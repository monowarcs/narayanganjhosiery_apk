# Narayanganj Hosiery — Flutter App

Official shopping app for **Narayanganj Hosiery, Pabna** (নারায়ণগঞ্জ হোসিয়ারি, পাবনা).

> Existing website remains untouched at the repository root (`index.html`, `shop.html`, `checkout.html`, `js/`, `css/`, `assets/`, `google-apps-script/`).
> This Flutter app lives in `flutter_app/` and reuses the site's product data, pricing, cart logic, and Google Apps Script order API.

## Project Structure

```
flutter_app/
  lib/
    main.dart
    core/
      app_config.dart      # ORDER_API_URL, delivery, bKash/Nagad numbers (from js/config.js)
      bd_locations.dart     # BD_LOCATIONS + heroSlides (from js/config.js)
      theme.dart
    models/
      product.dart
      cart_item.dart
      order_payload.dart
    services/
      product_data.dart    # 24 products (from js/products.js) — source of truth
      order_service.dart    # POST to Google Apps Script (same payload as checkout.js)
      cart_storage.dart     # SharedPreferences persistence (key: nh_cart_v1)
    providers/
      cart_provider.dart
      shop_provider.dart
    screens/
      home_screen.dart
      shop_screen.dart
      product_detail_screen.dart
      cart_screen.dart
      checkout_screen.dart  # + OrderSuccessScreen
    widgets/
      product_card.dart
      hero_banner.dart
      app_nav.dart
    utils/
      helpers.dart          # generateOrderId NH-YYMMDD-XXXXX, validators, formatBdt
  assets/
    images/hero/            # copied from site assets
    products/
  test/
    app_test.dart
    order_service_test.dart
```

## API Endpoint

```
https://script.google.com/macros/s/AKfycbwxw0vCQUmtA1RkcQnYmHgPRFVstJWE89DIrNCWGjv9k3QefDpjchqfxYsWVgLrZJpQ/exec
```
Defined in `lib/core/app_config.dart` (`AppConfig.orderApiUrl`) — same as `js/config.js`.

- Method: `POST`
- Header: `Content-Type: text/plain;charset=utf-8` (avoids CORS preflight — same as website)
- Payload: `{ orderId, timestamp, customerName, mobile, email, country, division, district, address, paymentMethod, transactionId, items[], subtotal, deliveryCharge, total }`
- Response: `{ success, orderSaved, emailSent, orderId }` — `orderSaved:true` is the success signal (email may fail independently).

## Delivery

- `DELIVERY_CHARGE = 80`
- `FREE_DELIVERY_THRESHOLD = 5000`
- `delivery = subtotal >= 5000 ? 0 : 80` — from `AppConfig.deliveryFor()`.

## Run

```bash
cd flutter_app
flutter pub get
flutter run
```

If Flutter SDK is not yet on PATH (first-time setup):

```powershell
# Extract SDK (one-time)
Expand-Archive -Path $HOME\Downloads\flutter_sdk.zip -DestinationPath C:\src -Force
$env:PATH = "C:\src\flutter\bin;$env:PATH"
flutter doctor
cd flutter_app
flutter pub get
flutter run
```

## Test

```bash
cd flutter_app
flutter test
```

## Build APK

```bash
cd flutter_app
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

> Note: `flutter build apk` requires the Android SDK and a valid `android/` project. If `android/` is missing (project created manually), run `flutter create --platforms=android . --project-name narayanganj_hosiery` inside `flutter_app/` once to scaffold it, then rebuild.

## Confirmation

- No file outside `flutter_app/` was modified, moved, or deleted.
- Website files (`*.html`, `css/`, `js/`, `assets/`, `google-apps-script/Code.gs`) are unchanged.
- All product data, prices, and business logic are copied verbatim from the site.

## Packages

- `provider` — state management
- `http` — order POST
- `shared_preferences` — cart persistence
- `cached_network_image` — product images
- `intl` — formatting

## Critical Order Flow

Home → Shop → Product → Select size/color → Add to cart → Cart → Checkout → Division/District → COD/bKash/Nagad (+ Transaction ID) → POST to Apps Script → Sheet row + owner email → Success → cart cleared. Failures keep cart intact for retry; stock limits and BD mobile `01[3-9]XXXXXXXX` validation match the website.
