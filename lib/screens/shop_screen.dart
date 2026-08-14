import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../core/theme.dart';

class ShopScreen extends StatelessWidget {
  final void Function(int id) onOpenProduct;
  const ShopScreen({super.key, required this.onOpenProduct});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final filtered = shop.filtered;
    final cats = ['all', 'men', 'women', 'children', 'hosiery'];
    final catLabels = {'all': 'সব', 'men': 'Men', 'women': 'Women', 'children': 'Children', 'hosiery': 'Hosiery'};

    return Column(
      children: [
        // Search + sort
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: shop.search)
                    ..selection = TextSelection.collapsed(offset: shop.search.length),
                  onChanged: (v) => context.read<ShopProvider>().setSearch(v),
                  decoration: InputDecoration(
                    hintText: 'খুঁজুন...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    suffixIcon: shop.search.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => context.read<ShopProvider>().setSearch(''))
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<SortOption>(
                value: shop.sort,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: SortOption.featured, child: Text('Featured', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: SortOption.priceAsc, child: Text('Price ↑', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: SortOption.priceDesc, child: Text('Price ↓', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: SortOption.newest, child: Text('Newest', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (v) { if (v != null) context.read<ShopProvider>().setSort(v); },
              ),
            ],
          ),
        ),
        // Category chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = cats[i];
              final active = shop.category == c;
              return ChoiceChip(
                label: Text(catLabels[c]!),
                selected: active,
                onSelected: (_) => context.read<ShopProvider>().setCategory(c),
                selectedColor: AppTheme.navy,
                labelStyle: TextStyle(color: active ? Colors.white : AppTheme.navy, fontWeight: FontWeight.w700, fontSize: 12),
              );
            },
          ),
        ),
        // Subcategory chips
        if (shop.subcategories.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: shop.subcategories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = i == 0 ? 'সব' : shop.subcategories[i - 1];
                final val = i == 0 ? 'all' : shop.subcategories[i - 1];
                final active = shop.subcategory == val;
                return ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  selected: active,
                  onSelected: (_) => context.read<ShopProvider>().setSubcategory(val),
                  selectedColor: AppTheme.navy,
                  labelStyle: TextStyle(color: active ? Colors.white : AppTheme.muted, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ],
        // Count + clear
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text('${filtered.length} টি পণ্য', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.muted)),
              const Spacer(),
              if (shop.category != 'all' || shop.subcategory != 'all' || shop.search.isNotEmpty)
                TextButton(onPressed: () => context.read<ShopProvider>().clearFilters(), child: const Text('Clear filters', style: TextStyle(fontSize: 12))),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🛍️', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('কোন পণ্য পাওয়া যায়নি', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('অন্য ক্যাটাগরি বা সার্চ চেষ্টা করুন', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return ProductCard(
                      product: p,
                      onTap: () => onOpenProduct(p.id),
                      onAddToCart: () {
                        final err =
                            context.read<CartProvider>().addToCart(p, size: p.sizes.first, color: p.colors.first);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err ?? 'কার্টে যোগ করা হয়েছে ✓'),
                          backgroundColor: err != null ? Colors.red : AppTheme.navy,
                        ));
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
