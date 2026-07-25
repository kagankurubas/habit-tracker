import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int colorValue;

  @HiveField(3)
  final List<DateTime> completedDatesList;

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    List<DateTime>? completedDates,
  }) : completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  // Belirli bir günün tamamlanıp tamamlanmadığını kontrol eder
  bool isCompletedOn(DateTime date) {
    return completedDatesList.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  // Günü tamamlandı/tamamlanmadı olarak değiştirir
  void toggleDate(DateTime date) {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCompletedOn(normalizedDate)) {
      completedDatesList.removeWhere((d) =>
          d.year == normalizedDate.year &&
          d.month == normalizedDate.month &&
          d.day == normalizedDate.day);
    } else {
      completedDatesList.add(normalizedDate);
    }
  }

  // Kesintisiz zincir (Streak) hesaplama algoritması
  int calculateStreak() {
    if (completedDatesList.isEmpty) return 0;

    // Tarihleri sıralı listeye dönüştür
    final sortedDates = completedDatesList
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // En yeni tarihten eskiye doğru sırala

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Son tamamlanan tarih bugün mü yoksa dün mü kontrol et
    final latestDate = sortedDates.first;
    final isDoneToday = latestDate.isAtSameMomentAs(today);
    final isDoneYesterday = latestDate.isAtSameMomentAs(yesterday);

    // Eğer ne bugün ne dün yapılmadıysa zincir kırılmıştır
    if (!isDoneToday && !isDoneYesterday) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = isDoneToday ? today : yesterday;

    for (final date in sortedDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        // Arada atlanan bir gün var, zincir bitti
        break;
      }
    }

    return streak;
  }
}