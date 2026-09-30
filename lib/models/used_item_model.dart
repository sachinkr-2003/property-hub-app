class UsedItem {
  final String id;
  final String title;
  final double price;
  final String condition; // Like New, Good Condition, Fair
  final String category; // Furniture, Electronics, Appliances, Study
  final String imageUrl;
  final String location;
  final String sellerName;
  final String sellerPhone;
  final String description;
  final DateTime postedAt;
  final bool isVerified;

  UsedItem({
    required this.id,
    required this.title,
    required this.price,
    required this.condition,
    required this.category,
    required this.imageUrl,
    required this.location,
    required this.sellerName,
    required this.sellerPhone,
    required this.description,
    required this.postedAt,
    this.isVerified = true,
  });

  String get formattedPrice => '₹ ${price.toStringAsFixed(0)}';
}
