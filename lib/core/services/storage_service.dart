import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyIsLoggedIn    = 'is_logged_in';
  static const String _keyRole          = 'current_role';
  static const String _keyFavorites     = 'favorite_property_ids';
  static const String _keyUserPhone     = 'user_phone';
  static const String _keyUserName      = 'user_name';
  static const String _keyAuthToken     = 'auth_token';
  static const String _keyUserSession   = 'user_session_json';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ────────────────────────────────────────────────
  // Login & Session
  // ────────────────────────────────────────────────
  static Future<void> setLoggedIn(bool value) async {
    await init();
    await _prefs?.setBool(_keyIsLoggedIn, value);
  }

  static bool getLoggedIn({bool defaultValue = false}) {
    return _prefs?.getBool(_keyIsLoggedIn) ?? defaultValue;
  }

  // ────────────────────────────────────────────────
  // JWT Token
  // ────────────────────────────────────────────────
  static Future<void> setAuthToken(String token) async {
    await init();
    await _prefs?.setString(_keyAuthToken, token);
  }

  static String? getAuthToken() {
    return _prefs?.getString(_keyAuthToken);
  }

  // ────────────────────────────────────────────────
  // Full UserSession JSON
  // ────────────────────────────────────────────────
  static Future<void> saveUserSession(Map<String, dynamic> sessionJson) async {
    await init();
    await _prefs?.setString(_keyUserSession, json.encode(sessionJson));
  }

  static Map<String, dynamic>? getUserSession() {
    final raw = _prefs?.getString(_keyUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────────
  // Role (user or owner)
  // ────────────────────────────────────────────────
  static Future<void> setRole(String role) async {
    await init();
    await _prefs?.setString(_keyRole, role);
  }

  static String getRole({String defaultRole = 'user'}) {
    return _prefs?.getString(_keyRole) ?? defaultRole;
  }

  // ────────────────────────────────────────────────
  // Favorites
  // ────────────────────────────────────────────────
  static Future<void> saveFavorites(List<String> ids) async {
    await init();
    await _prefs?.setStringList(_keyFavorites, ids);
  }

  static List<String> getFavorites() {
    return _prefs?.getStringList(_keyFavorites) ?? [];
  }

  // ────────────────────────────────────────────────
  // Profile details (legacy — kept for backward compat)
  // ────────────────────────────────────────────────
  static Future<void> saveUserProfile(String name, String phone) async {
    await init();
    await _prefs?.setString(_keyUserName, name);
    await _prefs?.setString(_keyUserPhone, phone);
  }

  static String getUserName({String defaultName = 'User'}) {
    return _prefs?.getString(_keyUserName) ?? defaultName;
  }

  static String getUserPhone({String defaultPhone = ''}) {
    return _prefs?.getString(_keyUserPhone) ?? defaultPhone;
  }

  // ────────────────────────────────────────────────
  // Clear on logout (all session data)
  // ────────────────────────────────────────────────
  static Future<void> clearSession() async {
    await init();
    await _prefs?.remove(_keyIsLoggedIn);
    await _prefs?.remove(_keyRole);
    await _prefs?.remove(_keyAuthToken);
    await _prefs?.remove(_keyUserSession);
    await _prefs?.remove(_keyUserName);
    await _prefs?.remove(_keyUserPhone);
  }
}
