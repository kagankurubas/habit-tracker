import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(String name, int colorValue, int iconCodePoint) onSave;

  const AddCategoryDialog({super.key, required this.onSave});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();

  final List<Color> _availableColors = const [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
  ];

  final List<IconData> _availableIcons = const [
    Icons.star_rounded,
    Icons.push_pin_rounded,
    Icons.laptop_rounded,
    Icons.music_note_rounded,
    Icons.sports_esports_rounded,
    Icons.directions_run_rounded,
    Icons.book_rounded,
    Icons.fitness_center_rounded,
    Icons.brush_rounded,
    Icons.work_rounded,
  ];

  late int _selectedColorValue;
  late int _selectedIconCodePoint;

  @override
  void initState() {
    super.initState();
    _selectedColorValue = _availableColors[0].toARGB32();
    _selectedIconCodePoint = _availableIcons[0].codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('add_new_category')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.tr('category_name'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 🎨 COLOR SELECTION
            Text(
              context.tr('category_color'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _availableColors.map((color) {
                  final colorValue = color.toARGB32();
                  final isSelected = _selectedColorValue == colorValue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorValue = colorValue;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              context.tr('select_icon'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconData) {
                final isSelected = _selectedIconCodePoint == iconData.codePoint;
                final activeColor = Color(_selectedColorValue);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIconCodePoint = iconData.codePoint;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected ? activeColor : Colors.grey,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColorValue),
          ),
          onPressed: () {
            final categoryName = _nameController.text.trim();
            if (categoryName.isNotEmpty) {
              widget.onSave(
                categoryName,
                _selectedColorValue,
                _selectedIconCodePoint,
              );
              Navigator.pop(context);
            }
          },
          child: Text(
            context.tr('add'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
