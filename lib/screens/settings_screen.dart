import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/category_model.dart';
import '../services/backup_service.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class SettingsScreen extends StatelessWidget {
  final Box<Habit> habitsBox;
  final Box<CategoryModel> categoriesBox;

  const SettingsScreen({
    super.key,
    required this.habitsBox,
    required this.categoriesBox,
  });

  @override
  Widget build(BuildContext context) {
    // ⚡ Ayarlar kutumuzu açıyoruz (Varsayılan ad: 'settings')
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final textColor = AppThemes.getTextColor(bgColor);
        final subtextColor = AppThemes.getSubtextColor(bgColor);
        final cardColor = AppThemes.getCardColor(bgColor);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'Ayarlar',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 🎨 GÖRÜNÜM & TEMA SEKSİYONU
              _buildSectionTitle('Görünüm', textColor),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtextColor.withValues(alpha: 0.15)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined, color: Color(0xFF6366F1)),
                  title: Text('Tema Rengi', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Uygulama renk paletini kişiselleştir', style: TextStyle(color: subtextColor, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () => ThemeService.showThemeSelector(context),
                ),
              ),

              const SizedBox(height: 24),

              // 🔊 SES & GERİ BİLDİRİM SEKSİYONU (YENİ EKLENDİ)
              _buildSectionTitle('Ses & Geri Bildirim', textColor),
              const SizedBox(height: 8),
              ValueListenableBuilder<Box>(
                valueListenable: settingsBox.listenable(),
                builder: (context, box, _) {
                  final isSoundEnabled = box.get('isSoundEnabled', defaultValue: true);
                  final isHapticEnabled = box.get('isHapticEnabled', defaultValue: true);

                  return Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: subtextColor.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        // 🔊 Ses Efekti Switch
                        SwitchListTile(
                          activeColor: const Color(0xFF6366F1),
                          secondary: const Icon(Icons.volume_up_rounded, color: Color(0xFF6366F1)),
                          title: Text(
                            'Ses Efektleri',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Görev tamamlandığında tamamlama sesi çalar',
                            style: TextStyle(color: subtextColor, fontSize: 12),
                          ),
                          value: isSoundEnabled,
                          onChanged: (bool value) async {
                            await box.put('isSoundEnabled', value);
                          },
                        ),
                        Divider(height: 1, color: subtextColor.withValues(alpha: 0.1)),

                        // 📳 Haptik Titreşim Switch
                        SwitchListTile(
                          activeColor: const Color(0xFF6366F1),
                          secondary: const Icon(Icons.vibration_rounded, color: Color(0xFF10B981)),
                          title: Text(
                            'Haptik Titreşim',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Dokunma anında fiziksel titreşim hissi verir',
                            style: TextStyle(color: subtextColor, fontSize: 12),
                          ),
                          value: isHapticEnabled,
                          onChanged: (bool value) async {
                            await box.put('isHapticEnabled', value);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 💾 VERİ & YEDEKLEME SEKSİYONU
              _buildSectionTitle('Veri & Yedekleme', textColor),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtextColor.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    // 📤 Dışa Aktar (Export)
                    ListTile(
                      leading: const Icon(Icons.upload_file_rounded, color: Color(0xFF6366F1)),
                      title: Text(
                        'Yedek Oluştur (JSON Dışa Aktar)',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Tüm alışkanlık ve kategori verilerini dosya olarak kaydet',
                        style: TextStyle(color: subtextColor, fontSize: 12),
                      ),
                      onTap: () async {
                        try {
                          await BackupService.exportDataToJson(habitsBox, categoriesBox);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yedek dosyası hazırlandı! 🎉')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Yedekleme hatası: $e')),
                            );
                          }
                        }
                      },
                    ),
                    Divider(height: 1, color: subtextColor.withValues(alpha: 0.1)),

                    // 📥 İçe Aktar (Import)
                    ListTile(
                      leading: const Icon(Icons.download_for_offline_rounded, color: Color(0xFF10B981)),
                      title: Text(
                        'Yedekten Geri Yükle (JSON İçe Aktar)',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Önceden aldığın .json yedek dosyasını yükle',
                        style: TextStyle(color: subtextColor, fontSize: 12),
                      ),
                      onTap: () async {
                        final success = await BackupService.importDataFromJson(habitsBox, categoriesBox);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veriler başarıyla yüklendi! 🚀')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('İçe aktarma iptal edildi veya dosya geçersiz.')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ℹ️ UYGULAMA BİLGİSİ
              _buildSectionTitle('Hakkında', textColor),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: subtextColor.withValues(alpha: 0.15)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Colors.amber),
                  title: Text('Habit Tracker', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text('Sürüm 1.0.0', style: TextStyle(color: subtextColor, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}