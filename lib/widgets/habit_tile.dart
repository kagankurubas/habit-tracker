import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final int index;
  final Box<Habit> habitsBox;
  final VoidCallback onEdit;
  final VoidCallback onTap;

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
    final streak = habit.currentStreak;
    final isDoneToday = habit.isCompletedOn(DateTime.now());

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
              : habit.color.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDoneToday ? Colors.greenAccent : habit.color.withValues(alpha: 0.4),
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
                      color: habit.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      habit.icon,
                      color: habit.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () async {
                      final today = DateTime.now();
                      final todayNormalized = DateTime(today.year, today.month, today.day);

                      habit.toggleDate(todayNormalized);

                      if (habit.key != null) {
                        await habitsBox.put(habit.key, habit);
                      } else {
                        await habitsBox.putAt(index, habit);
                      }
                      await habitsBox.flush();
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
                      habit.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: isDoneToday ? TextDecoration.lineThrough : null,
                        color: isDoneToday ? subtextColor : textColor, // 👈 Dinamik Metin Rengi
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
                      habit.category,
                      style: TextStyle(fontSize: 9, color: subtextColor), // 👈 Dinamik Alt Metin Rengi
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

              // 3. İLERLEME VE BİLDİRİM BİLGİSİ + PROGRESS BAR (GERİ EKLENDİ)
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
                              if (habit.isNotificationEnabled && habit.notificationHour != null) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.alarm, size: 11, color: isLight ? Colors.amber.shade800 : Colors.amberAccent),
                                const SizedBox(width: 2),
                                Text(
                                  '${habit.notificationHour.toString().padLeft(2, '0')}:${habit.notificationMinute.toString().padLeft(2, '0')}',
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
                          '%${habit.calculateCompletionRate(lastDays: 30).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: habit.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 🚀 PROGRESS BAR (İLERLEME ÇUBUĞU)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: habit.calculateCompletionRate(lastDays: 30) / 100,
                        backgroundColor: isLight 
                            ? Colors.black.withValues(alpha: 0.1) 
                            : Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(habit.color),
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
                      await NotificationService().cancelHabitNotification(habit);
                      await habit.delete();
                      await habitsBox.flush();
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
  }
}