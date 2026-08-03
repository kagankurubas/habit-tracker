import 'package:flutter/material.dart';
import '../../models/habit.dart';
import 'package:easy_localization/easy_localization.dart';

class SmartInsightCard extends StatelessWidget {
  final List<Habit> habits;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  static const Map<int, String> _dayNames = {
    1: 'mon',
    2: 'tue',
    3: 'wed',
    4: 'thu',
    5: 'fri',
    6: 'sat',
    7: 'sun',
  };

  const SmartInsightCard({
    super.key,
    required this.habits,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);

    final Map<int, int> completedPerDay = {for (var i = 1; i <= 7; i++) i: 0};
    final Map<int, int> targetPerDay = {for (var i = 1; i <= 7; i++) i: 0};

    for (int i = 0; i < 28; i++) {
      final date = todayNormalized.subtract(Duration(days: i));
      final weekday = date.weekday;

      for (final habit in habits) {
        if (habit.isTargetDate(date)) {
          targetPerDay[weekday] = (targetPerDay[weekday] ?? 0) + 1;
          if (habit.isCompletedOn(date)) {
            completedPerDay[weekday] = (completedPerDay[weekday] ?? 0) + 1;
          }
        }
      }
    }

    int? worstDay;
    double lowestRate = 101.0;
    int? bestDay;
    double highestRate = -1.0;

    for (int day = 1; day <= 7; day++) {
      final target = targetPerDay[day] ?? 0;
      final completed = completedPerDay[day] ?? 0;

      if (target >= 2) {
        final rate = (completed / target) * 100;
        if (rate < lowestRate) {
          lowestRate = rate;
          worstDay = day;
        }
        if (rate > highestRate) {
          highestRate = rate;
          bestDay = day;
        }
      }
    }

    String emoji = '💡';
    String message = context.tr('analyzing_data_msg');
    Color accentColor = const Color(0xFF6366F1);

    if (worstDay != null && lowestRate < 60) {
      final worstDayKey = _dayNames[worstDay];
      final dayName = worstDayKey == null ? '' : context.tr(worstDayKey);
      final dropPercent = (100 - lowestRate).toInt();
      emoji = '⚠️';
      accentColor = Colors.orangeAccent;
      message = context.tr(
        'bad_performance_msg',
        args: [dropPercent.toString(), dayName],
      );
    } else if (bestDay != null && highestRate >= 80) {
      final bestDayKey = _dayNames[bestDay];
      final dayName = bestDayKey == null ? '' : context.tr(bestDayKey);
      emoji = '⚡';
      accentColor = const Color(0xFF10B981);
      message = context.tr(
        'super_performance_msg',
        args: [highestRate.toInt().toString(), dayName],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('smart_insight'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
