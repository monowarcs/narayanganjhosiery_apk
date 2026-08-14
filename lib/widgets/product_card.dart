import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_config.dart';
import '../models/product.dart';
import '../utils/helpers.dart';
import '../core/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(child: Icon(Icons.checkroom_outlined, size: 36, color: Color(0xFF94A3B8))),
                    ),
                  ),
                  if (product.discount != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('-${product.discount}%',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(product.badge!,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${product.category} • ${product.subcategory}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.muted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 4),
                  const Row(children: [
                    Text('★★★★★', style: TextStyle(fontSize: 10, color: Color(0xFFF59E0B))),
                    SizedBox(width: 4),
                    Text('(4.8)', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text('${AppConfig.currency}${formatBdt(product.displayPrice)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      if (product.oldPrice != null)
                        Text('${AppConfig.currency}${formatBdt(product.oldPrice!)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.muted, decoration: TextDecoration.lineThrough)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                        child: Text(product.retailUnitLabel, style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('স্টক: ${product.availableStock} • ${product.sizes.take(3).join(', ')}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('কার্টে যোগ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
