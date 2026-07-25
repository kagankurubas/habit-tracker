import 'package:flutter/material.dart';

enum FrequencyType { daily, weeklyDays }

class Habit {
  final String id;
  final String title;
  final Color color;
  final FrequencyType frequencyType;
  final List<int> targetDays; // 1: Pazartesi, ..., 7: Pazar
  final Set<DateTime> completedDates; // Tamamlanan günler

  Habit({
    required this.id,
    required this.title,
    required this.color,
    this.frequencyType = FrequencyType.daily,
    this.targetDays = const [1, 2, 3, 4, 5, 6, 7],
    Set<DateTime>? completedDates,
  }) : completedDates = completedDates ?? {};

  // Belirli bir günün tamamlanıp tamamlanmadığını kontrol eder
  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  // Günü tamamlandı/tamamlanmadı olarak değiştirir
  void toggleDate(DateTime date) {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCompletedOn(normalizedDate)) {
      completedDates.removeWhere((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day);
    } else {
      completedDates.add(normalizedDate);
    }
  }
}