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
}
