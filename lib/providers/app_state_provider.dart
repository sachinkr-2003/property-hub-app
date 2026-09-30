import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../models/property_model.dart';
import '../models/roommate_model.dart';
import '../models/service_model.dart';
import '../models/used_item_model.dart';
import '../models/lead_model.dart';
import '../models/chat_model.dart';
import '../models/visit_booking_model.dart';

enum AppRole { user, owner }

class AppStateProvider extends ChangeNotifier {
  AppStateProvider() {
    _loadPersistedState();
    loadLivePropertiesFromBackend();
  }

  void _loadPersistedState() {
    _isLoggedIn = StorageService.getLoggedIn(defaultValue: true);
    final savedRole = StorageService.getRole(defaultRole: 'user');
    _currentRole = savedRole == 'owner' ? AppRole.owner : AppRole.user;

    final savedFavorites = StorageService.getFavorites();
    for (final prop in _properties) {
      if (savedFavorites.contains(prop.id)) {
        prop.isFavorite = true;
      }
    }
  }

  // Current Active Mode (User Mode vs Owner Mode)
  AppRole _currentRole = AppRole.user;
  AppRole get currentRole => _currentRole;

  // Session & Authentication State
  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    StorageService.setLoggedIn(true);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
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
  final List<Property> _properties = [
    Property(
      id: 'prop-1',
      title: 'Modern 3 BHK Luxury Flat',
      type: 'Flat',
      listingType: 'Rent',
      price: 25000,
      priceUnit: '/month',
      deposit: 50000,
      bhk: 3,
      areaSqFt: 1450,
      address: 'Plot 42, Sector 5, Indira Nagar',
      locality: 'Indira Nagar',
      city: 'Lucknow',
      images: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=80',
      ],
      isVerified: true,
      ownerName: 'Rajesh Kumar',
      ownerPhone: '+91 98765 43210',
      ownerRole: 'Direct Owner',
      amenities: ['Parking', 'Lift', 'Security', 'Gym', 'Power Backup', 'Wi-Fi'],
      furnishing: 'Fully Furnished',
      targetTenant: 'Bachelors & Working Pros',
      description: 'Spacious 3 BHK apartment with modular kitchen, premium wooden flooring, 2 balconies with scenic view, 24/7 power backup and gym access. No brokerage, direct owner agreement.',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFavorite: true,
      status: 'Active',
    ),
    Property(
      id: 'prop-2',
      title: 'Independent 2 BHK Villa / House',
      type: 'House',
      listingType: 'Rent',
      price: 12000,
      priceUnit: '/month',
      deposit: 24000,
      bhk: 2,
      areaSqFt: 1200,
      address: 'House 112, Near Kapoorthala, Aliganj',
      locality: 'Aliganj',
      city: 'Lucknow',
      images: [
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1000&q=80',
      ],
      isVerified: true,
      ownerName: 'Sunil Sharma',
      ownerPhone: '+91 94150 12345',
      ownerRole: 'Direct Owner',
      amenities: ['Parking', 'Garden', 'Security', 'Wi-Fi'],
      furnishing: 'Semi-Furnished',
      targetTenant: 'Bachelors or Small Family',
      description: 'Independent house on ground floor. Very close to coaching hub and market. Safe neighborhood with dedicated car parking.',
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
      isFavorite: false,
      status: 'Active',
    ),
    Property(
      id: 'prop-3',
      title: 'Cozy 1 BHK Studio for Bachelors',
      type: 'Room',
      listingType: 'Rent',
      price: 8500,
      priceUnit: '/month',
      deposit: 8500,
      bhk: 1,
      areaSqFt: 550,
      address: 'Vibhuti Khand, Gomti Nagar',
      locality: 'Gomti Nagar',
      city: 'Lucknow',
      images: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1000&q=80',
      ],
      isVerified: true,
      ownerName: 'Manish Verma',
      ownerPhone: '+91 97920 88990',
      ownerRole: 'Direct Owner',
      amenities: ['Wi-Fi', 'Security', 'Power Backup', 'Lift'],
      furnishing: 'Fully Furnished',
      targetTenant: 'Male / Female Bachelor',
      description: 'Walkable distance to IT Park, TCS, and DLF MyPad. Includes high-speed Wi-Fi, refrigerator, and AC.',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFavorite: false,
      status: 'Active',
    ),
    Property(
      id: 'prop-4',
      title: 'Luxury 4 BHK Duplex House for Sale',
      type: 'House',
      listingType: 'Buy',
      price: 9500000,
      priceUnit: '',
      bhk: 4,
      areaSqFt: 2400,
      address: 'Vipul Khand, Gomti Nagar',
      locality: 'Gomti Nagar',
      city: 'Lucknow',
      images: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1000&q=80',
      ],
      isVerified: true,
      ownerName: 'Praveen Tiwari',
      ownerPhone: '+91 93351 11223',
      ownerRole: 'Direct Owner',
      amenities: ['Parking', 'Garden', 'Security', 'Gym', 'Power Backup'],
      furnishing: 'Unfurnished',
      targetTenant: 'Buyers',
      description: 'LDA approved duplex property with prime location, 30 ft wide road, east facing, and complete ownership papers ready.',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
      isFavorite: false,
      status: 'Active',
    ),
    Property(
      id: 'prop-5',
      title: 'Premium PG Room with Mess Included',
      type: 'PG',
      listingType: 'Rent',
      price: 6500,
      priceUnit: '/month',
      deposit: 5000,
      bhk: 1,
      areaSqFt: 250,
      address: 'Near Engineering College Chauraha, Jankipuram',
      locality: 'Jankipuram',
      city: 'Lucknow',
      images: [
        'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&w=1000&q=80',
      ],
      isVerified: true,
      ownerName: 'Ashok Tripathi',
      ownerPhone: '+91 99180 55443',
      ownerRole: 'Direct Owner',
      amenities: ['Wi-Fi', 'Security', 'Power Backup'],
      furnishing: 'Fully Furnished',
      targetTenant: 'Bachelors (Students/Job)',
      description: 'Pure veg home-style 3 times food included. RO drinking water, geyser, cooler, and daily cleaning provided.',
      postedAt: DateTime.now().subtract(const Duration(hours: 12)),
      isFavorite: false,
      status: 'Active',
    ),
  ];

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
  final List<RoommateProfile> _roommates = [
    RoommateProfile(
      id: 'rm-1',
      name: 'Amit Kumar',
      age: 24,
      profession: 'Software Engineer',
      budgetRange: '₹5k - 8k',
      preferredLocation: 'Gomti Nagar, Lucknow',
      lookingFor: '1 Room in 2BHK / 3BHK Flat',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      gender: 'Male',
      habits: ['Non-Smoker', 'Veg / Non-Veg', 'Night Owl'],
      about: 'Working at HCL Lucknow. Looking for a chill, clean, and friendly flatmate who respects privacy.',
      phone: '+91 98765 11223',
    ),
    RoommateProfile(
      id: 'rm-2',
      name: 'Rahul Singh',
      age: 26,
      profession: 'Govt. Job Aspirant / UPSC',
      budgetRange: '₹7k - 10k',
      preferredLocation: 'Aliganj, Lucknow',
      lookingFor: 'Separate Room in Flat',
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      gender: 'Male',
      habits: ['Pure Veg', 'Non-Smoker', 'Quiet Environment'],
      about: 'Preparing for civil services. Need a peaceful environment with serious and disciplined roommates.',
      phone: '+91 94155 33445',
    ),
    RoommateProfile(
      id: 'rm-3',
      name: 'Priya Sharma',
      age: 23,
      profession: 'UI/UX Designer',
      budgetRange: '₹6k - 9k',
      preferredLocation: 'Indira Nagar, Lucknow',
      lookingFor: 'Female Flatmate in 2BHK',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      gender: 'Female',
      habits: ['Non-Smoker', 'Pet Friendly'],
      about: 'Working remotely for a Bangalore startup. Friendly, loves music and clean space.',
      phone: '+91 99188 66778',
    ),
  ];

  List<RoommateProfile> get roommates => _roommates;

  void addRoommate(RoommateProfile roommate) {
    _roommates.insert(0, roommate);
    notifyListeners();
  }

  // Bachelor Services List
  final List<BachelorService> _services = [
    BachelorService(
      id: 'srv-1',
      title: 'Tiffin / Mess',
      category: 'Food',
      priceStarting: '₹ 2,400 / month',
      rating: 4.8,
      reviewsCount: 142,
      icon: Icons.restaurant,
      color: const Color(0xFFF97316),
      description: 'Hygienic, home-cooked daily meals delivered to your doorstep (Lunch & Dinner).',
      features: ['Veg & Non-Veg options', 'Free Delivery', 'Customizable roti/rice', 'Sunday Special'],
    ),
    BachelorService(
      id: 'srv-2',
      title: 'Laundry & Iron',
      category: 'Cleaning',
      priceStarting: '₹ 49 / kg',
      rating: 4.7,
      reviewsCount: 98,
      icon: Icons.local_laundry_service,
      color: const Color(0xFF0EA5E9),
      description: 'Doorstep pickup & express 24-hr delivery for washed, dried & steam pressed clothes.',
      features: ['Steam Ironing', 'Fabric Care', 'Fast Turnaround', 'Pick & Drop'],
    ),
    BachelorService(
      id: 'srv-3',
      title: 'House Maid / Cook',
      category: 'Household',
      priceStarting: '₹ 1,500 / month',
      rating: 4.9,
      reviewsCount: 210,
      icon: Icons.cleaning_services,
      color: const Color(0xFF8B5CF6),
      description: 'Police-verified maids and professional cooks for daily cooking, dusting, and utensils.',
      features: ['Background Verified', 'Experienced Cooks', 'Trial Day Available', 'Flexible Timings'],
    ),
    BachelorService(
      id: 'srv-4',
      title: 'Deep Cleaning',
      category: 'Cleaning',
      priceStarting: '₹ 699',
      rating: 4.6,
      reviewsCount: 76,
      icon: Icons.sanitizer,
      color: const Color(0xFF10B981),
      description: 'Bathroom, kitchen, and full room sanitize & mechanized deep clean.',
      features: ['Eco-friendly chemicals', 'Machine scrubbing', 'Anti-bacterial spray'],
    ),
    BachelorService(
      id: 'srv-5',
      title: 'Electrician',
      category: 'Repairs',
      priceStarting: '₹ 149 visit',
      rating: 4.8,
      reviewsCount: 185,
      icon: Icons.electric_bolt,
      color: const Color(0xFFF59E0B),
      description: 'Expert repair of fans, wiring, switches, inverters, and appliances.',
      features: ['30 mins doorstep arrival', 'Standard rate card', '30-day warranty'],
    ),
    BachelorService(
      id: 'srv-6',
      title: 'Plumber',
      category: 'Repairs',
      priceStarting: '₹ 149 visit',
      rating: 4.7,
      reviewsCount: 120,
      icon: Icons.plumbing,
      color: const Color(0xFF3B82F6),
      description: 'Fix leakages, tap installation, geyser fitting, and water pipe blockages.',
      features: ['Quick fix', 'Genuine parts', 'Trained professionals'],
    ),
    BachelorService(
      id: 'srv-7',
      title: 'Carpenter',
      category: 'Repairs',
      priceStarting: '₹ 199 visit',
      rating: 4.6,
      reviewsCount: 65,
      icon: Icons.handyman,
      color: const Color(0xFFD97706),
      description: 'Bed assembly, door lock fixing, furniture repair, and curtain rod installation.',
      features: ['Fast service', 'Wood polish', 'Modular repair'],
    ),
    BachelorService(
      id: 'srv-8',
      title: 'Wi-Fi / Broadband',
      category: 'Utility',
      priceStarting: '₹ 499 / month',
      rating: 4.9,
      reviewsCount: 310,
      icon: Icons.wifi,
      color: const Color(0xFF6366F1),
      description: 'Ultra-fast fiber optic broadband with same-day connection and zero installation fee.',
      features: ['Up to 200 Mbps', 'Unlimited Data', 'Free dual-band router', '24/7 support'],
    ),
    BachelorService(
      id: 'srv-9',
      title: 'Packers & Movers',
      category: 'Shifting',
      priceStarting: '₹ 999',
      rating: 4.8,
      reviewsCount: 88,
      icon: Icons.local_shipping,
      color: const Color(0xFFEC4899),
      description: 'Hassle-free room and flat shifting with safe packing and vehicle transport.',
      features: ['Bubble wrap packing', 'Dedicated loading team', 'Zero scratch guarantee'],
    ),
  ];

  List<BachelorService> get services => _services;

  final List<ServiceBooking> _bookings = [
    ServiceBooking(
      id: 'bk-1',
      serviceTitle: 'Tiffin / Mess Service',
      date: 'Tomorrow, Lunch Delivery',
      timeSlot: '1:00 PM - 1:30 PM',
      address: 'Indira Nagar, Lucknow',
      price: 2499,
    ),
    ServiceBooking(
      id: 'bk-2',
      serviceTitle: 'Room Deep Cleaning',
      date: 'Saturday',
      timeSlot: 'Morning (10:00 AM)',
      address: 'Indira Nagar, Lucknow',
      price: 699,
    ),
  ];
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
  final List<UsedItem> _usedItems = [
    UsedItem(
      id: 'item-1',
      title: 'Comfortable 3-Seater Sofa Set',
      price: 6000,
      condition: 'Good Condition',
      category: 'Furniture',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&w=600&q=80',
      location: 'Indira Nagar, Lucknow',
      sellerName: 'Vikas Pandey',
      sellerPhone: '+91 98890 12345',
      description: 'Wooden structure, beige cushions. Used for 1.5 years. Selling because shifting to another city.',
      postedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UsedItem(
      id: 'item-2',
      title: 'Whirlpool Single Door Refrigerator 190L',
      price: 8500,
      condition: 'Like New',
      category: 'Appliances',
      imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=600&q=80',
      location: 'Gomti Nagar, Lucknow',
      sellerName: 'Anurag Mishra',
      sellerPhone: '+91 97210 56789',
      description: '4-star energy rating. In warranty till 2027. Works completely fine with bill and box.',
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    UsedItem(
      id: 'item-3',
      title: 'Wooden 4-Seater Dining Table',
      price: 4000,
      condition: 'Good Condition',
      category: 'Furniture',
      imageUrl: 'https://images.unsplash.com/photo-1617806118233-18e1de247200?auto=format&fit=crop&w=600&q=80',
      location: 'Aliganj, Lucknow',
      sellerName: 'Deepak Yadav',
      sellerPhone: '+91 94500 88991',
      description: 'Solid teak wood finish dining table with 4 cushioned chairs. Perfect for bachelor flat.',
      postedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    UsedItem(
      id: 'item-4',
      title: 'Study Table & Ergonomic Office Chair',
      price: 3200,
      condition: 'Like New',
      category: 'Study',
      imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?auto=format&fit=crop&w=600&q=80',
      location: 'Mahanagar, Lucknow',
      sellerName: 'Sumit Saxena',
      sellerPhone: '+91 91250 33442',
      description: 'Adjustable mesh back office chair with sturdy study table. Ideal for WFH / students.',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<UsedItem> get usedItems => _usedItems;

  void addUsedItem(UsedItem item) {
    _usedItems.insert(0, item);
    notifyListeners();
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
    }
  }

  // Owner KYC Status
  bool isAadhaarUploaded = true;
  bool isPanUploaded = true;
  bool isPhotoUploaded = true;
  String kycStatus = 'Verified'; // Verified, Pending

  void submitKyc({
    String name = 'Rajesh Kumar',
    String mobile = '+91 98765 43210',
    String email = 'rajesh.owner@propertyhub.in',
    String aadhaar = '4521-8890-3412',
    String pan = 'ABCDE1234F',
    String registry = 'Indira Nagar Registry Deed',
  }) {
    isAadhaarUploaded = true;
    isPanUploaded = true;
    isPhotoUploaded = true;
    kycStatus = 'Pending';
    notifyListeners();

    ApiService.submitKyc(
      ownerName: name,
      mobile: mobile,
      email: email,
      aadhaarNumber: aadhaar,
      panNumber: pan,
      registryDetails: registry,
    ).then((success) {
      debugPrint('[AppStateProvider] KYC submitted to backend: $success');
    });
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

  List<VisitBooking> get visitBookings => _visitBookings;

  void addVisitBooking(VisitBooking booking) {
    _visitBookings.insert(0, booking);
    notifyListeners();
  }

  void cancelVisitBooking(String id) {
    final index = _visitBookings.indexWhere((v) => v.id == id);
    if (index != -1) {
      _visitBookings.removeAt(index);
      notifyListeners();
    }
  }
}

