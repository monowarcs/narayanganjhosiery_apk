import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_storage.dart';
import '../services/product_data.dart';
import '../core/app_config.dart';

class CartProvider extends ChangeNotifier {
  final CartStorage _storage;
  List<CartItem> _items = [];
  bool _loaded = false;

  CartProvider({CartStorage? storage}) : _storage = storage ?? CartStorage();

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;
  bool get isEmpty => _items.isEmpty;

  int get count => _items.fold(0, (s, e) => s + e.qty);

  /// Subtotal computed from current product prices (fallback to stored unitPrice).
  double get subtotal {
    double sum = 0;
    for (final it in _items) {
      final p = findProduct(it.id);
      final price = p?.displayPrice ?? it.unitPrice;
      sum += price * it.qty;
    }
    return sum;
  }

  int get delivery => AppConfig.deliveryFor(subtotal.toInt());
  double get total => subtotal + delivery;

  Future<void> load() async {
    _items = await _storage.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.save(_items);
    notifyListeners();
  }

  /// Adds product with size/color. Merges if same id+size+color exists.
  /// Returns err message if stock limit hit, else null.
  String? addToCart(Product p,
      {int qty = 1, String? size, String? color}) {
    final q = qty < 1 ? 1 : qty;
    final stock = p.availableStock;
    final idx = _items.indexWhere(
        (e) => e.id == p.id && e.size == size && e.color == color);
    if (idx >= 0) {
      final next = (_items[idx].qty + q).clamp(1, stock);
      if (next == _items[idx].qty) return 'স্টক সীমা পৌঁছে গেছে';
      _items[idx] = _items[idx].copyWith(qty: next);
    } else {
      final clamped = q.clamp(1, stock);
      _items.add(CartItem(
        id: p.id,
        name: p.name,
        image: p.image,
        unitLabel: p.retailUnitLabel,
        unitPrice: p.displayPrice,
        qty: clamped,
        size: size,
        color: color,
      ));
    }
    _persist();
    return null;
  }

  /// qty delta; removes if qty <=0.
  String? updateQty(int index, int delta) {
    if (index < 0 || index >= _items.length) return null;
    final p = findProduct(_items[index].id);
    final stock = p?.availableStock ?? 99;
    final next = _items[index].qty + delta;
    if (next <= 0) {
      _items.removeAt(index);
      _persist();
      return null;
    }
    if (next > stock) return 'স্টক সীমা: $stock';
    _items[index] = _items[index].copyWith(qty: next);
    _persist();
    return null;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    _persist();
  }

  Future<void> clear() async {
    _items = [];
    await _persist();
  }

  Future<void> clearAfterOrder() async {
    _items = [];
    await _storage.save(_items);
    notifyListeners();
  }
}
