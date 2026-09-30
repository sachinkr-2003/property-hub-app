class Property {
  final String id;
  final String title;
  final String type; // Flat, House, PG, Room, Office, Plot
  final String listingType; // Rent, Buy
  final double price;
  final String priceUnit; // /month, Lakhs, Cr
  final double? deposit;
  final int bhk;
  final int areaSqFt;
  final String address;
  final String locality;
  final String city;
  final List<String> images;
  final bool isVerified;
  final String ownerName;
  final String ownerPhone;
  final String ownerRole; // Direct Owner
  final List<String> amenities;
  final String furnishing; // Fully Furnished, Semi-Furnished, Unfurnished
  final String targetTenant; // Bachelors, Family, Anyone
  final String description;
  final DateTime postedAt;
  bool isFavorite;
  String status; // Active, Pending Verification, Rented

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.listingType,
    required this.price,
    this.priceUnit = '/month',
    this.deposit,
    required this.bhk,
    required this.areaSqFt,
    required this.address,
    required this.locality,
    this.city = 'Lucknow',
    required this.images,
    this.isVerified = true,
    required this.ownerName,
    required this.ownerPhone,
    this.ownerRole = 'Direct Owner',
    required this.amenities,
    this.furnishing = 'Semi-Furnished',
    this.targetTenant = 'Bachelors & Working Pros',
    required this.description,
    required this.postedAt,
    this.isFavorite = false,
    this.status = 'Active',
  });

  String get formattedPrice {
    if (listingType == 'Buy') {
      if (price >= 10000000) {
        return '₹ ${(price / 10000000).toStringAsFixed(2)} Cr';
      } else if (price >= 100000) {
        return '₹ ${(price / 100000).toStringAsFixed(1)} Lakh';
      }
      return '₹ ${price.toStringAsFixed(0)}';
    }
    return '₹ ${price.toStringAsFixed(0)}$priceUnit';
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['customId']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Flat',
      listingType: json['listingType']?.toString() ?? 'Rent',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      priceUnit: json['priceUnit']?.toString() ?? '/month',
      deposit: json['deposit'] != null ? (json['deposit'] is num ? (json['deposit'] as num).toDouble() : double.tryParse(json['deposit'].toString())) : null,
      bhk: (json['bhk'] is num) ? (json['bhk'] as num).toInt() : int.tryParse(json['bhk']?.toString() ?? '1') ?? 1,
      areaSqFt: (json['areaSqFt'] is num) ? (json['areaSqFt'] as num).toInt() : int.tryParse(json['areaSqFt']?.toString() ?? '800') ?? 800,
      address: json['address']?.toString() ?? '',
      locality: json['locality']?.toString() ?? '',
      city: json['city']?.toString() ?? 'Lucknow',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isVerified: json['isVerified'] == true,
      ownerName: json['ownerName']?.toString() ?? 'Owner',
      ownerPhone: json['ownerPhone']?.toString() ?? '',
      ownerRole: json['ownerRole']?.toString() ?? 'Direct Owner',
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      furnishing: json['furnishing']?.toString() ?? 'Semi-Furnished',
      targetTenant: json['targetTenant']?.toString() ?? 'Bachelors & Working Pros',
      description: json['description']?.toString() ?? '',
      postedAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      isFavorite: false,
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'title': title,
      'type': type,
      'listingType': listingType,
      'price': price,
      'priceUnit': priceUnit,
      'deposit': deposit,
      'bhk': bhk,
      'areaSqFt': areaSqFt,
      'address': address,
      'locality': locality,
      'city': city,
      'images': images,
      'isVerified': isVerified,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerRole': ownerRole,
      'amenities': amenities,
      'furnishing': furnishing,
      'targetTenant': targetTenant,
      'description': description,
      'status': status,
    };
  }
}
