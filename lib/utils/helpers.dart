import 'dart:math';

/// NH-YYMMDD-XXXXX — matches js generateOrderId().
String generateOrderId() {
  final now = DateTime.now();
  final yy = (now.year % 100).toString().padLeft(2, '0');
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random();
  final suffix = List.generate(5, (_) => chars[rnd.nextInt(chars.length)]).join();
  return 'NH-$yy$mm$dd-$suffix';
}

bool isValidBangladeshiMobile(String s) =>
    RegExp(r'^01[3-9]\d{8}$').hasMatch(s.trim());

bool isValidEmail(String s) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s.trim());

String formatBdt(num n) {
  // en-BD style thousands separators, no decimals
  final s = n.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final pos = s.length - i;
    buf.write(s[i]);
    if (pos > 1 && pos % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

/// Filter products matching query across name/nameEn/category/subcategory/description.
bool matchesSearch(String haystack, String query) =>
    haystack.toLowerCase().contains(query.toLowerCase().trim());
