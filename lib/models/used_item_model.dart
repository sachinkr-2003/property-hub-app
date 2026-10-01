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

  factory UsedItem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return UsedItem(
      id: json['customId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Used Item',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      condition: json['condition']?.toString() ?? 'Good Condition',
      category: json['category']?.toString() ?? 'Furniture',
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString() ?? '',
      location: json['locality']?.toString() ?? json['location']?.toString() ?? 'Lucknow',
      sellerName: json['sellerName']?.toString() ?? 'Verified Seller',
      sellerPhone: json['phone']?.toString() ?? json['sellerPhone']?.toString() ?? '+91 98765 00000',
      description: json['description']?.toString() ?? 'Well maintained item for immediate sale.',
      postedAt: parsedDate,
      isVerified: !(json['reported'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customId': id,
      'title': title,
      'price': price,
      'condition': condition,
      'category': category,
      'image': imageUrl,
      'locality': location,
      'sellerName': sellerName,
      'phone': sellerPhone,
      'description': description,
    };
  }
}
