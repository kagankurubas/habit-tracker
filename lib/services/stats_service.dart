// lib/services/stats_service.dart

import '../models/habit.dart';

class DayPerformance {
  final int weekday; // 1: Pzt, 2: Sal, ..., 7: Paz
  final String dayName;
  final int completedCount;
  final int targetCount;

  DayPerformance({
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

  InsightResult({
    this.worstDay,
    this.bestDay,
    required this.message,
    required this.emoji,
  });
}

class StatsService {
  static const Map<int, String> dayNames = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };

  /// Son [daysBack] gün içindeki haftalık performans analizi
  static InsightResult analyzeWeeklyPerformance(List<Habit> habits, {int daysBack = 30}) {
    if (habits.isEmpty) {
      return InsightResult(
        message: 'Henüz yeterli alışkanlık verisi yok. Görevlerini tamamladıkça sana özel analizler burada görünecek!',
        emoji: '📊',
      );
    }

    final today = DateTime.now();
    final Map<int, int> completedPerDay = {for (var i = 1; i <= 7; i++) i: 0};
    final Map<int, int> targetPerDay = {for (var i = 1; i <= 7; i++) i: 0};

    // Son X günün her bir gününü kontrol et
    for (int i = 0; i < daysBack; i++) {
      final date = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final weekday = date.weekday;

      for (var habit in habits) {
        if (habit.isTargetDate(date)) {
          targetPerDay[weekday] = (targetPerDay[weekday] ?? 0) + 1;
          if (habit.isCompletedOn(date)) {
            completedPerDay[weekday] = (completedPerDay[weekday] ?? 0) + 1;
          }
        }
      }
    }

    List<DayPerformance> performances = [];
    for (int day = 1; day <= 7; day++) {
      if ((targetPerDay[day] ?? 0) > 0) {
        performances.add(
          DayPerformance(
            weekday: day,
            dayName: dayNames[day]!,
            completedCount: completedPerDay[day] ?? 0,
            targetCount: targetPerDay[day] ?? 0,
          ),
        );
      }
    }

    if (performances.isEmpty) {
      return InsightResult(
        message: 'Alışkanlık takibine devam et, ilk haftalık analizini hazırlıyoruz!',
        emoji: '🌱',
      );
    }

    // Sırala: En düşükten en yükseğe
    performances.sort((a, b) => a.completionRate.compareTo(b.completionRate));

    final worst = performances.first;
    final best = performances.last;

    // Aksama tespiti (Eğer en kötü günün tamamlama oranı %70'in altındaysa uyarı ver)
    if (worst.completionRate < 70 && worst.targetCount >= 2) {
      final dropPercent = (100 - worst.completionRate).toStringAsFixed(0);
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '⚠️',
        message: '${worst.dayName} günleri alışkanlıklarını %$dropPercent oranında aksatıyorsun! Bugünlere biraz daha odaklanmaya ne dersin?',
      );
    } else if (best.completionRate >= 80) {
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '🔥',
        message: 'Harika gidiyorsun! En verimli günün %${best.completionRate.toStringAsFixed(0)} başarı oranıyla ${best.dayName}.',
      );
    } else {
      return InsightResult(
        worstDay: worst,
        bestDay: best,
        emoji: '💪',
        message: 'Dengeli bir ivme yakaladın. Rutinlerini aksatmadan devam ettir!',
      );
    }
  }
}