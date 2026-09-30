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
}
