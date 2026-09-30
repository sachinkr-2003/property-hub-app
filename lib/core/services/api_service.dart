import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/property_model.dart';

class ApiService {
  // Configurable base URL for Android Emulator, iOS Simulator, and Web
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  // Common Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Fetch all active properties from MongoDB
  static Future<List<Property>> fetchProperties({String? status, String? type, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (type != null && type.isNotEmpty && type != 'All') queryParams['type'] = type;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/properties').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      debugPrint('[ApiService] Fetching: $uri');
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
      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'mobile': mobile,
          if (otp != null) 'otp': otp,
        }),
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
}
