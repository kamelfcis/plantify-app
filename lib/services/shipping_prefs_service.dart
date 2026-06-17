import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to save and load shipping information from SharedPreferences.
class ShippingPrefsService {
  static const String _key = 'shipping_info';

  static final ShippingPrefsService _instance =
      ShippingPrefsService._internal();
  factory ShippingPrefsService() => _instance;
  static ShippingPrefsService get instance => _instance;

  ShippingPrefsService._internal();

  /// Save shipping info to SharedPreferences
  Future<void> saveShippingInfo(Map<String, dynamic> shippingInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(shippingInfo));
  }

  /// Load shipping info from SharedPreferences
  Future<Map<String, dynamic>?> loadShippingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clear shipping info
  Future<void> clearShippingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

