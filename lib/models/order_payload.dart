/// Order payload — mirrors the JS payload sent to Google Apps Script.

class OrderItemPayload {
  final int id;
  final String name;
  final String category;
  final String subcategory;
  final int qty;
  final int quantity;
  final String unitType;
  final String unitLabel;
  final double unitPrice;
  final double subtotal;
  final String? size;
  final String? color;

  const OrderItemPayload({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.qty,
    required this.quantity,
    required this.unitType,
    required this.unitLabel,
    required this.unitPrice,
    required this.subtotal,
    this.size,
    this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'qty': qty,
        'quantity': quantity,
        'unitType': unitType,
        'unitLabel': unitLabel,
        'unitPrice': unitPrice,
        'subtotal': subtotal,
        'size': size,
        'color': color,
      };
}

class OrderPayload {
  final String orderId;
  final String timestamp; // ISO8601
  final String customerName;
  final String mobile;
  final String email;
  final String country;
  final String division;
  final String district;
  final String address;
  final String paymentMethod; // cod | bkash | nagad
  final String transactionId;
  final List<OrderItemPayload> items;
  final double subtotal;
  final double deliveryCharge;
  final double total;

  const OrderPayload({
    required this.orderId,
    required this.timestamp,
    required this.customerName,
    required this.mobile,
    required this.email,
    required this.country,
    required this.division,
    required this.district,
    required this.address,
    required this.paymentMethod,
    required this.transactionId,
    required this.items,
    required this.subtotal,
    required this.deliveryCharge,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'timestamp': timestamp,
        'customerName': customerName,
        'mobile': mobile,
        'email': email,
        'country': country,
        'division': division,
        'district': district,
        'address': address,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryCharge': deliveryCharge,
        'total': total,
      };
}

/// Response shape from Apps Script doPost.
class OrderResponse {
  final bool success;
  final bool orderSaved;
  final bool emailSent;
  final String? orderId;
  final String? error;
  final String? message;
  const OrderResponse({
    required this.success,
    required this.orderSaved,
    required this.emailSent,
    this.orderId,
    this.error,
    this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> j) => OrderResponse(
        success: j['success'] == true,
        orderSaved: j['orderSaved'] == true,
        emailSent: j['emailSent'] == true,
        orderId: j['orderId'] as String?,
        error: j['error'] as String?,
        message: j['message'] as String?,
      );
}
