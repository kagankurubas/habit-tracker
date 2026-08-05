import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📌 Added for clipboard copy
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/category_model.dart';
import '../services/backup_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../app_themes.dart';
import 'package:easy_localization/easy_localization.dart';

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
              context.tr('settings'),
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 24),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // 🎨 APPEARANCE & THEME SECTION
                _SectionTitle(
                  title: context.tr('appearance'),
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                Material(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: subtextColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.palette_outlined,
                      color: Color(0xFF6366F1),
                    ),
                    title: Text(
                      context.tr('theme_color'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('customize_color_palette'),
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                    ),
                    onTap: () => ThemeService.showThemeSelector(context),
                  ),
                ),

                const SizedBox(height: 24),

                // 🌍 LANGUAGE SECTION
                _SectionTitle(
                  title: context.tr('language'),
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                Material(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: subtextColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF6366F1),
                    ),
                    title: Text(
                      context.tr('language'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Locale>(
                          value: context.locale,
                          focusColor: Colors.transparent,
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: subtextColor,
                            ),
                          ),
                          dropdownColor: AppThemes.isLightBackground(bgColor)
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          elevation: 6,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                          onChanged: (Locale? newLocale) async {
                            if (newLocale != null) {
                              await context.setLocale(newLocale);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇬🇧', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 8),
                                  Text('English'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: Locale('tr'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇹🇷', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 8),
                                  Text('Türkçe'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔊 SOUND & FEEDBACK SECTION
                _SectionTitle(
                  title: context.tr('sound_feedback'),
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<Box>(
                  valueListenable: settingsBox.listenable(),
                  builder: (context, box, _) {
                    final isSoundEnabled = box.get(
                      'isSoundEnabled',
                      defaultValue: true,
                    );
                    final isHapticEnabled = box.get(
                      'isHapticEnabled',
                      defaultValue: true,
                    );

                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: subtextColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 🔊 Sound Effect Switch
                          SwitchListTile(
                            activeThumbColor: const Color(0xFF6366F1),
                            secondary: const Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFF6366F1),
                            ),
                            title: Text(
                              context.tr('sound_effects'),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              context.tr('sound_effects_desc'),
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
                            ),
                            value: isSoundEnabled,
                            onChanged: (bool value) async {
                              await box.put('isSoundEnabled', value);
                            },
                          ),
                          Divider(
                            height: 1,
                            color: subtextColor.withValues(alpha: 0.1),
                          ),

                          // 📳 Haptic Vibration Switch
                          SwitchListTile(
                            activeThumbColor: const Color(0xFF6366F1),
                            secondary: const Icon(
                              Icons.vibration_rounded,
                              color: Color(0xFF10B981),
                            ),
                            title: Text(
                              context.tr('haptic_feedback'),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              context.tr('haptic_feedback_desc'),
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 12,
                              ),
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

                // 💾 DATA & BACKUP SECTION
                _SectionTitle(
                  title: context.tr('data_backup'),
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: subtextColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      // 📤 Export Backup
                      ListTile(
                        leading: const Icon(
                          Icons.upload_file_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        title: Text(
                          context.tr('create_backup'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          context.tr('create_backup_desc'),
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        onTap: () async {
                          try {
                            await BackupService.exportDataToJson(
                              habitsBox,
                              categoriesBox,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('backup_ready')),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr(
                                      'backup_error',
                                      args: [e.toString()],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      Divider(
                        height: 1,
                        color: subtextColor.withValues(alpha: 0.1),
                      ),

                      // 📥 Import Backup
                      ListTile(
                        leading: const Icon(
                          Icons.download_for_offline_rounded,
                          color: Color(0xFF10B981),
                        ),
                        title: Text(
                          context.tr('restore_backup'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          context.tr('restore_backup_desc'),
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        onTap: () async {
                          final success =
                              await BackupService.importDataFromJson(
                                habitsBox,
                                categoriesBox,
                              );
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('data_restored')),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('restore_cancelled'),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🔔 NOTIFICATION TEST
                _SectionTitle(
                  title: context.tr('notifications'),
                  textColor: textColor,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: subtextColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF6366F1),
                    ),
                    title: Text(
                      context.tr('test_notification'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      context.tr('test_notification_desc'),
                      style: TextStyle(color: subtextColor, fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.send_rounded,
                      color: Colors.grey,
                    ),
                    onTap: () async {
                      await NotificationService().showInstantTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('test_notification_sent')),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ℹ️ APP INFO & GITHUB
                _SectionTitle(title: context.tr('about'), textColor: textColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: subtextColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.amber,
                        ),
                        title: Text(
                          'HABITTO',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${context.tr('version')} 1.0.0',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: subtextColor.withValues(alpha: 0.1),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.code_rounded,
                          color: Color(0xFF6366F1),
                        ),
                        title: Text(
                          context.tr('github_source_code'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'kagankurubas/habitto',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),

                        trailing: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onTap: () async {
                          await Clipboard.setData(
                            const ClipboardData(
                              text: 'https://github.com/kagankurubas/habitto',
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('github_copied')),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
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
