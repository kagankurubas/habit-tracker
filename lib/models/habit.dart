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
  }) : selectedWeekdays = selectedWeekdays ?? <int>[],
       completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  // ⚡ Static Icon Map: RAM'de sadece 1 kez oluşturulur
  static final Map<int, IconData> _iconMap = {
    Icons.book_rounded.codePoint: Icons.book_rounded,
    Icons.fitness_center_rounded.codePoint: Icons.fitness_center_rounded,
    Icons.music_note_rounded.codePoint: Icons.music_note_rounded,
    Icons.code_rounded.codePoint: Icons.code_rounded,
    Icons.water_drop_rounded.codePoint: Icons.water_drop_rounded,
    Icons.directions_run_rounded.codePoint: Icons.directions_run_rounded,
    Icons.bed_rounded.codePoint: Icons.bed_rounded,
    Icons.self_improvement_rounded.codePoint: Icons.self_improvement_rounded,
  };

  // ⚡ Static Day Names: Bellekte her seferinde yeniden türetilmez
  static const Map<int, String> _dayNames = {
    1: 'Pzt',
    2: 'Sal',
    3: 'Çar',
    4: 'Per',
    5: 'Cum',
    6: 'Cmt',
    7: 'Paz',
  };

  IconData get icon => _iconMap[iconCodePoint] ?? Icons.star_rounded;

  String get frequencyText {
    switch (frequencyType) {
      case 1:
        return 'Hafta İçi';
      case 2:
        return 'Hafta Sonu';
      case 3:
        return '$intervalDays Günde Bir';
      case 4:
        final names = selectedWeekdays
            .map((d) => _dayNames[d])
            .whereType<String>()
            .join(', ');
        return names.isEmpty ? 'Haftalık' : names;
      case 0:
      default:
        return 'Her Gün';
    }
  }

  // Tarih saatini 00:00:00 yapacak yardımcı metot
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// ⚡ Hızlı Set dönüştürücü
  Set<DateTime> get _completedDatesSet =>
      completedDatesList.map((d) => _stripTime(d)).toSet();

  /// ⚡ OPTİMİZE EDİLDİ: Sort yapmadan tek geçişte en eski tarihi bulur
  DateTime get startDate {
    if (completedDatesList.isNotEmpty) {
      final earliest = completedDatesList.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      return _stripTime(earliest);
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
    return completedDatesList.any(
      (d) => _stripTime(d).isAtSameMomentAs(target),
    );
  }

  void toggleDate(DateTime date) {
    final target = _stripTime(date);
    final newList = List<DateTime>.from(completedDatesList);

    final index = newList.indexWhere(
      (d) => _stripTime(d).isAtSameMomentAs(target),
    );

    if (index != -1) {
      newList.removeAt(index);
    } else {
      newList.add(target);
    }

    completedDatesList = newList;
  }

  int get currentStreak {
    if (completedDatesList.isEmpty) return 0;

    final completedSet = _completedDatesSet;
    final today = _stripTime(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (!completedSet.contains(today) && !completedSet.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = completedSet.contains(today) ? today : yesterday;

    while (completedSet.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  double calculateCompletionRate({int lastDays = 30}) {
    if (completedDatesList.isEmpty || lastDays <= 0) return 0.0;

    final completedSet = _completedDatesSet;
    final today = _stripTime(DateTime.now());
    int completedCount = 0;

    for (int i = 0; i < lastDays; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (completedSet.contains(checkDate)) {
        completedCount++;
      }
    }

    final rate = (completedCount / lastDays) * 100;
    return rate > 100 ? 100.0 : double.parse(rate.toStringAsFixed(1));
  }

  int get totalCompletedDays => completedDatesList.length;
}
