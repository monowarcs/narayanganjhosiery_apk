import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_config.dart';
import '../core/bd_locations.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../services/product_data.dart';
import '../services/order_service.dart';
import '../services/cart_storage.dart';
import '../models/order_payload.dart';
import '../utils/helpers.dart';

class CheckoutScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const CheckoutScreen({super.key, required this.onSuccess});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _txnCtrl = TextEditingController();

  String? _division;
  String? _district;
  String _payment = 'cod'; // cod | bkash | nagad
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _txnCtrl.dispose();
    super.dispose();
  }

  List<String> get _districts =>
      _division == null ? [] : (bdLocations[_division!] ?? []);

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কার্ট খালি — পণ্য যোগ করুন'), backgroundColor: Colors.red));
      return;
    }
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অনুগ্রহ করে লাল চিহ্নিত ফিল্ডগুলো ঠিক করুন'), backgroundColor: Colors.red));
      return;
    }
    if (_division == null || _district == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বিভাগ ও জেলা নির্বাচন করুন'), backgroundColor: Colors.red));
      return;
    }
    if ((_payment == 'bkash' || _payment == 'nagad') && _txnCtrl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction ID আবশ্যক'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _submitting = true);

    final subtotal = cart.subtotal;
    final delivery = AppConfig.deliveryFor(subtotal.toInt()).toDouble();
    final total = subtotal + delivery;

    final payload = OrderPayload(
      orderId: generateOrderId(),
      timestamp: DateTime.now().toIso8601String(),
      customerName: _nameCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      country: 'Bangladesh',
      division: _division!,
      district: _district!,
      address: _addressCtrl.text.trim(),
      paymentMethod: _payment,
      transactionId: _txnCtrl.text.trim(),
      items: cart.items.map((it) {
        final p = findProduct(it.id);
        final unitPrice = p?.displayPrice ?? it.unitPrice;
        return OrderItemPayload(
          id: it.id,
          name: it.name,
          category: p?.category ?? '',
          subcategory: p?.subcategory ?? '',
          qty: it.qty,
          quantity: it.qty,
          unitType: p?.unitType ?? 'dozen',
          unitLabel: it.unitLabel,
          unitPrice: unitPrice,
          subtotal: unitPrice * it.qty,
          size: it.size,
          color: it.color,
        );
      }).toList(),
      subtotal: subtotal,
      deliveryCharge: delivery,
      total: total,
    );

    try {
      final svc = OrderService();
      await svc.submitOrder(payload);
      // Success — persist last order, clear cart
      final storage = CartStorage();
      await storage.saveLastOrder(jsonEncode(payload.toJson()));
      await cart.clearAfterOrder();
      if (!mounted) return;
      // Navigate to success — use widget callback then show success inline
      // For now show dialog then call onSuccess
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অর্ডার সফলভাবে পাঠানো হয়েছে ✓'), backgroundColor: Colors.green));
      widget.onSuccess();
      // Also push success route with payload
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderSuccessScreen(payload: payload)));
    } on OrderException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('অর্ডার পাঠানো যায়নি — ${e.message}'), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('নেটওয়ার্ক ত্রুটি — আবার চেষ্টা করুন'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('চেকআউট'), backgroundColor: AppTheme.navy),
      body: cart.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🛒', style: TextStyle(fontSize: 40)),
                const Text('কার্ট খালি'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => Navigator.pop(context), child: const Text('পণ্য দেখুন')),
              ]),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('অর্ডার সামারি', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        ...cart.items.map((it) {
                          final p = findProduct(it.id);
                          final price = p?.displayPrice ?? it.unitPrice;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('${it.name} × ${it.qty}', style: const TextStyle(fontSize: 12))),
                                Text('${AppConfig.currency}${formatBdt(price * it.qty)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        _SummaryRow(label: 'সাবটোটাল', value: '${AppConfig.currency}${formatBdt(cart.subtotal)}'),
                        _SummaryRow(label: 'ডেলিভারি', value: cart.delivery == 0 ? 'ফ্রি' : '${AppConfig.currency}${formatBdt(cart.delivery)}'),
                        const Divider(),
                        _SummaryRow(label: 'মোট', value: '${AppConfig.currency}${formatBdt(cart.total)}', bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Customer fields
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'আপনার নাম *', hintText: 'পুরো নাম লিখুন'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'নাম লিখুন (কমপক্ষে ২ অক্ষর)' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'মোবাইল নম্বর *', hintText: '01XXXXXXXXX'),
                    validator: (v) => (v == null || !isValidBangladeshiMobile(v)) ? 'সঠিক মোবাইল নম্বর দিন (01XXXXXXXXX)' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'ইমেইল (ঐচ্ছিক)', hintText: 'example@mail.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return isValidEmail(v) ? null : 'সঠিক ইমেইল দিন';
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _division,
                    decoration: const InputDecoration(labelText: 'বিভাগ *'),
                    items: bdLocations.keys.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() {
                      _division = v;
                      _district = null;
                    }),
                    validator: (v) => v == null ? 'বিভাগ নির্বাচন করুন' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _district,
                    decoration: const InputDecoration(labelText: 'জেলা *'),
                    items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: _division == null ? null : (v) => setState(() => _district = v),
                    validator: (v) => v == null ? 'জেলা নির্বাচন করুন' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'বিস্তারিত ঠিকানা *', hintText: 'বাসা/রোড, এলাকা, থানা...'),
                    validator: (v) => (v == null || v.trim().length < 6) ? 'বিস্তারিত ঠিকানা লিখুন' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('পেমেন্ট পদ্ধতি', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _PayOption(
                    label: 'Cash on Delivery',
                    subtitle: 'পণ্য হাতে পাওয়ার পর টাকা পরিশোধ করুন।',
                    value: 'cod',
                    group: _payment,
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
                  _PayOption(
                    label: 'bKash — ${AppConfig.bkashNumber}',
                    subtitle: 'bKash Send Money — ${AppConfig.bkashNumber} নম্বরে Send Money করার পর Transaction ID দিন।',
                    value: 'bkash',
                    group: _payment,
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
                  _PayOption(
                    label: 'Nagad — ${AppConfig.nagadNumber}',
                    subtitle: 'Nagad Send Money — ${AppConfig.nagadNumber} নম্বরে Send Money করার পর Transaction ID দিন।',
                    value: 'nagad',
                    group: _payment,
                    onChanged: (v) => setState(() => _payment = v!),
                  ),
                  if (_payment == 'bkash' || _payment == 'nagad') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _txnCtrl,
                      decoration: InputDecoration(labelText: 'Transaction ID *', hintText: 'TRX ID লিখুন'),
                      validator: (v) {
                        if (_payment == 'cod') return null;
                        return (v == null || v.trim().length < 4) ? 'Transaction ID আবশ্যক' : null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _submitting
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('অর্ডার কনফার্ম করুন'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _SummaryRow({required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: bold ? AppTheme.navy : AppTheme.muted, fontSize: bold ? 14 : 12)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 14 : 12)),
        ]),
      );
}

class _PayOption extends StatelessWidget {
  final String label, subtitle, value, group;
  final ValueChanged<String?> onChanged;
  const _PayOption({required this.label, required this.subtitle, required this.value, required this.group, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final active = value == group;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? AppTheme.navy : const Color(0xFFE2E8F0), width: active ? 1.5 : 1),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: group,
        onChanged: onChanged,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        activeColor: AppTheme.navy,
      ),
    );
  }
}

class OrderSuccessScreen extends StatelessWidget {
  final OrderPayload payload;
  const OrderSuccessScreen({super.key, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('অর্ডার সফল'), backgroundColor: AppTheme.navy, automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(16)),
            child: const Column(children: [
              Text('✓', style: TextStyle(fontSize: 40, color: Color(0xFF166534))),
              SizedBox(height: 8),
              Text('অর্ডার সফল হয়েছে!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF166534))),
              SizedBox(height: 4),
              Text('আমরা শীঘ্রই যোগাযোগ করব', style: TextStyle(color: Color(0xFF166534))),
            ]),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Order ID', value: payload.orderId, mono: true),
          _InfoRow(label: 'নাম', value: payload.customerName),
          _InfoRow(label: 'মোট', value: '${AppConfig.currency}${formatBdt(payload.total)}', bold: true),
          _InfoRow(label: 'পেমেন্ট', value: payload.paymentMethod.toUpperCase()),
          _InfoRow(label: 'জেলা', value: payload.district),
          const SizedBox(height: 24),
          FilledButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('হোমে ফিরুন')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('আরও কেনাকাটা করুন')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool mono, bold;
  const _InfoRow({required this.label, required this.value, this.mono = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontFamily: mono ? 'monospace' : null)),
        ]),
      );
}
