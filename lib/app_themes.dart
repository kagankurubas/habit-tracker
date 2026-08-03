import 'package:flutter/material.dart';

class AppThemes {
  AppThemes._();

  static const Color defaultBg = Color(0xFF0F172A);

  static const List<Color> backgroundPalette = [
    Color(0xFF0F172A),
    Color(0xFFD8C3B5),
    Color(0xFFF4F3EF),
    Color(0xFF3A6B74),
    Color(0xFFCFA376),
    Color(0xFFC3D3D5),
    Color(0xFF233E3C),
    Color(0xFFA06752),
    Color(0xFFE1DBD6),
  ];

  static bool isLightBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.45;
  }

  static Color getTextColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? const Color(0xFF0F172A)
        : Colors.white;
  }

  static Color getSubtextColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? const Color(0xFF475569)
        : Colors.grey.shade400;
  }

  static Color getCardColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? Colors.black.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.08);
  }

  static Color getNavBarColor(Color backgroundColor) {
    final hsl = HSLColor.fromColor(backgroundColor);
    if (isLightBackground(backgroundColor)) {
      return hsl
          .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
          .toColor();
    } else {
      return hsl
          .withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0))
          .toColor();
    }
  }
}
