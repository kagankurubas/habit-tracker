import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../app_themes.dart';

class ThemeService {
  // 🛠️ Nesne türetilmesini engeller
  ThemeService._();

  static const String _boxName = 'settings';
  static const String _colorKey = 'bg_color';

  // Tüm uygulamanın dinleyeceği ValueNotifier
  static final ValueNotifier<Color> currentColor =
      ValueNotifier<Color>(AppThemes.defaultBg);

  // 🚀 1. Servisi Başlatma (main.dart içinde çağrılacak)
  static Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    final savedColorValue = box.get(_colorKey);

    if (savedColorValue != null) {
      currentColor.value = Color(savedColorValue as int);
    }
  }

  // 💾 2. Renk Değiştirme ve Hive'a Kaydetme
  static Future<void> changeColor(Color newColor) async {
    currentColor.value = newColor;
    final box = Hive.box(_boxName);
    await box.put(_colorKey, newColor.toARGB32());
  }

  // 🎨 3. Renk Seçim Modalını Açma
  static void showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder<Color>(
          valueListenable: currentColor,
          builder: (context, activeColor, _) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Arka Plan Rengi Seç',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppThemes.backgroundPalette.length,
                      itemBuilder: (context, index) {
                        final color = AppThemes.backgroundPalette[index];
                        final isSelected = activeColor.toARGB32() == color.toARGB32();

                        return GestureDetector(
                          onTap: () async {
                            await changeColor(color);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.amber : Colors.white24,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: AppThemes.getTextColor(color),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}