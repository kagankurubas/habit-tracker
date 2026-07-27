import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Tüm Görevler', 'icon': '✨'},
    {'name': 'Genel', 'icon': '📌'},
    {'name': 'Kodlama', 'icon': '💻'},
    {'name': 'Müzik', 'icon': '🎸'},
    {'name': 'Oyun Dev.', 'icon': '🎮'},
    {'name': 'Spor', 'icon': '🏃'},
    {'name': 'Okuma', 'icon': '📚'},
    {'name': 'Sağlık', 'icon': '🧘'},
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final isLight = AppThemes.isLightBackground(bgColor);

        return SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final String name = cat['name'];
              final String icon = cat['icon'];
              final isSelected = selectedCategory == name;

              // 🎯 RENK VE KONTRAST AYARLARI
              final Color activeBgColor = isLight 
                  ? const Color(0xFF0F172A)  // Açık temada seçili: Koyu Lacivert
                  : const Color(0xFF6366F1); // Koyu temada seçili: İndigo Mor

              final Color unselectedBgColor = isLight
                  ? Colors.white.withValues(alpha: 0.5) // Açık temada seçili olmayan: Yarı saydam krem/beyaz
                  : Colors.white.withValues(alpha: 0.08); // Koyu temada seçili olmayan: Yarı saydam gri

              final Color activeTextColor = Colors.white;
              final Color unselectedTextColor = isLight
                  ? const Color(0xFF0F172A) // Açık temada seçili olmayan metin: Koyu Lacivert (Net Okunur!)
                  : Colors.white.withValues(alpha: 0.8); // Koyu temada seçili olmayan metin: Açık Gri

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onCategorySelected(name),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBgColor : unselectedBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isLight 
                                  ? Colors.black.withValues(alpha: 0.1) 
                                  : Colors.white.withValues(alpha: 0.15)),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            icon,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? activeTextColor : unselectedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}