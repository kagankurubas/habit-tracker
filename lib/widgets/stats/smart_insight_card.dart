import 'package:flutter/material.dart';
import '../../models/habit.dart';

class SmartInsightCard extends StatelessWidget {
  final List<Habit> habits;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  static const Map<int, String> _dayNames = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
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

    // Son 28 günün analizi
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
    String message = 'Verilerinizi analiz ediyoruz. Rutinlerinizi aksatmadan tamamlamaya devam edin!';
    Color accentColor = const Color(0xFF6366F1);

    if (worstDay != null && lowestRate < 60) {
      final dayName = _dayNames[worstDay] ?? '';
      final dropPercent = (100 - lowestRate).toInt();
      emoji = '⚠️';
      accentColor = Colors.orangeAccent;
      message = '$dayName günleri alışkanlıklarını %$dropPercent oranında aksatıyorsun! Bugünlere biraz daha odaklanmaya ne dersin?';
    } else if (bestDay != null && highestRate >= 80) {
      final dayName = _dayNames[bestDay] ?? '';
      emoji = '⚡';
      accentColor = const Color(0xFF10B981);
      message = 'Süper performans! En verimli günün %${highestRate.toInt()} başarı oranıyla $dayName.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.5),
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
                  'Akıllı Rutin Analizi',
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