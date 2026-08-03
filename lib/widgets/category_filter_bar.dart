import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../services/theme_service.dart';
import 'package:easy_localization/easy_localization.dart';
import '../app_themes.dart';
import 'add_category_dialog.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  void _showDeleteDialog(
    BuildContext context,
    CategoryModel category,
    Color bgColor,
  ) {
    final textColor = AppThemes.getTextColor(bgColor);
    final subtextColor = AppThemes.getSubtextColor(bgColor);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppThemes.isLightBackground(bgColor)
            ? const Color(0xFFF1F5F9)
            : const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'delete_category'.tr(),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'delete_category_desc'.tr(args: [category.name.tr()]),
          style: TextStyle(color: subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr(), style: TextStyle(color: subtextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await category.delete();
              if (ctx.mounted) Navigator.pop(ctx);
              onCategorySelected('Tüm Görevler');
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesBox = Hive.box<CategoryModel>('categories');

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final isLight = AppThemes.isLightBackground(bgColor);

        return ValueListenableBuilder<Box<CategoryModel>>(
          valueListenable: categoriesBox.listenable(),
          builder: (context, box, child) {
            final userCategories = box.values.toList();

            return SizedBox(
              height: 38,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userCategories.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = selectedCategory == 'all_tasks';
                      return _buildChip(
                        context: context,
                        label: 'all_tasks'.tr(),
                        iconData: Icons.stars_rounded,
                        chipColor: const Color(0xFF6366F1),
                        isSelected: isSelected,
                        isLight: isLight,
                        onTap: () => onCategorySelected('all_tasks'),
                      );
                    }

                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AddCategoryDialog(
                                onSave:
                                    (name, colorValue, iconCodePoint) async {
                                      final newCategory = CategoryModel(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        name: name,
                                        colorValue: colorValue,
                                        iconCodePoint: iconCodePoint,
                                      );
                                      await categoriesBox.add(newCategory);
                                    },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.indigo.shade50
                                  : const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF6366F1,
                                ).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Color(0xFF6366F1),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'add_category_btn'.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final category = userCategories[index - 2];
                    final isSelected = selectedCategory == category.name;

                    return _buildChip(
                      context: context,
                      label: category.name.tr(),
                      iconData: category.iconData,
                      chipColor: category.color,
                      isSelected: isSelected,
                      isLight: isLight,
                      onTap: () => onCategorySelected(category.name),
                      onLongPress: () =>
                          _showDeleteDialog(context, category, bgColor),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData iconData,
    required Color chipColor,
    required bool isSelected,
    required bool isLight,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final Color activeBgColor = chipColor;
    final Color unselectedBgColor = isLight
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.08);
    const Color activeTextColor = Colors.white;
    final Color unselectedTextColor = isLight
        ? const Color(0xFF0F172A)
        : Colors.white.withValues(alpha: 0.8);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
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
              Icon(
                iconData,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isLight ? chipColor : chipColor.withValues(alpha: 0.9)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
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
    );
  }
}
