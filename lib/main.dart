import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/cart_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/product_detail_screen.dart';
import 'services/product_data.dart';
import 'widgets/app_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HosieryApp());
}

class HosieryApp extends StatelessWidget {
  const HosieryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..load()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: MaterialApp(
        title: 'Narayanganj Hosiery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const SplashScreen(),
      ),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  void _goShop() => setState(() => _index = 1);
  void _goHome() => setState(() => _index = 0);

  void _filterAndGoShop(String cat, String sub) {
    final shop = context.read<ShopProvider>();
    shop.setCategory(cat);
    shop.setSubcategory(sub);
    setState(() => _index = 1);
  }

  void _openProduct(int id) {
    final p = findProduct(id);
    if (p == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)));
  }

  void _openCheckout() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CheckoutScreen(onSuccess: _goHome)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onGoShop: _goShop, onOpenProduct: _openProduct, onFilterAndGoShop: _filterAndGoShop),
      ShopScreen(onOpenProduct: _openProduct),
      CartScreen(onCheckout: _openCheckout, onGoShop: _goShop),
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RootNav()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('assets/images/logo/app_icon_512.png', width: 110, height: 110, fit: BoxFit.cover),
            ),
            const SizedBox(height: 22),
            SvgPicture.asset('assets/images/logo/logo_dark.svg', height: 38),
            const SizedBox(height: 10),
            const Text('পাবনা • খুচরা ও পাইকারি', style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 36),
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.navy,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/images/logo/app_icon_512.png', width: 52, height: 52),
                  ),
                  const SizedBox(height: 14),
                  SvgPicture.asset('assets/images/logo/logo_dark.svg', height: 30),
                  const SizedBox(height: 6),
                  const Text('নারায়ণগঞ্জ হোসিয়ারি, পাবনা', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(leading: const Icon(Icons.storefront, color: Colors.white70), title: const Text('Shop', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.info_outline, color: Colors.white70), title: const Text('About', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.phone, color: Colors.white70), title: const Text('Contact  01711-483621', style: TextStyle(color: Colors.white, fontSize: 13)), onTap: () => Navigator.pop(context)),
            const Spacer(),
            const Padding(padding: EdgeInsets.all(16), child: Text('© Narayanganj Hosiery', style: TextStyle(color: Colors.white38, fontSize: 11))),
          ],
        ),
      ),
    );
  }
}
