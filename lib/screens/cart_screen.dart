import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cart_provider.dart';
import '../services/product_data.dart';
import '../core/app_config.dart';
import '../core/theme.dart';
import '../utils/helpers.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback onCheckout;
  final VoidCallback onGoShop;
  const CartScreen({super.key, required this.onCheckout, required this.onGoShop});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('কার্ট খালি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Text('পণ্য যোগ করুন এবং চেকআউট করুন', style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 16),
              FilledButton(onPressed: onGoShop, child: const Text('পণ্য দেখুন')),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final it = cart.items[i];
              final p = findProduct(it.id);
              final price = p?.displayPrice ?? it.unitPrice;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Builder(builder: (_) {
                        final img = it.image.isNotEmpty ? it.image : (p?.image ?? '');
                        if (img.isEmpty) {
                          return Container(width: 56, height: 56, color: const Color(0xFFF1F5F9), child: const Icon(Icons.checkroom_outlined, color: Color(0xFF94A3B8)));
                        }
                        return CachedNetworkImage(
                          imageUrl: img,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(width: 56, height: 56, color: const Color(0xFFF1F5F9), child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => Container(width: 56, height: 56, color: const Color(0xFFF1F5F9), child: const Icon(Icons.checkroom_outlined, color: Color(0xFF94A3B8))),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('${it.unitLabel} • ${AppConfig.currency}${formatBdt(price)}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                          if (it.size != null) Text('Size: ${it.size}${it.color != null ? ' • ${it.color}' : ''}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _QtyBtn(icon: Icons.remove, onTap: () {
                                final err = context.read<CartProvider>().updateQty(i, -1);
                                if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                              }),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w800))),
                              _QtyBtn(icon: Icons.add, onTap: () {
                                final err = context.read<CartProvider>().updateQty(i, 1);
                                if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                              }),
                              const SizedBox(width: 12),
                              Text('${AppConfig.currency}${formatBdt(price * it.qty)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => context.read<CartProvider>().removeAt(i)),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: [
              _Row(label: 'সাবটোটাল', value: '${AppConfig.currency}${formatBdt(cart.subtotal)}'),
              const SizedBox(height: 6),
              _Row(label: 'ডেলিভারি', value: cart.delivery == 0 ? 'ফ্রি' : '${AppConfig.currency}${formatBdt(cart.delivery)}', valueColor: cart.delivery == 0 ? Colors.green : null),
              const Divider(height: 20),
              _Row(label: 'মোট', value: '${AppConfig.currency}${formatBdt(cart.total)}', bold: true),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: FilledButton(onPressed: onCheckout, child: const Text('ডেলিভারি কনফার্ম করুন →'))),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => context.read<CartProvider>().clear(), child: const Text('কার্ট খালি করুন'))),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14),
        ),
      );
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.bold = false, this.valueColor});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 15 : 13, color: bold ? AppTheme.navy : AppTheme.muted)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 15 : 13, color: valueColor ?? (bold ? AppTheme.navy : null))),
        ],
      );
}
