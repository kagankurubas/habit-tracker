import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

class HabitCategory {
  final String name;
  final String icon;

  const HabitCategory(this.name, this.icon);
}

const List<HabitCategory> availableCategories = [
  HabitCategory('Genel', '📌'),
  HabitCategory('Kodlama', '💻'),
  HabitCategory('Müzik', '🎸'),
  HabitCategory('Oyun Dev', '🎮'),
  HabitCategory('Spor', '🏃'),
  HabitCategory('Okuma', '📚'),
  HabitCategory('Sağlık', '🧘'),
];

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  List<DateTime> completedDatesList;

  @HiveField(4)
  int frequencyType;

  @HiveField(5)
  int intervalDays;

  @HiveField(6)
  List<int> selectedWeekdays;

  @HiveField(7)
  int iconCodePoint;

  @HiveField(8)
  String category;

  @HiveField(9)
  bool isNotificationEnabled;

  @HiveField(10)
  int? notificationHour;

  @HiveField(11)
  int? notificationMinute;

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    this.frequencyType = 0,
    this.intervalDays = 2,
    this.iconCodePoint = 0xe3af,
    List<int>? selectedWeekdays,
    List<DateTime>? completedDates,
    this.category = 'Genel',
    this.isNotificationEnabled = false,
    this.notificationHour,
    this.notificationMinute,
  })  : selectedWeekdays = selectedWeekdays ?? [1, 3, 5],
        completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  // İkon Dönüştürücü
  IconData get icon {
    final iconMap = <int, IconData>{
      Icons.book_rounded.codePoint: Icons.book_rounded,
      Icons.fitness_center_rounded.codePoint: Icons.fitness_center_rounded,
      Icons.music_note_rounded.codePoint: Icons.music_note_rounded,
      Icons.code_rounded.codePoint: Icons.code_rounded,
      Icons.water_drop_rounded.codePoint: Icons.water_drop_rounded,
      Icons.directions_run_rounded.codePoint: Icons.directions_run_rounded,
      Icons.bed_rounded.codePoint: Icons.bed_rounded,
      Icons.self_improvement_rounded.codePoint: Icons.self_improvement_rounded,
    };

    return iconMap[iconCodePoint] ?? Icons.star_rounded;
  }

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

  // Tarih saatini 00:00:00 yapacak yardımcı metot
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime get startDate {
    if (completedDatesList.isNotEmpty) {
      final sorted = List<DateTime>.from(completedDatesList)..sort();
      return _stripTime(sorted.first);
    }
    return _stripTime(DateTime.now());
  }

  bool isTargetDate(DateTime date) {
    final target = _stripTime(date);
    final start = startDate;

    if (target.isBefore(start)) return false;

    switch (frequencyType) {
      case 1:
        return target.weekday >= 1 && target.weekday <= 5;
      case 2:
        return target.weekday == 6 || target.weekday == 7;
      case 3:
        final differenceInDays = target.difference(start).inDays;
        return differenceInDays % intervalDays == 0;
      case 4:
        return selectedWeekdays.contains(target.weekday);
      case 0:
      default:
        return true;
    }
  }

  bool isCompletedOn(DateTime date) {
    final target = _stripTime(date);
    return completedDatesList.any((d) => _stripTime(d).isAtSameMomentAs(target));
  }

  void toggleDate(DateTime date) {
    final target = _stripTime(date);
    final newList = List<DateTime>.from(completedDatesList);

    final index = newList.indexWhere((d) => _stripTime(d).isAtSameMomentAs(target));

    if (index != -1) {
      newList.removeAt(index);
    } else {
      newList.add(target);
    }

    completedDatesList = newList;
  }

  // 📊 Mükerrer kayıtları engelleyen ve güvenli seri (streak) hesaplayıcı
  int get currentStreak {
    if (completedDatesList.isEmpty) return 0;

    final sortedDates = completedDatesList
        .map((d) => _stripTime(d))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = _stripTime(DateTime.now());
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

  // 📈 Son X gün içindeki başarı yüzdesi
  double calculateCompletionRate({int lastDays = 30}) {
    if (completedDatesList.isEmpty) return 0.0;

    final today = _stripTime(DateTime.now());
    int completedCount = 0;

    for (int i = 0; i < lastDays; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (isCompletedOn(checkDate)) {
        completedCount++;
      }
    }

    return (completedCount / lastDays) * 100;
  }

  // 🔢 Toplam tamamlanan gün sayısı
  int get totalCompletedDays => completedDatesList.length;
}