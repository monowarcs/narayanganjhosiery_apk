import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartStorage {
  static const _key = 'nh_cart_v1';
  static const _lastOrderKey = 'nh_last_order';

  Future<List<CartItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> saveLastOrder(String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOrderKey, jsonStr);
  }

  Future<String?> loadLastOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOrderKey);
  }
}
