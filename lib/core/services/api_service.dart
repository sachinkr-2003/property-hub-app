import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/property_model.dart';
import '../../models/service_model.dart';
import '../../models/used_item_model.dart';
import '../../models/roommate_model.dart';
import '../../models/visit_booking_model.dart';
import '../../models/user_session_model.dart';
import '../../models/notification_item_model.dart';
import '../../models/chat_model.dart';

class ApiService {
  // Live Render Cloud Backend URL (and localhost fallback)
  static const String liveCloudUrl = 'https://property-hub-backend-j0ea.onrender.com';
  static const bool useLiveCloud = true;

  static String get serverRootUrl {
    if (useLiveCloud) {
      return liveCloudUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://localhost:5000';
  }

  static String get baseUrl => '$serverRootUrl/api';

  // Common Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with Bearer token for authenticated requests
  static Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ==========================================
  // AUTH — OTP Login & Registration
  // ==========================================

  /// Step 1: Send OTP to mobile
  static Future<Map<String, dynamic>?> sendOtp(String mobile) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/send-otp'),
            headers: _headers,
            body: json.encode({'mobile': mobile}),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 200 && decoded['success'] == true) {
        return decoded['data'] as Map<String, dynamic>?;
      }
      debugPrint('[Auth] sendOtp failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] sendOtp error: $e');
    }
    return null;
  }

  /// Step 2: Verify OTP → returns UserSession on success
  static Future<UserSession?> verifyOtp({
    required String mobile,
    required String otp,
    String? name,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'mobile': mobile,
        'otp': otp,
        'name': ?name,
        'role': ?role,
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          decoded['success'] == true) {
        return UserSession.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      debugPrint('[Auth] verifyOtp failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] verifyOtp error: $e');
    }
    return null;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// Email OTP Login
  /// ──────────────────────────────────────────────────────────────────────────

  /// Send Email OTP
  static Future<Map<String, dynamic>?> sendEmailOtp(String email) async {
    try {
      final body = <String, dynamic>{'email': email};
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/send-email-otp'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 200 && decoded['success'] == true) {
        return decoded['data'] as Map<String, dynamic>?;
      }
      debugPrint('[Auth] sendEmailOtp failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] sendEmailOtp error: $e');
    }
    return null;
  }

  /// Verify Email OTP → returns UserSession on success
  static Future<UserSession?> verifyEmailOtp({
    required String email,
    required String otp,
    String? name,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'otp': otp,
        'name': ?name,
        'role': ?role,
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-email-otp'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 200 && decoded['success'] == true) {
        return UserSession.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      debugPrint('[Auth] verifyEmailOtp failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] verifyEmailOtp error: $e');
    }
    return null;
  }

  /// ──────────────────────────────────────────────────────────────────────────
  /// Other Logins
  /// ──────────────────────────────────────────────────────────────────────────

  /// Google Login (Real) → returns UserSession on success
  static Future<UserSession?> googleLogin({
    required String idToken,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'idToken': idToken,
        'role': ?role,
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/google-login'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          decoded['success'] == true) {
        return UserSession.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      debugPrint('[Auth] googleLogin failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] googleLogin error: $e');
    }
    return null;
  }

  /// Email Login
  static Future<UserSession?> emailLogin({
    required String email,
    required String password,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login-email'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 200 && decoded['success'] == true) {
        return UserSession.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      debugPrint('[Auth] emailLogin failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] emailLogin error: $e');
    }
    return null;
  }

  /// Email Register
  static Future<UserSession?> emailRegister({
    required String email,
    required String password,
    required String name,
    required String mobile,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'name': name,
        'mobile': mobile,
        'role': ?role,
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/register-email'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 201 && decoded['success'] == true) {
        return UserSession.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      debugPrint('[Auth] emailRegister failed: ${decoded['message']}');
    } catch (e) {
      debugPrint('[Auth] emailRegister error: $e');
    }
    return null;
  }

  /// Fetch current user profile using stored token
  static Future<UserSession?> getMe(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: _authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = json.decode(res.body);
      if (res.statusCode == 200 && decoded['success'] == true) {
        return UserSession.fromJson(
          {'user': decoded['data']},
          token: token,
        );
      }
    } catch (e) {
      debugPrint('[Auth] getMe error: $e');
    }
    return null;
  }

  /// Update profile fields
  static Future<bool> updateProfile({
    required String token,
    String? name,
    String? city,
    String? locality,
    String? profileImage,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': ?name,
        'city': ?city,
        'locality': ?locality,
        'profileImage': ?profileImage,
      };
      final res = await http
          .patch(
            Uri.parse('$baseUrl/auth/profile'),
            headers: _authHeaders(token),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[Auth] updateProfile error: $e');
    }
    return false;
  }

  static String resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$serverRootUrl$trimmed';
    }
    return '$serverRootUrl/$trimmed';
  }

  // ==========================================
  // MULTIPART DOCUMENT & IMAGE UPLOADS
  // ==========================================

  static MediaType _getMediaType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// Upload single general media file (selfie, chat media, avatar)
  static Future<String?> uploadSingleFile(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/upload/single');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: _getMediaType(filePath),
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return resolveMediaUrl(decoded['data']['url']?.toString());
        }
      }
    } catch (e) {
      debugPrint('[ApiService] uploadSingleFile error: $e');
    }
    return null;
  }

  /// Upload multiple property images
  static Future<List<String>> uploadPropertyImages(List<String> filePaths) async {
    if (filePaths.isEmpty) return [];
    try {
      final uri = Uri.parse('$baseUrl/upload/property-images');
      final request = http.MultipartRequest('POST', uri);
      for (final p in filePaths) {
        if (p.isNotEmpty && !p.startsWith('http')) {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            p,
            contentType: _getMediaType(p),
          ));
        }
      }

      if (request.files.isEmpty) {
        return filePaths;
      }

      final streamed = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data']?['images'] is List) {
          return (decoded['data']['images'] as List)
              .map((url) => resolveMediaUrl(url?.toString()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] uploadPropertyImages error: $e');
    }
    return [];
  }

  /// Upload Owner KYC Documents (Aadhaar & PAN)
  static Future<Map<String, String?>> uploadKycDocs({String? aadhaarPath, String? panPath}) async {
    final result = <String, String?>{'aadhaarUrl': null, 'panUrl': null};
    try {
      final uri = Uri.parse('$baseUrl/upload/kyc-docs');
      final request = http.MultipartRequest('POST', uri);
      if (aadhaarPath != null && aadhaarPath.isNotEmpty && !aadhaarPath.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath(
          'aadhaar',
          aadhaarPath,
          contentType: _getMediaType(aadhaarPath),
        ));
      }
      if (panPath != null && panPath.isNotEmpty && !panPath.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath(
          'pan',
          panPath,
          contentType: _getMediaType(panPath),
        ));
      }

      if (request.files.isEmpty) return result;

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          result['aadhaarUrl'] = resolveMediaUrl(decoded['data']['aadhaarUrl']?.toString());
          result['panUrl'] = resolveMediaUrl(decoded['data']['panUrl']?.toString());
        }
      }
    } catch (e) {
      debugPrint('[ApiService] uploadKycDocs error: $e');
    }
    return result;
  }

  /// Upload Property Title Deed / Registry Document
  static Future<String?> uploadDeedDoc(String deedPath) async {
    if (deedPath.isEmpty || deedPath.startsWith('http')) return deedPath;
    try {
      final uri = Uri.parse('$baseUrl/upload/deed-doc');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'registry',
        deedPath,
        contentType: _getMediaType(deedPath),
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return resolveMediaUrl(decoded['data']['registryUrl']?.toString());
        }
      }
    } catch (e) {
      debugPrint('[ApiService] uploadDeedDoc error: $e');
    }
    return null;
  }

  // ==========================================
  // PROPERTIES API
  // ==========================================

  /// Fetch all active properties from MongoDB
  static Future<List<Property>> fetchProperties({String? status, String? type, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (type != null && type.isNotEmpty && type != 'All') queryParams['type'] = type;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/properties').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((item) => Property.fromJson(item as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchProperties warning: $e (Falling back to local cache)');
    }
    return [];
  }

  /// Create new property listing in MongoDB
  static Future<Property?> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final uri = Uri.parse('$baseUrl/properties');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(propertyData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return Property.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createProperty warning: $e');
    }
    return null;
  }

  // ==========================================
  // BACHELOR SERVICES API
  // ==========================================

  /// Fetch all services from MongoDB
  static Future<List<BachelorService>> fetchServices() async {
    try {
      final uri = Uri.parse('$baseUrl/services');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => BachelorService.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchServices warning: $e');
    }
    return [];
  }

  // ==========================================
  // USED ITEMS (MARKETPLACE) API
  // ==========================================

  /// Fetch used marketplace items from MongoDB
  static Future<List<UsedItem>> fetchUsedItems({String? category, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/used-items').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => UsedItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchUsedItems warning: $e');
    }
    return [];
  }

  /// Create new used item listing
  static Future<UsedItem?> createUsedItem(Map<String, dynamic> itemData) async {
    try {
      final uri = Uri.parse('$baseUrl/used-items');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(itemData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return UsedItem.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createUsedItem warning: $e');
    }
    return null;
  }

  // ==========================================
  // ROOMMATES API
  // ==========================================

  /// Fetch roommate seekers from MongoDB
  static Future<List<RoommateProfile>> fetchRoommates({String? gender, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (gender != null && gender.isNotEmpty && gender != 'All') queryParams['gender'] = gender;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/roommates').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => RoommateProfile.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchRoommates warning: $e');
    }
    return [];
  }

  /// Create roommate post
  static Future<RoommateProfile?> createRoommate(Map<String, dynamic> roommateData) async {
    try {
      final uri = Uri.parse('$baseUrl/roommates');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(roommateData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return RoommateProfile.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createRoommate warning: $e');
    }
    return null;
  }

  // ==========================================
  // SITE VISITS & LEADS API
  // ==========================================

  /// Fetch site visits from MongoDB
  static Future<List<VisitBooking>> fetchVisits({String? status, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty && status != 'All') queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/visits').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((item) => VisitBooking.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchVisits warning: $e');
    }
    return [];
  }

  /// Create new visit booking in MongoDB
  static Future<VisitBooking?> createVisit(Map<String, dynamic> visitData) async {
    try {
      final uri = Uri.parse('$baseUrl/visits');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(visitData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return VisitBooking.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createVisit warning: $e');
    }
    return null;
  }

  // ==========================================
  // OWNER KYC & AUTH API
  // ==========================================

  /// Submit Owner KYC Dossier
  static Future<bool> submitKyc({
    required String ownerName,
    required String mobile,
    required String email,
    required String aadhaarNumber,
    required String panNumber,
    required String registryDetails,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/kyc/submit');
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'name': ownerName,
          'mobile': mobile,
          'email': email,
          'aadhaar': aadhaarNumber,
          'pan': panNumber,
          'registry': registryDetails,
        }),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[ApiService] submitKyc warning: $e');
      return false;
    }
  }

  /// Phone Login & OTP Verification
  static Future<Map<String, dynamic>?> phoneLogin(String mobile, [String? otp]) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/phone-login');
      final Map<String, dynamic> payload = {'mobile': mobile};
      if (otp != null && otp.isNotEmpty) {
        payload['otp'] = otp;
      }

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] phoneLogin warning: $e');
    }
    return null;
  }

  /// Fetch notifications from backend
  static Future<List<NotificationItem>> fetchNotifications({
    String? audience,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (audience != null) queryParams['targetAudience'] = audience;
      if (userId != null) queryParams['userId'] = userId;

      final uri = Uri.parse('$baseUrl/communication/notifications').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final list = decoded['data'] as List<dynamic>;
          return list.map((item) => NotificationItem.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchNotifications warning: $e');
    }
    return [];
  }

  /// Mark notification as read
  static Future<bool> markNotificationRead(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/communication/notifications/$id/read');
      final response = await http.patch(uri, headers: _headers).timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] markNotificationRead warning: $e');
      return false;
    }
  }

  /// Clear all notifications
  static Future<bool> clearAllNotifications() async {
    try {
      final uri = Uri.parse('$baseUrl/communication/notifications');
      final response = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] clearAllNotifications warning: $e');
      return false;
    }
  }

  /// Fetch all chat conversations
  static Future<List<ChatThread>> fetchConversations() async {
    try {
      final uri = Uri.parse('$baseUrl/communication/conversations');
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final list = decoded['data'] as List<dynamic>;
          return list.map((item) => ChatThread.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('[ApiService] fetchConversations warning: $e');
    }
    return [];
  }

  /// Create or find a conversation
  static Future<ChatThread?> createConversation({
    required String participantName,
    required String propertyTitle,
    String? avatarUrl,
    String? role,
    String? initialMessage,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/communication/conversations');
      final body = {
        'participantName': participantName,
        'propertyTitle': propertyTitle,
        'avatarUrl': ?avatarUrl,
        'role': ?role,
        'initialMessage': ?initialMessage,
      };
      final response = await http
          .post(uri, headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return ChatThread.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createConversation warning: $e');
    }
    return null;
  }

  /// Post message to conversation
  static Future<bool> sendChatMessage(String threadId, String text, {String? senderName}) async {
    try {
      final uri = Uri.parse('$baseUrl/communication/conversations/$threadId/messages');
      final body = {
        'text': text,
        'senderName': ?senderName,
        'isSender': true,
      };
      final response = await http
          .post(uri, headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[ApiService] sendChatMessage warning: $e');
      return false;
    }
  }

  /// Record payment transaction (Razorpay / Online)
  static Future<Map<String, dynamic>?> createTransaction({
    required String userName,
    required String purpose,
    required double amount,
    String userRole = 'Tenant',
    String gateway = 'Razorpay',
    String? paymentId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/finance/transactions');
      final body = {
        'userName': userName,
        'userRole': userRole,
        'purpose': purpose,
        'amount': amount,
        'gateway': gateway,
        'paymentId': paymentId ?? 'pay_rzp_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'Success',
      };
      final response = await http
          .post(uri, headers: _headers, body: json.encode(body))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] createTransaction warning: $e');
    }
    return null;
  }
}
