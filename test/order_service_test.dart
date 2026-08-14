import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:narayanganj_hosiery/services/order_service.dart';
import 'package:narayanganj_hosiery/models/order_payload.dart';

OrderPayload fakePayload() => OrderPayload(
      orderId: 'NH-260814-ABCDE',
      timestamp: DateTime.now().toIso8601String(),
      customerName: 'Test User',
      mobile: '01711483621',
      email: '',
      country: 'Bangladesh',
      division: 'Rajshahi',
      district: 'Pabna',
      address: 'Pabna College Rd',
      paymentMethod: 'cod',
      transactionId: '',
      items: const [
        OrderItemPayload(
          id: 1,
          name: 'প্রিমিয়াম কটন পাঞ্জাবি',
          category: 'men',
          subcategory: 'panjabi',
          qty: 1,
          quantity: 1,
          unitType: 'dozen',
          unitLabel: 'প্রতি ডজন',
          unitPrice: 4800,
          subtotal: 4800,
          size: 'L',
          color: 'সাদা',
        )
      ],
      subtotal: 4800,
      deliveryCharge: 80,
      total: 4880,
    );

void main() {
  test('submitOrder success parses response', () async {
    final client = MockClient((req) async {
      expect(req.headers['Content-Type'], contains('text/plain'));
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['orderId'], 'NH-260814-ABCDE');
      return http.Response(jsonEncode({'success': true, 'orderSaved': true, 'emailSent': true, 'orderId': 'NH-260814-ABCDE'}), 200);
    });
    final svc = OrderService(client: client);
    final res = await svc.submitOrder(fakePayload());
    expect(res.success, isTrue);
    expect(res.orderSaved, isTrue);
  });

  test('submitOrder treats orderSaved:true even if success:false as success', () async {
    final client = MockClient((_) async => http.Response(jsonEncode({'success': false, 'orderSaved': true, 'emailSent': false}), 200));
    final svc = OrderService(client: client);
    final res = await svc.submitOrder(fakePayload());
    expect(res.orderSaved, isTrue);
  });

  test('submitOrder throws on http error', () async {
    final client = MockClient((_) async => http.Response('oops', 500));
    final svc = OrderService(client: client);
    expect(() => svc.submitOrder(fakePayload()), throwsA(isA<OrderException>()));
  });
}
