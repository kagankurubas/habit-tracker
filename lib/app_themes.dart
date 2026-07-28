import 'package:flutter/material.dart';

class AppThemes {
  // 🛠️ Nesne türetilmesini engeller
  AppThemes._();

  static const Color defaultBg = Color(0xFF0F172A);

  static const List<Color> backgroundPalette = [
    Color(0xFF0F172A), // Koyu Lacivert
    Color(0xFFD8C3B5), // Sıcak Bej
    Color(0xFFF4F3EF), // Krem / Off-White
    Color(0xFF3A6B74), // Mavi-Yeşil Petrol
    Color(0xFFCFA376), // Mat Hardal / Taba
    Color(0xFFC3D3D5), // Buz Mavisi
    Color(0xFF233E3C), // Derin Orman Yeşili
    Color(0xFFA06752), // Kiremit / Terracotta
    Color(0xFFE1DBD6), // Soft Vizon / Açık Gri
  ];

  // 🎯 Arka plan açık mı? (Luminance > 0.45 ise açık zemin)
  static bool isLightBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.45;
  }

  // ✍️ Dinamik Ana Metin Rengi
  static Color getTextColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? const Color(0xFF0F172A) // Açık zemin için koyu lacivert
        : Colors.white; // Koyu zemin için beyaz
  }

  // 🖋️ Dinamik İkincil Metin Rengi (Subtitle)
  static Color getSubtextColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? const Color(0xFF475569) // Açık zemin için koyu gri
        : Colors.grey.shade400; // Koyu zemin için açık gri
  }

  // 🃏 Dinamik Kart Rengi
  static Color getCardColor(Color backgroundColor) {
    return isLightBackground(backgroundColor)
        ? Colors.black.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.08);
  }

  // 🧭 Alt Navigasyon Çubuğu İçin Akıllı Tonlama
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
