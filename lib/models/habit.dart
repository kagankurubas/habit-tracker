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

  // 0: Her Gün, 1: Hafta İçi, 2: Hafta Sonu, 3: Haftada 3 Gün
  @HiveField(4)
  final int frequencyType; 

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    this.frequencyType = 0,
    List<DateTime>? completedDates,
  }) : completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  String get frequencyText {
    switch (frequencyType) {
      case 1:
        return 'Hafta İçi';
      case 2:
        return 'Hafta Sonu';
      case 3:
        return 'Haftada 3 Gün';
      case 0:
      default:
        return 'Her Gün';
    }
  }

  bool isCompletedOn(DateTime date) {
    return completedDatesList.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

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

  int calculateStreak() {
    if (completedDatesList.isEmpty) return 0;

    final sortedDates = completedDatesList
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final latestDate = sortedDates.first;
    final isDoneToday = latestDate.isAtSameMomentAs(today);
    final isDoneYesterday = latestDate.isAtSameMomentAs(yesterday);

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
        break;
      }
    }

    return streak;
  }
}