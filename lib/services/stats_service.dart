import 'package:easy_localization/easy_localization.dart';
import '../models/habit.dart';

class DayPerformance {
  final int weekday;
  final String dayName;
  final int completedCount;
  final int targetCount;

  const DayPerformance({
    required this.weekday,
    required this.dayName,
    required this.completedCount,
    required this.targetCount,
  });

  double get completionRate =>
      targetCount == 0 ? 0 : (completedCount / targetCount) * 100;
}

class InsightResult {
  final DayPerformance? worstDay;
  final DayPerformance? bestDay;
  final String message;
  final String emoji;

  const InsightResult({
    this.worstDay,
    this.bestDay,
    required this.message,
    required this.emoji,
  });
}

class StatsService {
  StatsService._();

  static const Map<int, String> dayNames = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };

  static InsightResult analyzeWeeklyPerformance(
    List<Habit> habits, {
    int daysBack = 30,
  }) {
    if (habits.isEmpty) {
      return InsightResult(message: 'insight_no_data'.tr(), emoji: '📊');
    }

    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);

    final Map<int, int> completedPerDay = {for (var i = 1; i <= 7; i++) i: 0};
    final Map<int, int> targetPerDay = {for (var i = 1; i <= 7; i++) i: 0};

    for (int i = 0; i < daysBack; i++) {
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

    final List<DayPerformance> performances = [];
    for (int day = 1; day <= 7; day++) {
      final targets = targetPerDay[day] ?? 0;
      if (targets > 0) {
        performances.add(
          DayPerformance(
            weekday: day,
            dayName: dayNames[day] ?? '',
            completedCount: completedPerDay[day] ?? 0,
            targetCount: targets,
          ),
        );
      }
    }

    if (performances.isEmpty) {
      return InsightResult(message: 'insight_preparing'.tr(), emoji: '🌱');
    }

    performances.sort((a, b) => a.completionRate.compareTo(b.completionRate));

    final worst = performances.first;
    final best = performances.last;

    if (worst.completionRate < 70 && worst.targetCount >= 2) {
      final dropPercent = (100 - worst.completionRate).toStringAsFixed(0);
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '⚠️',
        message: 'insight_worst_day'.tr(args: [worst.dayName, dropPercent]),
      );
    } else if (best.completionRate >= 80) {
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '🔥',
        message: 'insight_best_day'.tr(
          args: [best.completionRate.toStringAsFixed(0), best.dayName],
        ),
      );
    } else {
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '💪',
        message: 'insight_balanced'.tr(),
      );
    }
  }
}
