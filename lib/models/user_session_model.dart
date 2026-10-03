import 'dart:io';

/// UserSession — stores authenticated user data after successful OTP login.
/// This is the single source of truth for the currently logged-in user.
class UserSession {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String role;
  final String profileImage;
  final String city;
  final String locality;
  final String token;

  const UserSession({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.role,
    required this.profileImage,
    required this.city,
    required this.locality,
    required this.token,
  });

  /// Create from backend JSON response
  factory UserSession.fromJson(Map<String, dynamic> json, {String token = ''}) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return UserSession(
      id: user['id']?.toString() ??
          user['customId']?.toString() ??
          user['_id']?.toString() ??
          '',
      name: user['name']?.toString() ?? 'User',
      mobile: user['mobile']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      role: user['role']?.toString() ?? 'Tenant',
      profileImage: user['profileImage']?.toString() ?? '',
      city: user['city']?.toString() ?? 'Lucknow',
      locality: user['locality']?.toString() ?? 'Gomti Nagar',
      token: json['token']?.toString() ?? token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'email': email,
        'role': role,
        'profileImage': profileImage,
        'city': city,
        'locality': locality,
        'token': token,
      };

  /// Create an updated copy with changed fields
  UserSession copyWith({
    String? name,
    String? mobile,
    String? email,
    String? role,
    String? city,
    String? locality,
    String? profileImage,
    String? token,
  }) {
    return UserSession(
      id: id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      token: token ?? this.token,
    );
  }

  /// Display name (first name or full)
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.first;
  }

  /// Formatted phone
  String get formattedPhone => '+91 ${mobile.replaceAllMapped(
        RegExp(r'^(\d{5})(\d{5})$'),
        (m) => '${m[1]} ${m[2]}',
      )}';

  /// Whether profile image is set (local file path, data URI, or remote URL)
  bool get hasProfileImage {
    final p = profileImage.trim();
    if (p.isEmpty) return false;
    // If it's a local file path, verify it actually exists on disk
    if (!p.startsWith('http://') &&
        !p.startsWith('https://') &&
        !p.startsWith('data:') &&
        !p.startsWith('assets/')) {
      try {
        return File(p).existsSync();
      } catch (_) {
        return false;
      }
    }
    return true;
  }
}
