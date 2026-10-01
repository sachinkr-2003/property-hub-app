import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
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
  Future<void> updateUserProfile({String? name, String? city, String? locality, String? profileImage}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      name: name,
      city: city,
      locality: locality,
      profileImage: profileImage,
    );
    _currentUser = updated;
    await StorageService.saveUserSession(updated.toJson());
    await StorageService.saveUserProfile(updated.name, updated.mobile);
    notifyListeners();

    // Sync to backend
    await ApiService.updateProfile(
      token: updated.token,
      name: name,
      city: city,
      locality: locality,
      profileImage: profileImage,
    );
  }

  /// Uploads and updates the user's profile image
  Future<void> uploadProfileImage(String imagePath) async {
    if (_currentUser == null) return;
    final uploadedUrl = await ApiService.uploadSingleFile(imagePath);
    if (uploadedUrl != null) {
      await updateUserProfile(profileImage: uploadedUrl);
    } else {
      throw Exception('Failed to upload image');
    }
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

  List<Property> get ownerProperties =>
      _properties.where((p) => p.ownerName == 'Rajesh Kumar' || p.ownerName == 'Vikramaditya Roy').toList();

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

  void addProperty(Property property) {
    _properties.insert(0, property);
    notifyListeners();

    // Asynchronously save to MongoDB in background
    ApiService.createProperty(property.toJson()).then((created) {
      if (created != null) {
        debugPrint('[AppStateProvider] Successfully created property in MongoDB: ${created.id}');
      }
    });
  }

  void togglePropertyStatus(String propertyId) {
    final index = _properties.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      _properties[index].status =
          (_properties[index].status == 'Active') ? 'Paused' : 'Active';
      notifyListeners();
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
      _properties[index] = Property(
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
      notifyListeners();
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

  void addRoommate(RoommateProfile roommate) {
    _roommates.insert(0, roommate);
    notifyListeners();

    ApiService.createRoommate(roommate.toJson()).then((created) {
      if (created != null) {
        debugPrint('[AppStateProvider] Created roommate in MongoDB: ${created.id}');
      }
    });
  }

  // Bachelor Services List
  final List<BachelorService> _services = [];

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

  // Used Items List (Marketplace)
  final List<UsedItem> _usedItems = [];

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

  void addUsedItem(UsedItem item) {
    _usedItems.insert(0, item);
    notifyListeners();

    ApiService.createUsedItem(item.toJson()).then((created) {
      if (created != null) {
        debugPrint('[AppStateProvider] Created used item in MongoDB: ${created.id}');
      }
    });
  }

  // Leads & Inquiries for Owner Mode
  final List<PropertyLead> _leads = [
    PropertyLead(
      id: 'lead-1',
      userName: 'Amit Sharma',
      userPhone: '+91 98390 12345',
      propertyTitle: 'Modern 3 BHK Luxury Flat',
      propertyId: 'prop-1',
      inquiryType: 'Visit Request',
      message: 'Hello, I want to visit this 3 BHK flat tomorrow around 5 PM. Is it available?',
      dateTime: DateTime.now().subtract(const Duration(minutes: 45)),
      status: 'New',
    ),
    PropertyLead(
      id: 'lead-2',
      userName: 'Rohit Verma',
      userPhone: '+91 94151 98765',
      propertyTitle: 'Independent 2 BHK Villa / House',
      propertyId: 'prop-2',
      inquiryType: 'Price Query',
      message: 'Can the rent be slightly negotiated if paid 6 months upfront?',
      dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'Contacted',
    ),
    PropertyLead(
      id: 'lead-3',
      userName: 'Sneha Singh',
      userPhone: '+91 99182 44332',
      propertyTitle: 'Cozy 1 BHK Studio for Bachelors',
      propertyId: 'prop-3',
      inquiryType: 'General Enquiry',
      message: 'Are two working girls allowed in this studio apartment?',
      dateTime: DateTime.now().subtract(const Duration(hours: 6)),
      status: 'Accepted',
    ),
  ];

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
      id: 'chat-1',
      participantName: 'Rohit Sharma (Direct Owner)',
      participantRole: 'Owner',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: '3 BHK Flat in Indira Nagar',
      lastMessage: 'Yes, it is available. Would you like to visit it?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
      unreadCount: 1,
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'm1',
          text: 'Hi, is this property still available for rent?',
          isSender: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        ChatMessage(
          id: 'm2',
          text: 'Hi! Yes, it is available. Would you like to visit it?',
          isSender: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ],
    ),
    ChatThread(
      id: 'chat-2',
      participantName: 'Amit Kumar',
      participantRole: 'Roommate Match',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
      propertyOrItemTitle: 'Roommate Inquiry (Gomti Nagar)',
      lastMessage: 'Great, let us connect over a call tonight.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'm3',
          text: 'Hey Amit! I saw your roommate profile. Are you still looking?',
          isSender: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        ChatMessage(
          id: 'm4',
          text: 'Great, let us connect over a call tonight.',
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
    }
  }

  // Owner KYC Status
  bool isAadhaarUploaded = true;
  bool isPanUploaded = true;
  bool isPhotoUploaded = true;
  String? aadhaarDocUrl;
  String? panDocUrl;
  String? selfiePhotoUrl;
  String kycStatus = 'Verified'; // Verified, Pending

  Future<bool> submitKyc({
    String name = 'Rajesh Kumar',
    String mobile = '+91 98765 43210',
    String email = 'rajesh.owner@propertyhub.in',
    String aadhaar = '4521-8890-3412',
    String pan = 'ABCDE1234F',
    String registry = 'Indira Nagar Registry Deed',
    String? aadhaarFilePath,
    String? panFilePath,
    String? selfieFilePath,
  }) async {
    isAadhaarUploaded = true;
    isPanUploaded = true;
    isPhotoUploaded = true;
    kycStatus = 'Pending';
    notifyListeners();

    // If local file paths are passed, upload them via multipart first
    if ((aadhaarFilePath != null && aadhaarFilePath.isNotEmpty) ||
        (panFilePath != null && panFilePath.isNotEmpty)) {
      final kycUrls = await ApiService.uploadKycDocs(
        aadhaarPath: aadhaarFilePath,
        panPath: panFilePath,
      );
      if (kycUrls['aadhaarUrl'] != null) aadhaarDocUrl = kycUrls['aadhaarUrl'];
      if (kycUrls['panUrl'] != null) panDocUrl = kycUrls['panUrl'];
    }

    if (selfieFilePath != null && selfieFilePath.isNotEmpty) {
      final selfieUrl = await ApiService.uploadSingleFile(selfieFilePath);
      if (selfieUrl != null) selfiePhotoUrl = selfieUrl;
    }

    final success = await ApiService.submitKyc(
      ownerName: name,
      mobile: mobile,
      email: email,
      aadhaarNumber: aadhaar,
      panNumber: pan,
      registryDetails: registry,
    );

    debugPrint('[AppStateProvider] KYC submitted to backend: $success');
    notifyListeners();
    return success;
  }

  // Visit Bookings (Digital Visit Passes)
  final List<VisitBooking> _visitBookings = [
    VisitBooking(
      id: 'vis-101',
      propertyId: 'prop-1',
      propertyTitle: 'Spacious 2 BHK Semi-Furnished Flat',
      propertyAddress: 'Sector 14, Indira Nagar, Lucknow',
      propertyImage: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
      ownerName: 'Rajesh Kumar',
      ownerPhone: '+91 98765 43210',
      visitDate: 'Tomorrow, 11:30 AM',
      timeSlot: 'Morning (10:00 AM - 1:00 PM)',
      passCode: 'PH-VIS-4921',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'Confirmed',
    ),
  ];

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

  void addVisitBooking(VisitBooking booking) {
    _visitBookings.insert(0, booking);
    notifyListeners();

    ApiService.createVisit(booking.toJson()).then((created) {
      if (created != null) {
        debugPrint('[AppStateProvider] Created visit in MongoDB: ${created.id}');
      }
    });
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

