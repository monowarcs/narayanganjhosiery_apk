/// Product model — Dart mirror of js/products.js structure.
class Product {
  final int id;
  final String name;
  final String nameEn;
  final String category; // men | women | children | hosiery
  final String subcategory;
  final double dozenPrice; // price per dozen (BDT) — source of truth
  final double price; // display price (same as dozenPrice for dozen items)
  final double? oldPrice;
  final int? discount; // percent
  final String unitType; // dozen | piece
  final String retailUnitLabel; // "প্রতি ডজন"
  final int minimumOrderQuantity;
  final int availableStock;
  final String image;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final int stock; // duplicate of availableStock kept for compat
  final bool featured;
  final String? badge;

  const Product({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.subcategory,
    required this.dozenPrice,
    required this.price,
    this.oldPrice,
    this.discount,
    required this.unitType,
    required this.retailUnitLabel,
    required this.minimumOrderQuantity,
    required this.availableStock,
    required this.image,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.stock,
    required this.featured,
    this.badge,
  });

  /// Display price: dozenPrice if unitType dozen, else price.
  double get displayPrice => unitType == 'dozen' ? dozenPrice : price;

  /// Human unit label e.g. "৳4800 / প্রতি ডজন"
  String get unitLabel => retailUnitLabel;

  /// Search haystack lowercased.
  String get searchHaystack =>
      '$name $nameEn $category $subcategory $description'.toLowerCase();
}
