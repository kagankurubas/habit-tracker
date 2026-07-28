import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  group('Habit model', () {
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

    test('daily habit targets every day', () {
      final habit = Habit(
        id: 'daily-habit',
        title: 'Daily Habit',
        colorValue: 0xFF6366F1,
        frequencyType: 0,
      );

      expect(habit.isTargetDate(DateTime.now()), isTrue);
    });
  });
}
