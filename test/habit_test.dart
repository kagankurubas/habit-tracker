import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  group('Habit completion', () {
    test('completed date can be added and removed', () {
      final habit = Habit(
        id: 'test-habit',
        title: 'Test Habit',
        colorValue: 0xFF6366F1,
      );

      final testDate = DateTime(2026, 7, 28);

      habit.toggleDate(testDate);

      expect(habit.isCompletedOn(testDate), isTrue);
      expect(habit.totalCompletedDays, 1);

      habit.toggleDate(testDate);

      expect(habit.isCompletedOn(testDate), isFalse);
      expect(habit.totalCompletedDays, 0);
    });

    test('times on the same calendar day are treated as one completion', () {
      final habit = Habit(
        id: 'same-day-habit',
        title: 'Same Day Habit',
        colorValue: 0xFF6366F1,
      );

      final morning = DateTime(2026, 7, 28, 8, 30);
      final evening = DateTime(2026, 7, 28, 22, 15);

      habit.toggleDate(morning);

      expect(habit.isCompletedOn(evening), isTrue);
      expect(habit.totalCompletedDays, 1);

      habit.toggleDate(evening);

      expect(habit.totalCompletedDays, 0);
    });
  });

  group('Habit scheduling', () {
    final startDate = DateTime(2026, 8, 3); // Monday

    test('daily habit targets every day from its start date', () {
      final habit = Habit(
        id: 'daily-habit',
        title: 'Daily Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 0,
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 3)), isTrue);
      expect(habit.isTargetDate(DateTime(2026, 8, 4)), isTrue);
      expect(habit.isTargetDate(DateTime(2026, 8, 8)), isTrue);
    });

    test('weekday habit targets Monday through Friday only', () {
      final habit = Habit(
        id: 'weekday-habit',
        title: 'Weekday Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 1,
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 3)), isTrue); // Monday
      expect(habit.isTargetDate(DateTime(2026, 8, 7)), isTrue); // Friday
      expect(habit.isTargetDate(DateTime(2026, 8, 8)), isFalse); // Saturday
      expect(habit.isTargetDate(DateTime(2026, 8, 9)), isFalse); // Sunday
    });

    test('weekend habit targets Saturday and Sunday only', () {
      final habit = Habit(
        id: 'weekend-habit',
        title: 'Weekend Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 2,
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 7)), isFalse); // Friday
      expect(habit.isTargetDate(DateTime(2026, 8, 8)), isTrue); // Saturday
      expect(habit.isTargetDate(DateTime(2026, 8, 9)), isTrue); // Sunday
      expect(habit.isTargetDate(DateTime(2026, 8, 10)), isFalse); // Monday
    });

    test('interval habit targets every configured number of days', () {
      final habit = Habit(
        id: 'interval-habit',
        title: 'Interval Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 3,
        intervalDays: 3,
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 3)), isTrue); // Day 0
      expect(habit.isTargetDate(DateTime(2026, 8, 4)), isFalse); // Day 1
      expect(habit.isTargetDate(DateTime(2026, 8, 5)), isFalse); // Day 2
      expect(habit.isTargetDate(DateTime(2026, 8, 6)), isTrue); // Day 3
      expect(habit.isTargetDate(DateTime(2026, 8, 9)), isTrue); // Day 6
    });

    test('specific-day habit targets only selected weekdays', () {
      final habit = Habit(
        id: 'specific-days-habit',
        title: 'Specific Days Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 4,
        selectedWeekdays: [1, 3, 5],
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 3)), isTrue); // Monday
      expect(habit.isTargetDate(DateTime(2026, 8, 4)), isFalse); // Tuesday
      expect(habit.isTargetDate(DateTime(2026, 8, 5)), isTrue); // Wednesday
      expect(habit.isTargetDate(DateTime(2026, 8, 7)), isTrue); // Friday
      expect(habit.isTargetDate(DateTime(2026, 8, 8)), isFalse); // Saturday
    });

    test('dates before the habit start date are not targets', () {
      final habit = Habit(
        id: 'future-habit',
        title: 'Future Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 0,
        completedDates: [startDate],
      );

      expect(habit.isTargetDate(DateTime(2026, 8, 2)), isFalse);
      expect(habit.isTargetDate(startDate), isTrue);
    });
  });
}
