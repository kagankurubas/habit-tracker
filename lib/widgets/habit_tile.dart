import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final int index;
  final Box<Habit> habitsBox;
  final VoidCallback onEdit;
  final VoidCallback onTap;
  static final AudioPlayer _audioPlayer = AudioPlayer();

  const HabitTile({
    super.key,
    required this.habit,
    required this.index,
    required this.habitsBox,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ⚡ OPTİMİZASYON: Kart yalnızca KENDİ Hive key'ini dinler.
    // Başka bir alışkanlık güncellendiğinde bu kart rebuild OLMAZ!
    return ValueListenableBuilder<Box<Habit>>(
      valueListenable: habitsBox.listenable(keys: habit.key != null ? [habit.key] : null),
      builder: (context, box, _) {
        // Güncel habit nesnesini Hive'dan çekiyoruz
        final currentHabit = box.get(habit.key) ?? habit;
        final streak = currentHabit.currentStreak;
        final isDoneToday = currentHabit.isCompletedOn(DateTime.now());

        // 🚀 DİNAMİK TEMA RENGİ DİNLENİYOR
        return ValueListenableBuilder<Color>(
          valueListenable: ThemeService.currentColor,
          builder: (context, bgColor, child) {
            final textColor = AppThemes.getTextColor(bgColor);
            final subtextColor = AppThemes.getSubtextColor(bgColor);
            final isLight = AppThemes.isLightBackground(bgColor);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isLight
                  ? Colors.black.withValues(alpha: 0.05)
                  : currentHabit.color.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDoneToday ? Colors.greenAccent : currentHabit.color.withValues(alpha: 0.4),
                  width: isDoneToday ? 2.0 : 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

                  // 1. SOL ELEMANLAR: İKON VE ONAY TİKİ
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: currentHabit.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentHabit.icon,
                          color: currentHabit.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () async {
                          final today = DateTime.now();
                          final todayNormalized = DateTime(today.year, today.month, today.day);

                          // Görev tamamlanmamışsa ve şimdi tamamlanıyorsa haptik + ses verelim
                          final willComplete = !currentHabit.isCompletedOn(todayNormalized);

                          // ⚡ Settings kovanındaki kullanıcı tercihlerini okuyoruz
                          final bool isSettingsOpen = Hive.isBoxOpen('settings');
                          final Box? settingsBox = isSettingsOpen ? Hive.box('settings') : null;

                          final bool isSoundEnabled = settingsBox?.get('isSoundEnabled', defaultValue: true) ?? true;
                          final bool isHapticEnabled = settingsBox?.get('isHapticEnabled', defaultValue: true) ?? true;

                          if (willComplete) {
                            // 📳 1. Haptik Titreşim (Açıksa)
                            if (isHapticEnabled) {
                              HapticFeedback.mediumImpact();
                            }

                            // 🔊 2. Ses Efekti Çal (Açıksa)
                            if (isSoundEnabled) {
                              try {
                                await _audioPlayer.stop(); // Önceki ses çalıyorsa durdur
                                await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
                              } catch (_) {
                                // Web veya ses sürücüsü hatası olursa uygulamayı aksatmasın
                              }
                            }
                          } else {
                            // İptal ederken daha hafif bir titreşim (Açıksa)
                            if (isHapticEnabled) {
                              HapticFeedback.lightImpact();
                            }
                          }

                          currentHabit.toggleDate(todayNormalized);

                          if (currentHabit.key != null) {
                            await habitsBox.put(currentHabit.key, currentHabit);
                          } else {
                            await habitsBox.putAt(index, currentHabit);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDoneToday ? Colors.greenAccent : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDoneToday ? Colors.greenAccent : subtextColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: isDoneToday ? Colors.black : Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. ORTA ELEMANLAR: BAŞLIK, KATEGORİ VE STREAK ALEVİ
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentHabit.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: isDoneToday ? TextDecoration.lineThrough : null,
                            color: isDoneToday ? subtextColor : textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLight
                              ? Colors.black.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentHabit.category,
                          style: TextStyle(fontSize: 9, color: subtextColor),
                        ),
                      ),
                      if (streak > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Text(
                            '🔥 $streak',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // 3. İLERLEME VE BİLDİRİM BİLGİSİ + PROGRESS BAR
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Son 30 Gün',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 10, color: subtextColor),
                                    ),
                                  ),
                                  if (currentHabit.isNotificationEnabled && currentHabit.notificationHour != null) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.alarm, size: 11, color: isLight ? Colors.amber.shade800 : Colors.amberAccent),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${currentHabit.notificationHour.toString().padLeft(2, '0')}:${currentHabit.notificationMinute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: isLight ? Colors.amber.shade900 : Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              '%${currentHabit.calculateCompletionRate(lastDays: 30).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: currentHabit.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: currentHabit.calculateCompletionRate(lastDays: 30) / 100,
                            backgroundColor: isLight
                                ? Colors.black.withValues(alpha: 0.1)
                                : Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(currentHabit.color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. SAĞ ELEMANLAR: DÜZENLE VE SİL
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 18),
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        onPressed: () async {
                          await NotificationService().cancelHabitNotification(currentHabit);
                          await currentHabit.delete();
                        },
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, color: subtextColor, size: 16),
                    ],
                  ),
                  onTap: onTap,
                ),
              ),
            );
          },
        );
      },
    );
  }
}