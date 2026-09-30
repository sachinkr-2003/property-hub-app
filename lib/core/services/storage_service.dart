import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRole = 'current_role';
  static const String _keyFavorites = 'favorite_property_ids';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserName = 'user_name';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Login & Session
  static Future<void> setLoggedIn(bool value) async {
    await init();
    await _prefs?.setBool(_keyIsLoggedIn, value);
  }

  static bool getLoggedIn({bool defaultValue = true}) {
    return _prefs?.getBool(_keyIsLoggedIn) ?? defaultValue;
  }

  // Role (user or owner)
  static Future<void> setRole(String role) async {
    await init();
    await _prefs?.setString(_keyRole, role);
  }

  static String getRole({String defaultRole = 'user'}) {
    return _prefs?.getString(_keyRole) ?? defaultRole;
  }

  // Favorites
  static Future<void> saveFavorites(List<String> ids) async {
    await init();
    await _prefs?.setStringList(_keyFavorites, ids);
  }

  static List<String> getFavorites() {
    return _prefs?.getStringList(_keyFavorites) ?? ['prop-1'];
  }

  // Profile details
  static Future<void> saveUserProfile(String name, String phone) async {
    await init();
    await _prefs?.setString(_keyUserName, name);
    await _prefs?.setString(_keyUserPhone, phone);
  }

  static String getUserName({String defaultName = 'Sachin Bhaskar'}) {
    return _prefs?.getString(_keyUserName) ?? defaultName;
  }

  static String getUserPhone({String defaultPhone = '+91 98765 43210'}) {
    return _prefs?.getString(_keyUserPhone) ?? defaultPhone;
  }

  // Clear on logout
  static Future<void> clearSession() async {
    await init();
    await _prefs?.remove(_keyIsLoggedIn);
    await _prefs?.remove(_keyRole);
  }
}
