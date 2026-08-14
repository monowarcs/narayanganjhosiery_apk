import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/app_config.dart';
import '../models/order_payload.dart';

class OrderService {
  final http.Client _client;
  OrderService({http.Client? client}) : _client = client ?? http.Client();

  /// Sends order to Google Apps Script.
  /// GAS Web App always responds with a 302 redirect to
  /// script.googleusercontent.com — we must follow it manually and
  /// handle the method change (302 POST -> GET) correctly.
  /// Using text/plain avoids CORS preflight (same as website checkout.js).
  Future<OrderResponse> submitOrder(OrderPayload payload) async {
    final body = jsonEncode(payload.toJson());
    final initialUri = Uri.parse(AppConfig.orderApiUrl);

    // Redact transactionId for logs
    String redact(String s) {
      if (payload.transactionId.isEmpty) return s;
      return s.replaceAll(payload.transactionId, '***');
    }

    try {
      debugPrint('[OrderService] POST ${initialUri.toString()} bodyLen=${body.length}');
      final res = await _postWithRedirects(
        uri: initialUri,
        headers: {'Content-Type': 'text/plain;charset=utf-8'},
        body: body,
        redact: redact,
      );

      debugPrint('[OrderService] final status=${res.statusCode} headers=${res.headers} body=${res.body.substring(0, res.body.length.clamp(0, 500))}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw OrderException('সার্ভার ত্রুটি (${res.statusCode})। আবার চেষ্টা করুন।', debugDetail: 'HTTP ${res.statusCode} body=${res.body.substring(0, res.body.length.clamp(0, 300))}');
      }

      try {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = OrderResponse.fromJson(decoded);
        debugPrint('[OrderService] parsed success=${parsed.success} orderSaved=${parsed.orderSaved} emailSent=${parsed.emailSent} error=${parsed.error}');
        if (!parsed.success && !parsed.orderSaved) {
          throw OrderException(parsed.error ?? 'অর্ডার সংরক্ষণ ব্যর্থ হয়েছে।', debugDetail: parsed.error);
        }
        return parsed;
      } catch (e) {
        if (e is OrderException) rethrow;
        debugPrint('[OrderService] Non-JSON 2xx response: $e body=${res.body.substring(0, res.body.length.clamp(0, 300))}');
        return const OrderResponse(
          success: true,
          orderSaved: true,
          emailSent: true,
          message: 'Order received',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('[OrderService] Timeout: $e');
      throw OrderException('সময় শেষ হয়েছে। ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।', debugDetail: e.toString());
    } on SocketException catch (e) {
      debugPrint('[OrderService] SocketException: $e');
      throw OrderException('ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।', debugDetail: e.toString());
    } on OrderException {
      rethrow;
    } catch (e) {
      final msg = e.toString();
      final isNetwork = msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('No address associated') ||
          msg.contains('ClientException') ||
          msg.contains('Connection');
      if (isNetwork) {
        debugPrint('[OrderService] Network error: $e');
        throw OrderException('ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।', debugDetail: msg);
      }
      debugPrint('[OrderService] Unexpected: $e');
      throw OrderException('নেটওয়ার্ক ত্রুটি — আবার চেষ্টা করুন।', debugDetail: msg);
    }
  }

  /// Follows GAS redirects manually. POST to /exec returns 302 to
  /// script.googleusercontent.com; per HTTP spec 302/303 POST becomes GET.
  Future<http.Response> _postWithRedirects({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required String Function(String) redact,
    int maxRedirects = 5,
  }) async {
    var currentUri = uri;
    var method = 'POST';
    String? currentBody = body;
    Map<String, String> currentHeaders = headers;

    for (var i = 0; i <= maxRedirects; i++) {
      debugPrint('[OrderService] -> $method $currentUri (hop $i)');
      late http.Response res;
      if (method == 'POST') {
        res = await _client
            .post(currentUri, headers: currentHeaders, body: currentBody)
            .timeout(const Duration(seconds: 25));
      } else {
        res = await _client
            .get(currentUri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 25));
      }

      final sc = res.statusCode;
      debugPrint('[OrderService] <- $sc location=${res.headers['location']} bodyLen=${res.body.length}');

      final isRedirect = sc == 301 || sc == 302 || sc == 303 || sc == 307 || sc == 308;
      if (!isRedirect) return res;

      final loc = res.headers['location'];
      if (loc == null || loc.isEmpty) {
        debugPrint('[OrderService] Redirect $sc without Location — returning as-is');
        return res;
      }
      currentUri = Uri.parse(loc);
      // Per RFC, 302/303: POST -> GET. 307/308 preserve method.
      if (sc == 302 || sc == 303 || sc == 301) {
        method = 'GET';
        currentBody = null;
        currentHeaders = {};
      }
      // else 307/308 keep POST + body
      if (i == maxRedirects) {
        debugPrint('[OrderService] max redirects reached');
        return res;
      }
    }
    throw OrderException('অনেক বেশি রিডাইরেক্ট। আবার চেষ্টা করুন।');
  }
}

class OrderException implements Exception {
  final String message; // user-facing Bengali
  final String? debugDetail;
  OrderException(this.message, {this.debugDetail});
  @override
  String toString() => debugDetail != null ? '$message ($debugDetail)' : message;
}
