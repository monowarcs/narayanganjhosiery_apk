import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../core/app_config.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../utils/helpers.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String selectedSize;
  late String selectedColor;
  int qty = 1;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizes.first;
    selectedColor = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final stock = p.availableStock;
    return Scaffold(
      appBar: AppBar(title: Text(p.name, style: const TextStyle(fontSize: 15)), backgroundColor: AppTheme.navy),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: p.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: const Color(0xFFF1F5F9), child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (_, __, ___) => Container(color: const Color(0xFFF1F5F9), child: const Center(child: Icon(Icons.checkroom_outlined, size: 48, color: Color(0xFF94A3B8)))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                    child: Text('${p.category} • ${p.subcategory}', style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  if (p.nameEn.isNotEmpty) Text(p.nameEn, style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
                  const SizedBox(height: 8),
                  const Row(children: [Text('★★★★★', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13)), SizedBox(width: 6), Text('(4.8 • 124 রিভিউ)', style: TextStyle(color: AppTheme.muted, fontSize: 12))]),
                  const SizedBox(height: 12),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Text('${AppConfig.currency}${formatBdt(p.displayPrice)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      if (p.oldPrice != null) Text('${AppConfig.currency}${formatBdt(p.oldPrice!)}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppTheme.muted)),
                      if (p.discount != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(999)), child: Text('-${p.discount}%', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800, fontSize: 12))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)), child: Text(p.retailUnitLabel, style: const TextStyle(fontSize: 11, color: AppTheme.muted))),
                    ],
                  ),
                  if (p.badge != null) ...[
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)), child: Text(p.badge!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)))),
                  ],
                  const SizedBox(height: 12),
                  Text(p.description, style: const TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 16),
                  // Sizes
                  const Text('সাইজ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.sizes.map((s) {
                      final active = s == selectedSize;
                      return ChoiceChip(
                        label: Text(s),
                        selected: active,
                        onSelected: (_) => setState(() => selectedSize = s),
                        selectedColor: AppTheme.navy,
                        labelStyle: TextStyle(color: active ? Colors.white : AppTheme.navy, fontWeight: FontWeight.w700, fontSize: 12),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('রঙ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: p.colors.map((c) {
                      final active = c == selectedColor;
                      return ChoiceChip(
                        label: Text(c),
                        selected: active,
                        onSelected: (_) => setState(() => selectedColor = c),
                        selectedColor: AppTheme.navy,
                        labelStyle: TextStyle(color: active ? Colors.white : AppTheme.navy, fontWeight: FontWeight.w700, fontSize: 12),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('পরিমাণ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 6),
                      Text('(${p.retailUnitLabel})', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      const Spacer(),
                      Text('স্টক: $stock', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(onPressed: qty > 1 ? () => setState(() => qty--) : null, icon: const Icon(Icons.remove), style: IconButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      IconButton(onPressed: qty < stock ? () => setState(() => qty++) : null, icon: const Icon(Icons.add), style: IconButton.styleFrom(side: const BorderSide(color: Color(0xFFE2E8F0)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final err = context.read<CartProvider>().addToCart(p, qty: qty, size: selectedSize, color: selectedColor);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err ?? 'কার্টে যোগ করা হয়েছে ✓ ($qty ${p.retailUnitLabel})'),
                          backgroundColor: err != null ? Colors.red : AppTheme.navy,
                        ));
                        if (err == null) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                      label: const Text('কার্টে যোগ করুন'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
