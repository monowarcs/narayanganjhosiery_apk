/// Single cart line — uniquely keyed by (id, size, color).
class CartItem {
  final int id;
  final String name;
  final String image;
  final String unitLabel;
  final double unitPrice; // snapshot at add-time but re-derived from product
  final int qty;
  final String? size;
  final String? color;

  const CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.unitLabel,
    required this.unitPrice,
    required this.qty,
    this.size,
    this.color,
  });

  CartItem copyWith({int? qty, String? size, String? color}) => CartItem(
        id: id,
        name: name,
        image: image,
        unitLabel: unitLabel,
        unitPrice: unitPrice,
        qty: qty ?? this.qty,
        size: size ?? this.size,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'unitLabel': unitLabel,
        'price': unitPrice,
        'qty': qty,
        'size': size,
        'color': color,
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        id: j['id'] as int,
        name: j['name'] as String,
        image: j['image'] as String? ?? '',
        unitLabel: j['unitLabel'] as String? ?? 'প্রতি ডজন',
        unitPrice: (j['price'] as num).toDouble(),
        qty: j['qty'] as int,
        size: j['size'] as String?,
        color: j['color'] as String?,
      );

  /// Identity key for dedup.
  String get key => '$id|${size ?? ''}|${color ?? ''}';
}
