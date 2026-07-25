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

  // 0: Her Gün, 1: Hafta İçi, 2: Hafta Sonu, 3: X Günde Bir, 4: Belirli Günler
  @HiveField(4)
  final int frequencyType;

  @HiveField(5)
  final int intervalDays; // X günde bir için (Örn: 2, 3, 4)

  @HiveField(6)
  final List<int> selectedWeekdays; // Belirli günler için (1: Pzt, 2: Sal, ..., 7: Paz)

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    this.frequencyType = 0,
    this.intervalDays = 2,
    List<int>? selectedWeekdays,
    List<DateTime>? completedDates,
  })  : selectedWeekdays = selectedWeekdays ?? [1, 3, 5],
        completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  // Sıklık Metni (Kartlarda ve detayda gösterilecek metin)
  String get frequencyText {
    switch (frequencyType) {
      case 1:
        return 'Hafta İçi';
      case 2:
        return 'Hafta Sonu';
      case 3:
        return '$intervalDays Günde Bir';
      case 4:
        final dayNames = {1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'};
        final names = selectedWeekdays.map((d) => dayNames[d]).join(', ');
        return names.isEmpty ? 'Haftalık' : names;
      case 0:
      default:
        return 'Her Gün';
    }
  }

  DateTime get startDate {
    if (completedDatesList.isNotEmpty) {
      final sorted = List<DateTime>.from(completedDatesList)..sort();
      return DateTime(sorted.first.year, sorted.first.month, sorted.first.day);
    }
    return DateTime.now();
  }

  // 🎯 Dynamic Hedef Gün Hesaplama Algoritması
  bool isTargetDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (target.isBefore(start)) return false;

    switch (frequencyType) {
      case 0: // Her Gün
        return true;

      case 1: // Hafta İçi (Pzt-Cum)
        return target.weekday >= 1 && target.weekday <= 5;

      case 2: // Hafta Sonu (Cmt-Paz)
        return target.weekday == 6 || target.weekday == 7;

      case 3: // 🔄 X GÜNDE BİR (Haftanın gününden bağımsız döngüsel)
        final differenceInDays = target.difference(start).inDays;
        return differenceInDays % intervalDays == 0;

      case 4: // 📅 HAFTANIN BELİRLİ GÜNLERİ (Pazartesi, Çarşamba vb. sabiti)
        return selectedWeekdays.contains(target.weekday);

      default:
        return true;
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