/// Central configuration — single source of truth.
/// Values copied verbatim from js/config.js (website source of truth).
library;

class AppConfig {
  // ── Google Apps Script ───────────────────────────────────────
  static const String orderApiUrl =
      'https://script.google.com/macros/s/AKfycbwxw0vCQUmtA1RkcQnYmHgPRFVstJWE89DIrNCWGjv9k3QefDpjchqfxYsWVgLrZJpQ/exec';

  // ── Delivery ─────────────────────────────────────────────────
  static const int deliveryCharge = 80; // BDT
  static const int freeDeliveryThreshold = 5000; // BDT

  // ── Payments ─────────────────────────────────────────────────
  static const String bkashNumber = '01711483621';
  static const String nagadNumber = '01711483621';

  // ── Business ─────────────────────────────────────────────────
  static const String businessNameBn = 'নারায়ণগঞ্জ হোসিয়ারি, পাবনা';
  static const String businessNameEn = 'Narayanganj Hosiery, Pabna';
  static const String owner = 'Md Belal Hossain';
  static const String phoneDisplay = '01711-483621';
  static const String phoneTel = '01711483621';
  static const String address = '264Q+Q52, Pabna College Rd, Pabna 6600';
  static const String mapsUrl = 'https://maps.app.goo.gl/VRsFene5daTmZyXH8';
  static const String mapsEmbedSrc =
      'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d6311.760970521538!2d89.2353981!3d24.0068616!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x39fe9bc9e6b237df%3A0x84a379d0333e56b1!2z4Kao4Ka-4Kaw4Ka-4Kav4Ka84Kaj4KaX4Kae4KeN4KacIOCmueCni-CmuOCmv-Cmr-CmvOCmvuCmsOCmvywg4Kaq4Ka-4Kas4Kao4Ka-!5e1!3m2!1sen!2sbd!4v1786591432416!5m2!1sen!2sbd';
  static const String facebookUrl =
      'https://www.facebook.com/md.belal.hossain.122481';
  static const String siteUrl =
      'https://yourusername.github.io/narayanganj-hosiery/';

  // ── Currency ─────────────────────────────────────────────────
  static const String currency = '৳';

  // ── Delivery calc helper ─────────────────────────────────────
  static int deliveryFor(int subtotal) =>
      subtotal >= freeDeliveryThreshold ? 0 : deliveryCharge;
}
