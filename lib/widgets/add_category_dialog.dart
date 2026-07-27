import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '⭐';

  final List<String> _emojiList = [
    '⭐', '📌', '💻', '🎸', '🎮', '🏃', '📚', '🧘',
    '🎯', '🎨', '💼', '🚀', '☕', '💧', '🍕', '🛠️'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final cardColor = AppThemes.getCardColor(bgColor);
        final textColor = AppThemes.getTextColor(bgColor);
        final subtextColor = AppThemes.getSubtextColor(bgColor);

        return AlertDialog(
          backgroundColor: AppThemes.isLightBackground(bgColor)
              ? const Color(0xFFF1F5F9)
              : const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Yeni Kategori Ekle',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Kategori Adı',
                  labelStyle: TextStyle(color: subtextColor),
                  hintText: 'Örn: Diş Bakımı, Bütçe...',
                  hintStyle: TextStyle(color: subtextColor.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'İkon / Emoji Seç:',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                width: double.maxFinite,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: _emojiList.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojiList[index];
                    final isSelected = _selectedEmoji == emoji;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo.shade400.withValues(alpha: 0.3)
                              : cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.indigoAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal', style: TextStyle(color: subtextColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  final box = Hive.box<CategoryModel>('categories');
                  final newCategory = CategoryModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    icon: _selectedEmoji,
                  );
                  await box.add(newCategory);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}