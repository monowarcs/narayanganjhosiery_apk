import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/shop_provider.dart';
import '../services/product_data.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_card.dart';
import '../core/theme.dart';
import '../core/app_config.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoShop;
  final void Function(int id) onOpenProduct;
  final void Function(String cat, String sub) onFilterAndGoShop;
  const HomeScreen({
    super.key,
    required this.onGoShop,
    required this.onOpenProduct,
    required this.onFilterAndGoShop,
  });

  @override
  Widget build(BuildContext context) {
    final featured = kProducts.where((p) => p.featured).take(8).toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppTheme.navy,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/images/logo/app_icon_512.png', width: 34, height: 34, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/images/logo/logo_dark.svg', height: 20, fit: BoxFit.contain,
                      // fallback if svg fails: show text
                      placeholderBuilder: (_) => const Text('নারায়ণগঞ্জ হোসিয়ারি', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                    const Text('পাবনা • খুচরা ও পাইকারি', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Consumer<CartProvider>(builder: (_, cart, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      onPressed: onGoShop,
                    ),
                    if (cart.count > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(999)),
                          child: Text('${cart.count}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                onChanged: (v) {
                  context.read<ShopProvider>().setSearch(v);
                  if (v.trim().isNotEmpty) onGoShop();
                },
                decoration: InputDecoration(
                  hintText: 'পণ্য খুঁজুন... (নাম, ক্যাটাগরি)',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const HeroBanner(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ক্যাটাগরি', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    TextButton(onPressed: onGoShop, child: const Text('সব দেখুন →')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CategoryShortcuts(onSelect: onFilterAndGoShop),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ফিচার্ড পণ্য', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    TextButton(onPressed: onGoShop, child: const Text('সব পণ্য →')),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final p = featured[i];
                return ProductCard(
                  product: p,
                  onTap: () => onOpenProduct(p.id),
                  onAddToCart: () {
                    final err = ctx.read<CartProvider>().addToCart(p, size: p.sizes.first, color: p.colors.first);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? 'কার্টে যোগ করা হয়েছে ✓'),
                      backgroundColor: err != null ? Colors.red : AppTheme.navy,
                    ));
                  },
                );
              },
              childCount: featured.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('নারায়ণগঞ্জ হোসিয়ারি, পাবনা',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 6),
                const Text('মানসম্মত পোশাক ও হোসিয়ারি — এক ছাদের নিচে। খুচরা ও পাইকারি উভয় সুবিধা।',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text(AppConfig.address, style: const TextStyle(fontSize: 11))),
                    const Chip(label: Text('01711-483621', style: TextStyle(fontSize: 11))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
