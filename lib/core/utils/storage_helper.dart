import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // String
  static Future<bool> setString(String key, String value) async {
    final prefs = await _prefs;
    return await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  // Bool
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _prefs;
    return await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  // Int
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _prefs;
    return await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _prefs;
    return prefs.getInt(key);
  }

  // Double
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _prefs;
    return await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _prefs;
    return prefs.getDouble(key);
  }

  // String List
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _prefs;
    return await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _prefs;
    return prefs.getStringList(key);
  }

  // Remove
  static Future<bool> remove(String key) async {
    final prefs = await _prefs;
    return await prefs.remove(key);
  }

  // Clear all
  static Future<bool> clear() async {
    final prefs = await _prefs;
    return await prefs.clear();
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }
}

