import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';
import 'badge_unlocked_dialog.dart';

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

  Future<void> _handleToggle(BuildContext context, Habit currentHabit) async {
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final willComplete = !currentHabit.isCompletedOn(todayNormalized);

    final bool isSettingsOpen = Hive.isBoxOpen('settings');
    final Box? settingsBox = isSettingsOpen ? Hive.box('settings') : null;
    final bool isSoundEnabled =
        settingsBox?.get('isSoundEnabled', defaultValue: true) ?? true;
    final bool isHapticEnabled =
        settingsBox?.get('isHapticEnabled', defaultValue: true) ?? true;

    if (willComplete) {
      if (isHapticEnabled) HapticFeedback.mediumImpact();
      if (isSoundEnabled) {
        try {
          await _audioPlayer.stop();
          await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
        } catch (_) {}
      }
    } else if (isHapticEnabled) {
      HapticFeedback.lightImpact();
    }

    currentHabit.toggleDate(todayNormalized);

    if (currentHabit.key != null) {
      await habitsBox.put(currentHabit.key, currentHabit);
    } else {
      await habitsBox.putAt(index, currentHabit);
    }

    if (willComplete && context.mounted) {
      _checkBadgeUnlocked(context);
    }
  }

  // 🏆 BADGE CONTROL AND SEQUENTIAL POP-UP DISPLAY
  void _checkBadgeUnlocked(BuildContext context) async {
    final int streak = habit.currentStreak;
    final int totalCompletions = habitsBox.values.fold(
      0,
      (sum, h) => sum + h.completedDatesList.length,
    );

    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final allHabits = habitsBox.values.toList();
    final todayTargets = allHabits
        .where((h) => h.isTargetDate(todayNormalized))
        .toList();
    final isPerfectDay =
        todayTargets.length >= 3 &&
        todayTargets.every((h) => h.isCompletedOn(todayNormalized));

    final List<Map<String, dynamic>> badges = [];

    if (totalCompletions == 1) {
      badges.add({
        'title': context.tr('First Step'),
        'desc': context.tr('first_step_desc'),
        'imagePath': 'assets/badges/first_step.png',
        'color': const Color(0xFF10B981),
      });
    }
    if (isPerfectDay) {
      badges.add({
        'title': context.tr('Perfect Day'),
        'desc': context.tr('perfect_day_desc'),
        'imagePath': 'assets/badges/perfect_day.png',
        'color': const Color(0xFFF59E0B),
      });
    }
    if (streak == 3) {
      badges.add({
        'title': context.tr('On Fire'),
        'desc': context.tr('on_fire_desc'),
        'imagePath': 'assets/badges/streak_3.png',
        'color': const Color(0xFF3B82F6),
      });
    } else if (streak == 7) {
      badges.add({
        'title': context.tr('Willpower Master'),
        'desc': context.tr('willpower_master_desc'),
        'imagePath': 'assets/badges/streak_7.png',
        'color': const Color(0xFF8B5CF6),
      });
    } else if (streak == 30) {
      badges.add({
        'title': context.tr('habit_monster_title'),
        'desc': context.tr('habit_monster_desc'),
        'imagePath': 'assets/badges/completion_50.png',
        'color': const Color(0xFFEC4899),
      });
    } else if (totalCompletions == 50) {
      badges.add({
        'title': context.tr('Legend'),
        'desc': context.tr('legend_desc'),
        'imagePath': 'assets/badges/completion_50.png',
        'color': const Color(0xFFF59E0B),
      });
    }

    for (final b in badges) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => BadgeUnlockedDialog(
          badgeTitle: b['title'],
          badgeDescription: b['desc'],
          imagePath: b['imagePath'],
          badgeColor: b['color'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Habit>>(
      valueListenable: habitsBox.listenable(
        keys: habit.key != null ? [habit.key] : null,
      ),
      builder: (context, box, _) {
        final currentHabit = box.get(habit.key) ?? habit;
        final isDoneToday = currentHabit.isCompletedOn(DateTime.now());

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
                  color: isDoneToday
                      ? Colors.greenAccent
                      : currentHabit.color.withValues(alpha: 0.4),
                  width: isDoneToday ? 2.0 : 1.0,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                leading: _LeadingCheck(
                  habit: currentHabit,
                  isDoneToday: isDoneToday,
                  subtextColor: subtextColor,
                  onToggle: () => _handleToggle(context, currentHabit),
                ),
                title: _TitleAndCategory(
                  habit: currentHabit,
                  isDoneToday: isDoneToday,
                  textColor: textColor,
                  subtextColor: subtextColor,
                  isLight: isLight,
                ),
                subtitle: _SubtitleProgress(
                  habit: currentHabit,
                  subtextColor: subtextColor,
                  isLight: isLight,
                ),
                trailing: _TrailingActions(
                  habit: currentHabit,
                  subtextColor: subtextColor,
                  onEdit: onEdit,
                ),
                onTap: onTap,
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================================

class _LeadingCheck extends StatelessWidget {
  final Habit habit;
  final bool isDoneToday;
  final Color subtextColor;
  final VoidCallback onToggle;

  const _LeadingCheck({
    required this.habit,
    required this.isDoneToday,
    required this.subtextColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: habit.color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(habit.icon, color: habit.color, size: 18),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onToggle,
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
    );
  }
}

class _TitleAndCategory extends StatelessWidget {
  final Habit habit;
  final bool isDoneToday;
  final Color textColor;
  final Color subtextColor;
  final bool isLight;

  const _TitleAndCategory({
    required this.habit,
    required this.isDoneToday,
    required this.textColor,
    required this.subtextColor,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final streak = habit.currentStreak;
    return Row(
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
            context.tr(habit.category),
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
    );
  }
}

class _SubtitleProgress extends StatelessWidget {
  final Habit habit;
  final Color subtextColor;
  final bool isLight;

  const _SubtitleProgress({
    required this.habit,
    required this.subtextColor,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final rate = habit.calculateCompletionRate(lastDays: 30);
    return Padding(
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
                        context.tr('last_30_days'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: subtextColor),
                      ),
                    ),
                    if (habit.isNotificationEnabled &&
                        habit.notificationHour != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.alarm,
                        size: 11,
                        color: isLight
                            ? Colors.amber.shade800
                            : Colors.amberAccent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${habit.notificationHour.toString().padLeft(2, '0')}:${habit.notificationMinute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isLight
                              ? Colors.amber.shade900
                              : Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '%${rate.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: habit.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate / 100,
              backgroundColor: isLight
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(habit.color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailingActions extends StatelessWidget {
  final Habit habit;
  final Color subtextColor;
  final VoidCallback onEdit;

  const _TrailingActions({
    required this.habit,
    required this.subtextColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.edit_outlined,
            color: Colors.blueAccent,
            size: 18,
          ),
          onPressed: onEdit,
        ),
        const SizedBox(width: 6),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
            size: 18,
          ),
          onPressed: () async {
            await NotificationService().cancelHabitNotification(habit);
            await habit.delete();
          },
        ),
        const SizedBox(width: 2),
        Icon(Icons.chevron_right, color: subtextColor, size: 16),
      ],
    );
  }
}
