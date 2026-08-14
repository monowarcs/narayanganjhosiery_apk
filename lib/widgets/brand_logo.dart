import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand logo widgets — uses local SVG assets.
class BrandLogo extends StatelessWidget {
  final bool dark; // true = white text on navy, false = navy on white
  final double height;
  const BrandLogo({super.key, this.dark = false, this.height = 36});

  @override
  Widget build(BuildContext context) {
    final asset = dark ? 'assets/images/logo/logo_dark.svg' : 'assets/images/logo/logo.svg';
    return SvgPicture.asset(asset, height: height, fit: BoxFit.contain);
  }
}

class BrandMark extends StatelessWidget {
  final double size;
  final bool withBackground;
  const BrandMark({super.key, this.size = 44, this.withBackground = false});

  @override
  Widget build(BuildContext context) {
    // Use the app_icon SVG (symbol only) — render inside rounded container if needed
    if (withBackground) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        padding: EdgeInsets.all(size * 0.12),
        child: SvgPicture.asset('assets/images/logo/app_icon.svg', fit: BoxFit.contain),
      );
    }
    // For app bar, use a small white card with navy mark would clash, so use plain mark inside navy bg
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset('assets/images/logo/app_icon_512.png', width: size, height: size, fit: BoxFit.cover),
    );
  }
}
