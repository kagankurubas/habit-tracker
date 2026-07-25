import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id; // Sadece id final kalabilir

  @HiveField(1)
  String title; // 👈 'final' kelimesini kaldırdık

  @HiveField(2)
  int colorValue; // 👈 'final' kelimesini kaldırdık

  @HiveField(3)
  List<DateTime> completedDatesList;

  @HiveField(4)
  int frequencyType; // 👈 'final' kelimesini kaldırdık

  @HiveField(5)
  int intervalDays; // 👈 'final' kelimesini kaldırdık

  @HiveField(6)
  List<int> selectedWeekdays; // 👈 'final' kelimesini kaldırdık

  @HiveField(7)
  int iconCodePoint; // 👈 'final' kelimesini kaldırdık

  Habit({
    required this.id,
    required this.title,
    required this.colorValue,
    this.frequencyType = 0,
    this.intervalDays = 2,
    this.iconCodePoint = 0xe3af, // Varsayılan: fitness_center veya local_activity
    List<int>? selectedWeekdays,
    List<DateTime>? completedDates,
  })  : selectedWeekdays = selectedWeekdays ?? [1, 3, 5],
        completedDatesList = completedDates ?? [];

  Color get color => Color(colorValue);

  // Başına const Koyma!
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

  DateTime get startDate {
    if (completedDatesList.isNotEmpty) {
      final sorted = List<DateTime>.from(completedDatesList)..sort();
      return DateTime(sorted.first.year, sorted.first.month, sorted.first.day);
    }
    return DateTime.now();
  }

  bool isTargetDate(DateTime date) {
      final target = DateTime(date.year, date.month, date.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);

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
    final target = DateTime(date.year, date.month, date.day);
    return completedDatesList.any(
      (d) => d.year == target.year && d.month == target.month && d.day == target.day,
    );
  }
  // 📊 Mevcut üst üste tamamlanma serisini (streak) hesaplar
  int get currentStreak {
    if (completedDatesList.isEmpty) return 0;

    // Tarihleri sıralayalım (en yeniden en eskiye)
    final sortedDates = completedDatesList.map((d) => DateTime(d.year, d.month, d.day)).toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Eğer bugün veya dün tamamlanmadıysa seri bozulmuştur (0)
    if (!sortedDates.contains(today) && !sortedDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = sortedDates.contains(today) ? today : yesterday;

    while (sortedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void toggleDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);

    // Yeni bir liste kopyası oluşturuyoruz
    final newList = List<DateTime>.from(completedDatesList);

    final index = newList.indexWhere(
      (d) => d.year == target.year && d.month == target.month && d.day == target.day,
    );

    if (index != -1) {
      newList.removeAt(index);
    } else {
      newList.add(target);
    }

    // Değişken final olmadığı için artık yeni listeyi direkt eşitleyebiliyoruz!
    completedDatesList = newList; 
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
  // 📈 Son X gün içindeki başarı yüzdesini hesaplar (Örn: lastDays = 30)
  double calculateCompletionRate({int lastDays = 30}) {
    if (completedDatesList.isEmpty) return 0.0;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    int completedCount = 0;

    for (int i = 0; i < lastDays; i++) {
      final checkDate = normalizedToday.subtract(Duration(days: i));
      if (isCompletedOn(checkDate)) {
        completedCount++;
      }
    }

    return (completedCount / lastDays) * 100;
  }

  // 🔢 Toplam kaç gün tamamlandığını döndürür
  int get totalCompletedDays => completedDatesList.length;
}