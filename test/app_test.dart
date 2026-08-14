import 'package:flutter_test/flutter_test.dart';
import 'package:narayanganj_hosiery/utils/helpers.dart';
import 'package:narayanganj_hosiery/core/app_config.dart';
import 'package:narayanganj_hosiery/services/product_data.dart';

void main() {
  group('Order ID', () {
    test('generates NH-YYMMDD-XXXXX format', () {
      final id = generateOrderId();
      expect(RegExp(r'^NH-\d{6}-[A-Z0-9]{5}$').hasMatch(id), isTrue);
    });
    test('is unique across 100 calls', () {
      final ids = List.generate(100, (_) => generateOrderId()).toSet();
      expect(ids.length, greaterThan(95));
    });
  });

  group('Bangladeshi mobile validation', () {
    test('valid numbers', () {
      expect(isValidBangladeshiMobile('01711483621'), isTrue);
      expect(isValidBangladeshiMobile('01812345678'), isTrue);
      expect(isValidBangladeshiMobile('01999888777'), isTrue);
    });
    test('invalid numbers', () {
      expect(isValidBangladeshiMobile('01211483621'), isFalse); // 2 not allowed second digit
      expect(isValidBangladeshiMobile('0171148362'), isFalse); // too short
      expect(isValidBangladeshiMobile('017114836211'), isFalse); // too long
      expect(isValidBangladeshiMobile(''), isFalse);
    });
  });

  group('Delivery charge', () {
    test('free at threshold', () {
      expect(AppConfig.deliveryFor(5000), 0);
      expect(AppConfig.deliveryFor(6000), 0);
    });
    test('charged below threshold', () {
      expect(AppConfig.deliveryFor(4999), AppConfig.deliveryCharge);
      expect(AppConfig.deliveryFor(0), AppConfig.deliveryCharge);
    });
  });

  group('Product data integrity', () {
    test('24 products present', () => expect(kProducts.length, 24));
    test('all have required fields', () {
      for (final p in kProducts) {
        expect(p.name.isNotEmpty, isTrue, reason: 'product ${p.id} name empty');
        expect(p.displayPrice > 0, isTrue, reason: 'product ${p.id} price');
        expect(p.availableStock > 0, isTrue);
        expect(p.sizes.isNotEmpty, isTrue);
        expect(p.colors.isNotEmpty, isTrue);
      }
    });
    test('featured subset exists', () {
      expect(kProducts.where((p) => p.featured).length, greaterThan(5));
    });
    test('search haystack contains category', () {
      final p = kProducts.first;
      expect(p.searchHaystack.contains(p.category), isTrue);
    });
  });

  group('formatBdt', () {
    test('formats with commas', () {
      expect(formatBdt(4800), '4,800');
      expect(formatBdt(1200), '1,200');
      expect(formatBdt(80), '80');
    });
  });

  group('Email validation', () {
    test('valid', () => expect(isValidEmail('a@b.com'), isTrue));
    test('invalid', () => expect(isValidEmail('not-an-email'), isFalse));
    test('empty optional is handled by caller', () => expect(isValidEmail(''), isFalse));
  });
}
