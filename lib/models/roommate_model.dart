class RoommateProfile {
  final String id;
  final String name;
  final int age;
  final String profession;
  final String budgetRange; // e.g. ₹5k-8k
  final String preferredLocation;
  final String city;
  final String lookingFor; // e.g. 1 Room in 2 BHK Flat
  final String avatarUrl;
  final String gender;
  final List<String> habits; // Non-Smoker, Veg, Pet Friendly
  final String about;
  final bool isVerified;
  final String phone;

  RoommateProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.profession,
    required this.budgetRange,
    required this.preferredLocation,
    this.city = 'Lucknow',
    required this.lookingFor,
    required this.avatarUrl,
    required this.gender,
    required this.habits,
    required this.about,
    this.isVerified = true,
    required this.phone,
  });

  factory RoommateProfile.fromJson(Map<String, dynamic> json) {
    List<String> tagsList = ['Non-Smoker', 'Quiet Space'];
    if (json['tags'] != null && json['tags'] is List) {
      tagsList = List<String>.from((json['tags'] as List).map((e) => e.toString()));
    } else if (json['habits'] != null && json['habits'] is List) {
      tagsList = List<String>.from((json['habits'] as List).map((e) => e.toString()));
    }

    final budgetVal = json['budget'] != null ? '₹ ${json['budget']}' : (json['budgetRange']?.toString() ?? '₹ 5,000');

    return RoommateProfile(
      id: json['customId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['userName']?.toString() ?? json['name']?.toString() ?? 'Roommate Seeker',
      age: (json['age'] is num) ? (json['age'] as num).toInt() : 24,
      profession: json['profession']?.toString() ?? 'Working Professional',
      budgetRange: budgetVal,
      preferredLocation: json['targetLocality']?.toString() ?? json['preferredLocation']?.toString() ?? 'Lucknow',
      city: json['city']?.toString() ?? 'Lucknow',
      lookingFor: json['lookingFor']?.toString() ?? 'Flatmate / Shared Room',
      avatarUrl: json['userAvatar']?.toString() ??
          json['avatarUrl']?.toString() ??
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      gender: json['gender']?.toString() ?? 'Male',
      habits: tagsList,
      about: json['bio']?.toString() ?? json['about']?.toString() ?? 'Looking for a flatmate in Lucknow.',
      isVerified: json['status'] == 'Active',
      phone: json['phone']?.toString() ?? '+91 98765 00000',
    );
  }

  Map<String, dynamic> toJson() {
    final cleanBudget = double.tryParse(budgetRange.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 5000.0;
    return {
      'customId': id,
      'userName': name,
      'phone': phone,
      'budget': cleanBudget,
      'gender': gender,
      'lookingFor': lookingFor,
      'targetLocality': preferredLocation,
      'city': city,
      'profession': profession,
      'bio': about,
      'tags': habits,
      'status': isVerified ? 'Active' : 'Suspended',
    };
  }
}
