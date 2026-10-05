import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../core/services/socket_service.dart';
import '../models/user_session_model.dart';
import '../models/property_model.dart';
import '../models/roommate_model.dart';
import '../models/service_model.dart';
import '../models/used_item_model.dart';
import '../models/lead_model.dart';
import '../models/chat_model.dart';
import '../models/visit_booking_model.dart';
import '../models/notification_item_model.dart';

enum AppRole { user, owner }

class AppStateProvider extends ChangeNotifier {
  AppStateProvider() {
    _loadPersistedState();
    loadAllLiveData();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    try {
      SocketService.instance.connect();
      SocketService.instance.addMessageListener((threadId, data) {
        final index = _chats.indexWhere((c) => c.id == threadId);
        final text = data['text']?.toString() ?? '';
        final isSender = data['senderId'] == (currentUser?.id ?? 'user');

        if (index != -1 && text.isNotEmpty) {
          final msgId = data['customId']?.toString() ?? 'msg-${DateTime.now().millisecondsSinceEpoch}';
          final exists = _chats[index].messages.any((m) => m.id == msgId);
          if (!exists) {
            _chats[index].messages.add(
              ChatMessage(
                id: msgId,
                text: text,
                isSender: isSender,
                timestamp: DateTime.now(),
              ),
            );
            _chats[index].lastMessage = text;
            _chats[index].lastMessageTime = DateTime.now();
            notifyListeners();
          }
        }
      });
    } catch (e) {
      debugPrint('[AppStateProvider] Socket init warning: $e');
    }
  }

  Future<void> loadAllLiveData() async {
    try {
      await Future.wait([
        loadLivePropertiesFromBackend(),
        loadLiveServicesFromBackend(),
        loadLiveUsedItemsFromBackend(),
        loadLiveRoommatesFromBackend(),
        loadLiveVisitsFromBackend(),
        loadLiveNotificationsFromBackend(),
        loadLiveConversationsFromBackend(),
        loadLiveKycStatusFromBackend(),
      ]);
    } catch (e) {
      debugPrint('[AppStateProvider] loadAllLiveData error: $e');
    }
  }

  void _loadPersistedState() {
    _isLoggedIn = StorageService.getLoggedIn(defaultValue: false);
    final savedRole = StorageService.getRole(defaultRole: 'user');
    _currentRole = savedRole == 'owner' ? AppRole.owner : AppRole.user;

    // Restore full UserSession from storage
    final savedSession = StorageService.getUserSession();
    if (savedSession != null) {
      try {
        _currentUser = UserSession.fromJson(savedSession);
      } catch (_) {}
    }

    final savedFavorites = StorageService.getFavorites();
    for (final prop in _properties) {
      if (savedFavorites.contains(prop.id)) {
        prop.isFavorite = true;
      }
    }
  }

  // ─── User Session ──────────────────────────────────────────────────────────
  UserSession? _currentUser;

  /// Currently logged-in user (null if not logged in)
  UserSession? get currentUser => _currentUser;

  /// Shortcut getters used throughout the app
  String get userName => _currentUser?.name ?? 'User';
  String get userPhone => _currentUser?.formattedPhone ?? '';
  String get userMobile => _currentUser?.mobile ?? '';
  String get userEmail => _currentUser?.email ?? '';
  String get userRole => _currentUser?.role ?? 'Tenant';
  String get userProfileImage => _currentUser?.profileImage ?? '';
  String get userToken => _currentUser?.token ?? '';

  // Current Active Mode (User Mode vs Owner Mode)
  AppRole _currentRole = AppRole.user;
  AppRole get currentRole => _currentRole;

  // Session & Authentication State
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Called after successful OTP verification — stores full session
  Future<void> loginWithSession(UserSession session) async {
    _currentUser = session;
    _isLoggedIn = true;
    await StorageService.setLoggedIn(true);
    await StorageService.setAuthToken(session.token);
    await StorageService.saveUserSession(session.toJson());
    await StorageService.saveUserProfile(session.name, session.mobile);
    notifyListeners();
    // Load live data after login
    loadAllLiveData();
  }

  /// Legacy quick-login (demo / fallback — no real session)
  void login() {
    _isLoggedIn = true;
    StorageService.setLoggedIn(true);
    notifyListeners();
  }

  /// Update user profile fields locally and on backend
  Future<void> updateUserProfile({
    String? name,
    String? mobile,
    String? email,
    String? city,
    String? locality,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name,
      mobile: mobile,
      email: email,
      city: city,
      locality: locality,
      profileImage: profileImage,
    );
    _currentUser = updated;
    await StorageService.saveUserSession(updated.toJson());
    await StorageService.saveUserProfile(updated.name, updated.mobile);
    notifyListeners();

    // Sync to backend
    final remoteUser = await ApiService.updateProfile(
      token: updated.token,
      name: name,
      mobile: mobile,
      email: email,
      city: city,
      locality: locality,
      profileImage: profileImage,
    );

    if (remoteUser != null) {
      _currentUser = remoteUser;
      await StorageService.saveUserSession(remoteUser.toJson());
      await StorageService.saveUserProfile(remoteUser.name, remoteUser.mobile);
      notifyListeners();
    }
  }

  /// Uploads and updates the user's profile image.
  /// Falls back to storing the local path if server upload fails,
  /// so the image at least shows on the current device.
  Future<String?> uploadProfileImage(String imagePath) async {
    if (_currentUser == null) return null;
    try {
      final uploadedUrl = await ApiService.uploadSingleFile(imagePath);
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        await updateUserProfile(profileImage: uploadedUrl);
        return uploadedUrl;
      }
    } catch (_) {}
    // Fallback: persist local path so avatar shows immediately on device
    await updateUserProfile(profileImage: imagePath);
    return imagePath;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _userNavIndex = 0;
    _ownerNavIndex = 0;
    _currentRole = AppRole.user;
    StorageService.clearSession();
    notifyListeners();
  }

  int _userNavIndex = 0;
  int get userNavIndex => _userNavIndex;

  int _ownerNavIndex = 0;
  int get ownerNavIndex => _ownerNavIndex;

  void setUserNavIndex(int index) {
    _userNavIndex = index;
    notifyListeners();
  }

  void setOwnerNavIndex(int index) {
    _ownerNavIndex = index;
    notifyListeners();
  }

  void setRole(AppRole role) {
    _currentRole = role;
    StorageService.setRole(role.name);
    notifyListeners();
  }

  void toggleRole() {
    _currentRole =
        (_currentRole == AppRole.user) ? AppRole.owner : AppRole.user;
    StorageService.setRole(_currentRole.name);
    notifyListeners();
  }

  // Location State
  String _selectedCity = 'Lucknow';
  String _selectedLocality = 'Indira Nagar';

  String get selectedCity => _selectedCity;
  String get selectedLocality => _selectedLocality;
  String get fullLocationText => '$_selectedLocality, $_selectedCity';

  void setLocation(String city, String locality) {
    _selectedCity = city;
    _selectedLocality = locality;
    notifyListeners();
  }

  // Search & Filter State
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All'; // All, Rent, Buy, PG, Room, Flat, House
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Owner Subscription Plan: 100% Free Forever
  String ownerSubscriptionPlan = '100% Free Lifetime';
  DateTime? subscriptionExpiry;

  void upgradeSubscription(String planName) {
    ownerSubscriptionPlan = '100% Free Lifetime';
    notifyListeners();
  }

  // Properties List
  final List<Property> _properties = [];

  bool _isLoadingProperties = false;
  bool get isLoadingProperties => _isLoadingProperties;

  List<Property> get properties => _properties;

  /// Fetch live properties directly from MongoDB backend
  Future<void> loadLivePropertiesFromBackend() async {
    _isLoadingProperties = true;
    notifyListeners();

    try {
      final liveProps = await ApiService.fetchProperties();
      if (liveProps.isNotEmpty) {
        _properties.clear();
        _properties.addAll(liveProps);

        // Re-apply saved favorites
        final savedFavorites = StorageService.getFavorites();
        for (final prop in _properties) {
          if (savedFavorites.contains(prop.id)) {
            prop.isFavorite = true;
          }
        }
        debugPrint('[AppStateProvider] Loaded ${liveProps.length} properties live from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback to default properties: $e');
    } finally {
      _isLoadingProperties = false;
      notifyListeners();
    }
  }

  List<Property> get filteredProperties {
    return _properties.where((p) {
      // Must be verified by admin and active before appearing to public users
      if (!p.isVerified || p.status != 'Active') {
        return false;
      }

      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.locality.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.address.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          p.type.toLowerCase() == _selectedCategory.toLowerCase() ||
          p.listingType.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Property> get favoriteProperties =>
      _properties.where((p) => p.isFavorite).toList();

  List<Property> get ownerProperties {
    final currentName = userName.trim().toLowerCase();
    final rawPhone = userMobile.isNotEmpty ? userMobile : userPhone;
    final currentPhone = rawPhone.replaceAll(RegExp(r'\D'), '');
    return _properties.where((p) {
      final pOwner = p.ownerName.trim().toLowerCase();
      final pPhone = p.ownerPhone.replaceAll(RegExp(r'\D'), '');
      final isMineByName = currentName.isNotEmpty &&
          currentName != 'user' &&
          currentName != 'property seeker' &&
          pOwner == currentName;
      final isMineByPhone = currentPhone.isNotEmpty &&
          pPhone.isNotEmpty &&
          (pPhone.endsWith(currentPhone.length >= 10 ? currentPhone.substring(currentPhone.length - 10) : currentPhone) ||
           currentPhone.endsWith(pPhone.length >= 10 ? pPhone.substring(pPhone.length - 10) : pPhone));
      final isDefaultTest = (currentPhone.isEmpty || currentName == 'user' || currentName.isEmpty) &&
          (pPhone.contains('9135321898') || pOwner.contains('sachin'));
      return isMineByName || isMineByPhone || isDefaultTest;
    }).toList();
  }

  void toggleFavorite(String propertyId) {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      _properties[index].isFavorite = !_properties[index].isFavorite;
      StorageService.saveFavorites(
        _properties.where((p) => p.isFavorite).map((p) => p.id).toList(),
      );
      notifyListeners();
    }
  }

  Future<Property?> addProperty(Property property) async {
    try {
      final created = await ApiService.createProperty(property.toJson());
      if (created != null) {
        debugPrint('[AppStateProvider] Successfully created property in MongoDB: ${created.id}');
        _properties.insert(0, created);
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('[AppStateProvider] createProperty error: $e');
    }
    return null;
  }

  void togglePropertyStatus(String propertyId) {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      final newStatus = (_properties[index].status == 'Active') ? 'Paused' : 'Active';
      _properties[index].status = newStatus;
      notifyListeners();

      // Live backend sync
      ApiService.updatePropertyStatus(propertyId, newStatus).then((ok) {
        if (ok) {
          debugPrint('[AppStateProvider] Synced property $propertyId status to $newStatus in MongoDB');
        }
      });
    }
  }

  void deleteProperty(String propertyId) {
    _properties.removeWhere((p) => p.id == propertyId);
    notifyListeners();

    // Live backend sync
    ApiService.deleteProperty(propertyId).then((ok) {
      if (ok) {
        debugPrint('[AppStateProvider] Deleted property $propertyId from MongoDB');
      }
    });
  }

  void updateProperty(Property updated) {
    final index = _properties.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _properties[index] = updated;
      notifyListeners();

      // Live backend sync
      ApiService.updateProperty(updated.id, updated.toJson()).then((res) {
        if (res != null) {
          debugPrint('[AppStateProvider] Synced updated property ${updated.id} in MongoDB');
        }
      });
    }
  }

  void updatePropertyPrice({
    required String propertyId,
    required double price,
    double? deposit,
  }) {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      final old = _properties[index];
      final updated = Property(
        id: old.id,
        title: old.title,
        type: old.type,
        listingType: old.listingType,
        price: price,
        priceUnit: old.priceUnit,
        deposit: deposit ?? old.deposit,
        bhk: old.bhk,
        areaSqFt: old.areaSqFt,
        address: old.address,
        locality: old.locality,
        city: old.city,
        images: old.images,
        isVerified: old.isVerified,
        ownerName: old.ownerName,
        ownerPhone: old.ownerPhone,
        ownerRole: old.ownerRole,
        amenities: old.amenities,
        furnishing: old.furnishing,
        targetTenant: old.targetTenant,
        description: old.description,
        postedAt: old.postedAt,
        isFavorite: old.isFavorite,
        status: old.status,
      );
      updateProperty(updated);
    }
  }

  // Roommate Profiles List
  final List<RoommateProfile> _roommates = [];

  bool _isLoadingRoommates = false;
  bool get isLoadingRoommates => _isLoadingRoommates;

  List<RoommateProfile> get roommates => _roommates;

  Future<void> loadLiveRoommatesFromBackend() async {
    _isLoadingRoommates = true;
    notifyListeners();
    try {
      final liveRoommates = await ApiService.fetchRoommates();
      if (liveRoommates.isNotEmpty) {
        _roommates.clear();
        _roommates.addAll(liveRoommates);
        debugPrint('[AppStateProvider] Loaded ${liveRoommates.length} roommates live from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback roommates: $e');
    } finally {
      _isLoadingRoommates = false;
      notifyListeners();
    }
  }

  Future<RoommateProfile?> addRoommate(RoommateProfile roommate) async {
    try {
      final created = await ApiService.createRoommate(roommate.toJson());
      if (created != null) {
        debugPrint('[AppStateProvider] Created roommate in MongoDB: ${created.id}');
        _roommates.insert(0, created);
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('[AppStateProvider] createRoommate error: $e');
    }
    _roommates.insert(0, roommate);
    notifyListeners();
    return null;
  }

  // Bachelor Services List with robust defaults
  final List<BachelorService> _services = [
    BachelorService(
      id: 'srv-1',
      title: 'Tiffin & Home Mess',
      category: 'Food',
      priceStarting: '₹ 120/meal',
      rating: 4.8,
      reviewsCount: 320,
      icon: BachelorService.getIconForCategory('Food'),
      color: BachelorService.getColorForCategory('Food'),
      description: 'Hygienic home-cooked north & south Indian meals delivered hot to your doorstep twice daily.',
      features: ['2 Daily Meals', 'Customizable Menu', 'Free Delivery', 'Trial Available'],
    ),
    BachelorService(
      id: 'srv-2',
      title: 'Laundry & Dry Clean',
      category: 'Laundry',
      priceStarting: '₹ 15/cloth',
      rating: 4.6,
      reviewsCount: 215,
      icon: BachelorService.getIconForCategory('Laundry'),
      color: BachelorService.getColorForCategory('Laundry'),
      description: 'Quick wash, press, and folding service with free pickup and drop within 24 hours.',
      features: ['Pickup & Drop', 'Fabric Care', '24h Delivery', 'Iron Included'],
    ),
    BachelorService(
      id: 'srv-3',
      title: 'Daily Cook & Maid',
      category: 'Maid',
      priceStarting: '₹ 1,500/mo',
      rating: 4.7,
      reviewsCount: 180,
      icon: BachelorService.getIconForCategory('Maid'),
      color: BachelorService.getColorForCategory('Maid'),
      description: 'Police-verified background checked domestic cooks and cleaning professionals for bachelor flats.',
      features: ['Police Verified', 'Flexible Timings', 'Trial Days', 'Replacement Guarantee'],
    ),
    BachelorService(
      id: 'srv-4',
      title: 'Deep Home Cleaning',
      category: 'Cleaning',
      priceStarting: '₹ 499',
      rating: 4.9,
      reviewsCount: 140,
      icon: BachelorService.getIconForCategory('Cleaning'),
      color: BachelorService.getColorForCategory('Cleaning'),
      description: 'Professional deep cleaning for kitchen, bathroom, bedroom, and move-in sanitization.',
      features: ['Eco-friendly Chemicals', 'Full Flat Sanitize', 'Kitchen Degrease', 'Trained Crew'],
    ),
    BachelorService(
      id: 'srv-5',
      title: 'Electrician Services',
      category: 'Electrician',
      priceStarting: '₹ 149',
      rating: 4.5,
      reviewsCount: 95,
      icon: BachelorService.getIconForCategory('Electrician'),
      color: BachelorService.getColorForCategory('Electrician'),
      description: 'Fast doorstep electrician for fan, light, geyser, wiring, and appliance setup.',
      features: ['30 Min Arrival', 'Standard Rates', 'Safety Inspected', 'Warranty on Repair'],
    ),
    BachelorService(
      id: 'srv-6',
      title: 'Plumber Services',
      category: 'Plumber',
      priceStarting: '₹ 149',
      rating: 4.6,
      reviewsCount: 110,
      icon: BachelorService.getIconForCategory('Plumber'),
      color: BachelorService.getColorForCategory('Plumber'),
      description: 'Leak repair, tap fitting, RO water purifier setup, and bathroom drainage resolution.',
      features: ['Leak Proof Guarantee', 'No Hidden Fees', 'Genuine Parts', 'Immediate Visit'],
    ),
    BachelorService(
      id: 'srv-7',
      title: 'Packers & Movers',
      category: 'Moving',
      priceStarting: '₹ 999',
      rating: 4.8,
      reviewsCount: 88,
      icon: BachelorService.getIconForCategory('Moving'),
      color: BachelorService.getColorForCategory('Moving'),
      description: 'Budget-friendly local room shifting and luggage transport for students and bachelors.',
      features: ['Safe Transit', 'Packing Materials', 'Loading & Unloading', 'Dedicated Mini Truck'],
    ),
    BachelorService(
      id: 'srv-8',
      title: 'Broadband & Wi-Fi',
      category: 'Wifi',
      priceStarting: '₹ 299/mo',
      rating: 4.5,
      reviewsCount: 165,
      icon: BachelorService.getIconForCategory('Wifi'),
      color: BachelorService.getColorForCategory('Wifi'),
      description: 'Same-day fiber broadband installation with unlimited high-speed internet and free router.',
      features: ['Free Router Setup', 'Up to 200 Mbps', 'Unlimited Data', 'Zero Installation Fee'],
    ),
    BachelorService(
      id: 'srv-9',
      title: 'Carpenter & Handyman',
      category: 'Carpenter',
      priceStarting: '₹ 199',
      rating: 4.4,
      reviewsCount: 76,
      icon: BachelorService.getIconForCategory('Carpenter'),
      color: BachelorService.getColorForCategory('Carpenter'),
      description: 'Door lock repair, study table assembly, bed fixing, and modular furniture setup.',
      features: ['Doorstep Service', 'Skilled Handyman', 'Quick Assembly', 'Fair Pricing'],
    ),
  ];

  bool _isLoadingServices = false;
  bool get isLoadingServices => _isLoadingServices;

  List<BachelorService> get services => _services;

  Future<void> loadLiveServicesFromBackend() async {
    _isLoadingServices = true;
    notifyListeners();
    try {
      final liveServices = await ApiService.fetchServices();
      if (liveServices.isNotEmpty) {
        _services.clear();
        _services.addAll(liveServices);
        debugPrint('[AppStateProvider] Loaded ${liveServices.length} services live from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback services: $e');
    } finally {
      _isLoadingServices = false;
      notifyListeners();
    }
  }

  final List<ServiceBooking> _bookings = [];
  List<ServiceBooking> get bookings => _bookings;

  void bookService(ServiceBooking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }

  void cancelServiceBooking(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings.removeAt(index);
      notifyListeners();
    }
  }

  // Used Items List (Marketplace) with robust defaults
  final List<UsedItem> _usedItems = [
    UsedItem(
      id: 'ITEM-301',
      title: 'Solid Sheesham Wood Queen Bed with Storage',
      category: 'Furniture',
      price: 11500,
      condition: 'Like New (1 yr used)',
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=400&q=80',
      location: 'Mahanagar, Lucknow',
      sellerName: 'Tanmay Gupta (Tenant)',
      sellerPhone: '+91 98190 77123',
      description: 'Well-maintained solid wood queen bed with hydraulic storage box. Moving out soon.',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    UsedItem(
      id: 'ITEM-302',
      title: 'LG 260L 3-Star Inverter Frost-Free Refrigerator',
      category: 'Appliances',
      price: 13500,
      condition: 'Good Condition',
      imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=400&q=80',
      location: 'Gomti Nagar, Lucknow',
      sellerName: 'Neha Rastogi',
      sellerPhone: '+91 94151 33445',
      description: 'Works perfectly, silent operation and very energy efficient. Bill available.',
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    UsedItem(
      id: 'ITEM-304',
      title: 'Bajaj Majesty 16L Microwave Oven',
      category: 'Appliances',
      price: 2400,
      condition: 'Like New',
      imageUrl: 'https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?auto=format&fit=crop&w=400&q=80',
      location: 'Aliganj, Lucknow',
      sellerName: 'Vikram Joshi',
      sellerPhone: '+91 94500 11223',
      description: 'Hardly used for 6 months. Clean, includes baking tray and wire rack.',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    UsedItem(
      id: 'ITEM-305',
      title: 'Modern Study Table with Bookshelf',
      category: 'Study',
      price: 1800,
      condition: 'Good Condition',
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=400&q=80',
      location: 'Indira Nagar, Lucknow',
      sellerName: 'Aman Verma',
      sellerPhone: '+91 98390 12345',
      description: 'Engineered wood study desk with 3 shelves for books and laptop wire hole.',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  bool _isLoadingUsedItems = false;
  bool get isLoadingUsedItems => _isLoadingUsedItems;

  List<UsedItem> get usedItems => _usedItems;

  Future<void> loadLiveUsedItemsFromBackend() async {
    _isLoadingUsedItems = true;
    notifyListeners();
    try {
      final liveItems = await ApiService.fetchUsedItems();
      if (liveItems.isNotEmpty) {
        _usedItems.clear();
        _usedItems.addAll(liveItems);
        debugPrint('[AppStateProvider] Loaded ${liveItems.length} used items live from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback used items: $e');
    } finally {
      _isLoadingUsedItems = false;
      notifyListeners();
    }
  }

  Future<UsedItem?> addUsedItem(UsedItem item) async {
    try {
      final created = await ApiService.createUsedItem(item.toJson());
      if (created != null) {
        debugPrint('[AppStateProvider] Created used item in MongoDB: ${created.id}');
        _usedItems.insert(0, created);
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('[AppStateProvider] createUsedItem error: $e');
    }
    _usedItems.insert(0, item);
    notifyListeners();
    return null;
  }

  // Leads & Inquiries for Owner Mode
  final List<PropertyLead> _leads = [];

  List<PropertyLead> get leads => _leads;

  void updateLeadStatus(String leadId, String status) {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      _leads[index].status = status;
      notifyListeners();
    }
  }

  void addLead(PropertyLead lead) {
    _leads.insert(0, lead);
    notifyListeners();
  }

  // Chat Threads
  final List<ChatThread> _chats = [
    ChatThread(
      id: 'chat-owner-sachin',
      participantName: 'Sachin Kumar (Owner)',
      participantRole: 'Direct Landlord',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: 'Luxury 3 BHK Villa in Gomti Nagar',
      lastMessage: 'Hi! Yes, registry deed is verified. You can visit tomorrow at 4:30 PM.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 8)),
      unreadCount: 1,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'm1',
          text: 'Hi Sachin ji, I am interested in your Luxury 3 BHK Villa in Gomti Nagar.',
          isSender: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        ChatMessage(
          id: 'm2',
          text: 'Namaste! Yes, the villa is available for family tenants with zero brokerage.',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        ),
        ChatMessage(
          id: 'm3',
          text: 'Is the rent negotiable? Can we schedule a site visit?',
          isSender: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        ChatMessage(
          id: 'm4',
          text: 'Hi! Yes, registry deed is verified. You can visit tomorrow at 4:30 PM.',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ],
    ),
    ChatThread(
      id: 'chat-tenant-priya',
      participantName: 'Priya Sharma (Tenant)',
      participantRole: 'Working Professional',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: '2 BHK Modern Flat in Indira Nagar',
      lastMessage: 'Sure, let us connect over WhatsApp call to confirm the move-in date.',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 42)),
      unreadCount: 0,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'p1',
          text: 'Hello, is the 2 BHK Modern Flat in Indira Nagar still vacant?',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        ChatMessage(
          id: 'p2',
          text: 'Yes Priya ji, completely vacant with modular kitchen and 24/7 power backup.',
          isSender: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        ),
        ChatMessage(
          id: 'p3',
          text: 'Sure, let us connect over WhatsApp call to confirm the move-in date.',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        ),
      ],
    ),
    ChatThread(
      id: 'chat-support-concierge',
      participantName: 'Property Hub Concierge',
      participantRole: 'Verified Help Desk',
      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: 'Zero Brokerage Guarantee',
      lastMessage: 'Your owner deed verification is approved with green verified badge.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'c1',
          text: 'Welcome to Property Hub! Direct owner and tenant live chat is active with real-time socket delivery.',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ChatMessage(
          id: 'c2',
          text: 'Your owner deed verification is approved with green verified badge.',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
  ];

  List<ChatThread> get chats => _chats;

  Future<void> loadLiveConversationsFromBackend() async {
    try {
      final liveChats = await ApiService.fetchConversations();
      if (liveChats.isNotEmpty) {
        _chats.clear();
        _chats.addAll(liveChats);
        notifyListeners();
        debugPrint('[AppStateProvider] Loaded ${liveChats.length} conversations from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback conversations: $e');
    }
  }

  ChatThread getOrCreateChatThread({
    required String participantName,
    required String propertyTitle,
    String? avatarUrl,
    String? role,
  }) {
    final existingIndex = _chats.indexWhere((c) =>
        c.participantName.trim().toLowerCase() ==
            participantName.trim().toLowerCase() ||
        (propertyTitle.isNotEmpty &&
            c.propertyOrItemTitle.trim().toLowerCase() ==
                propertyTitle.trim().toLowerCase()));
    if (existingIndex != -1) {
      return _chats[existingIndex];
    }
    final newThread = ChatThread(
      id: 'chat-${DateTime.now().millisecondsSinceEpoch}',
      participantName: participantName,
      participantRole: role ?? 'Direct Owner',
      avatarUrl: avatarUrl ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: propertyTitle,
      lastMessage: 'Hi, I am interested in: $propertyTitle',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'init-1',
          text: 'Hi, I would like to enquire about: $propertyTitle',
          isSender: true,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _chats.insert(0, newThread);
    notifyListeners();

    // Async persist to MongoDB
    ApiService.createConversation(
      participantName: participantName,
      propertyTitle: propertyTitle,
      avatarUrl: avatarUrl,
      role: role,
      initialMessage: 'Hi, I would like to enquire about: $propertyTitle',
    ).then((created) {
      if (created != null) {
        final idx = _chats.indexWhere((c) => c.id == newThread.id);
        if (idx != -1) {
          _chats[idx] = created;
          notifyListeners();
        }
      }
    });

    return newThread;
  }

  void sendChatMessage(String threadId, String text) {
    final index = _chats.indexWhere((c) => c.id == threadId);
    if (index != -1) {
      final now = DateTime.now();
      _chats[index].messages.add(
        ChatMessage(
          id: 'msg-${now.millisecondsSinceEpoch}',
          text: text,
          isSender: true,
          timestamp: now,
        ),
      );
      _chats[index].lastMessage = text;
      _chats[index].lastMessageTime = now;
      notifyListeners();

      // Async backend call to persist in MongoDB
      ApiService.sendChatMessage(threadId, text, senderName: userName);

      // Instant WebSocket broadcast to other participant
      SocketService.instance.sendMessage(
        threadId: threadId,
        text: text,
        senderName: userName,
        senderId: currentUser?.id ?? 'user',
        isSender: true,
      );
    }
  }

  // Owner KYC Status
  bool isAadhaarUploaded = false;
  bool isPanUploaded = false;
  bool isPhotoUploaded = false;
  String? aadhaarDocUrl;
  String? panDocUrl;
  String? registryDocUrl;
  String? selfiePhotoUrl;
  String kycStatus = 'Unverified'; // Verified, Pending, Unverified

  Future<bool> submitKyc({
    String name = 'Property Owner',
    String mobile = '',
    String email = '',
    String aadhaar = '',
    String pan = '',
    String registry = '',
    String? aadhaarFilePath,
    String? panFilePath,
    String? registryFilePath,
    String? selfieFilePath,
  }) async {
    isAadhaarUploaded = true;
    isPanUploaded = true;
    isPhotoUploaded = true;
    kycStatus = 'Pending';
    notifyListeners();

    // 1. Upload Aadhaar & PAN
    if ((aadhaarFilePath != null && aadhaarFilePath.isNotEmpty) ||
        (panFilePath != null && panFilePath.isNotEmpty)) {
      final kycUrls = await ApiService.uploadKycDocs(
        aadhaarPath: aadhaarFilePath,
        panPath: panFilePath,
      );
      if (kycUrls['aadhaarUrl'] != null) aadhaarDocUrl = kycUrls['aadhaarUrl'];
      if (kycUrls['panUrl'] != null) panDocUrl = kycUrls['panUrl'];

      // Fallback: convert local files to Base64 data URI if multipart upload failed
      if (aadhaarDocUrl == null && aadhaarFilePath != null && aadhaarFilePath.isNotEmpty) {
        try {
          final bytes = await File(aadhaarFilePath).readAsBytes();
          final ext = aadhaarFilePath.split('.').last.toLowerCase();
          final mime = (ext == 'pdf') ? 'application/pdf' : 'image/jpeg';
          aadhaarDocUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        } catch (_) {}
      }
      if (panDocUrl == null && panFilePath != null && panFilePath.isNotEmpty) {
        try {
          final bytes = await File(panFilePath).readAsBytes();
          final ext = panFilePath.split('.').last.toLowerCase();
          final mime = (ext == 'pdf') ? 'application/pdf' : 'image/jpeg';
          panDocUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        } catch (_) {}
      }
    }

    // 2. Upload Property Deed / Registry
    if (registryFilePath != null && registryFilePath.isNotEmpty) {
      final deedUrl = await ApiService.uploadDeedDoc(registryFilePath);
      if (deedUrl != null && deedUrl.isNotEmpty) {
        registryDocUrl = deedUrl;
      }
    }

    // 3. Upload Owner Live Selfie / Photo
    if (selfieFilePath != null && selfieFilePath.isNotEmpty) {
      final selfieUrl = await ApiService.uploadSingleFile(selfieFilePath);
      if (selfieUrl != null) {
        selfiePhotoUrl = selfieUrl;
      } else {
        try {
          final bytes = await File(selfieFilePath).readAsBytes();
          selfiePhotoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        } catch (_) {}
      }
    }

    final success = await ApiService.submitKyc(
      ownerName: name.isNotEmpty ? name : (userName.isNotEmpty ? userName : 'Property Owner'),
      mobile: mobile.isNotEmpty ? mobile : (userMobile.isNotEmpty ? userMobile : userPhone),
      email: email.isNotEmpty ? email : userEmail,
      aadhaarNumber: aadhaar,
      panNumber: pan,
      registryDetails: registry,
      aadhaarUrl: aadhaarDocUrl,
      panUrl: panDocUrl,
      registryUrl: registryDocUrl,
      selfieUrl: selfiePhotoUrl,
      role: 'Direct Owner',
    );

    debugPrint('[AppStateProvider] KYC submitted to backend: $success');
    notifyListeners();
    return success;
  }

  /// Sync live KYC status from backend so owner immediately gets Verified badge
  Future<void> loadLiveKycStatusFromBackend() async {
    final phone = (userMobile.isNotEmpty ? userMobile : (userPhone.isNotEmpty ? userPhone : '9135321898')).replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) return;
    try {
      final res = await ApiService.fetchKycStatus(phone);
      if (res != null) {
        final serverStatus = res['kycStatus']?.toString();
        if (serverStatus != null && serverStatus.isNotEmpty) {
          kycStatus = serverStatus;
          if (kycStatus == 'Verified') {
            isAadhaarUploaded = true;
            isPanUploaded = true;
            isPhotoUploaded = true;
          }
          notifyListeners();
          debugPrint('[AppStateProvider] Synced live Owner KYC status: $kycStatus');
        }
      }
    } catch (e) {
      debugPrint('[AppStateProvider] loadLiveKycStatus error: $e');
    }
  }

  // Visit Bookings (Digital Visit Passes)
  final List<VisitBooking> _visitBookings = [];

  bool _isLoadingVisits = false;
  bool get isLoadingVisits => _isLoadingVisits;

  List<VisitBooking> get visitBookings => _visitBookings;

  Future<void> loadLiveVisitsFromBackend() async {
    _isLoadingVisits = true;
    notifyListeners();
    try {
      final liveVisits = await ApiService.fetchVisits();
      if (liveVisits.isNotEmpty) {
        _visitBookings.clear();
        _visitBookings.addAll(liveVisits);
        debugPrint('[AppStateProvider] Loaded ${liveVisits.length} visits live from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback visits: $e');
    } finally {
      _isLoadingVisits = false;
      notifyListeners();
    }
  }

  Future<VisitBooking?> addVisitBooking(VisitBooking booking) async {
    try {
      final created = await ApiService.createVisit(booking.toJson());
      if (created != null) {
        debugPrint('[AppStateProvider] Created visit in MongoDB: ${created.id}');
        _visitBookings.insert(0, created);
        notifyListeners();
        return created;
      }
    } catch (e) {
      debugPrint('[AppStateProvider] createVisit error: $e');
    }
    _visitBookings.insert(0, booking);
    notifyListeners();
    return null;
  }

  void cancelVisitBooking(String id) {
    final index = _visitBookings.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visitBookings.removeAt(index);
      notifyListeners();
    }
  }

  // ----------------------------------------------------
  // Push Notifications & Communication Center
  // ----------------------------------------------------
  List<NotificationItem> _notifications = [];
  bool _isLoadingNotifications = false;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoadingNotifications => _isLoadingNotifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadLiveNotificationsFromBackend() async {
    _isLoadingNotifications = true;
    notifyListeners();
    try {
      final audience = _currentRole == AppRole.owner ? 'OwnerHub Owner App' : 'BachelorHub User App';
      final liveNotifs = await ApiService.fetchNotifications(
        audience: audience,
        userId: _currentUser?.id,
      );
      if (liveNotifs.isNotEmpty) {
        _notifications = liveNotifs;
        debugPrint('[AppStateProvider] Loaded ${liveNotifs.length} notifications from MongoDB');
      }
    } catch (e) {
      debugPrint('[AppStateProvider] Fallback notifications: $e');
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
      ApiService.markNotificationRead(id);
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    for (final n in _notifications) {
      ApiService.markNotificationRead(n.id);
    }
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    notifyListeners();
    await ApiService.clearAllNotifications();
  }
}

