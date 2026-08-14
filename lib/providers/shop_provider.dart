import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_data.dart';

enum SortOption { featured, priceAsc, priceDesc, newest }

class ShopProvider extends ChangeNotifier {
  String category = 'all'; // all | men | women | children | hosiery
  String subcategory = 'all';
  SortOption sort = SortOption.featured;
  String search = '';

  List<Product> get filtered {
    Iterable<Product> list = kProducts;
    if (category != 'all') list = list.where((p) => p.category == category);
    if (subcategory != 'all') {
      list = list.where((p) => p.subcategory == subcategory);
    }
    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((p) => p.searchHaystack.contains(q));
    }
    final out = list.toList();
    switch (sort) {
      case SortOption.priceAsc:
        out.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case SortOption.priceDesc:
        out.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
      case SortOption.newest:
        out.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.featured:
        out.sort((a, b) => (b.featured ? 1 : 0).compareTo(a.featured ? 1 : 0));
        break;
    }
    return out;
  }

  List<String> get subcategories {
    if (category == 'all') return [];
    return kProducts
        .where((p) => p.category == category)
        .map((p) => p.subcategory)
        .toSet()
        .toList();
  }

  void setCategory(String c) {
    category = c;
    subcategory = 'all';
    notifyListeners();
  }

  void setSubcategory(String s) {
    subcategory = s;
    notifyListeners();
  }

  void setSort(SortOption s) {
    sort = s;
    notifyListeners();
  }

  void setSearch(String q) {
    search = q;
    notifyListeners();
  }

  void clearFilters() {
    category = 'all';
    subcategory = 'all';
    sort = SortOption.featured;
    search = '';
    notifyListeners();
  }
}
