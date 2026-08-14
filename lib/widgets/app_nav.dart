import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../core/theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: AppTheme.navy.withOpacity(0.12),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
        const NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'শপ'),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag),
          ),
          label: 'কার্ট',
        ),
      ],
    );
  }
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? bottom;
  const AppHeader({super.key, required this.title, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom != null ? 56 : 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      bottom: bottom != null ? PreferredSize(preferredSize: const Size.fromHeight(56), child: bottom!) : null,
      actions: [
        Consumer<CartProvider>(builder: (_, cart, __) {
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => DefaultTabController.of(context)?.animateTo(2),
              ),
              if (cart.count > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(999)),
                    child: Text('${cart.count}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
