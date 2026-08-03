import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/models/badge_model.dart';
import 'package:habit_tracker/models/habit.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  HabitBadge badge(String id) {
    return allBadges.firstWhere((badge) => badge.id == id);
  }

  Habit createHabit({
    String id = 'habit',
    String category = 'Genel',
    List<DateTime>? completedDates,
  }) {
    return Habit(
      id: id,
      title: 'Test Habit',
      colorValue: 0xFF6366F1,
      category: category,
      completedDates: completedDates,
    );
  }

  group('Badge definitions', () {
    test('all badge ids are unique', () {
      final ids = allBadges.map((badge) => badge.id).toList();

      expect(ids.toSet().length, ids.length);
    });
  });

  group('General badges', () {
    test('first step unlocks after one completion', () {
      final lockedHabit = createHabit();
      final completedHabit = createHabit(completedDates: [today]);

      expect(badge('first_step').isUnlocked([lockedHabit]), isFalse);
      expect(badge('first_step').isUnlocked([completedHabit]), isTrue);
    });

    test('three-day streak badge unlocks at three consecutive days', () {
      final habit = createHabit(
        completedDates: [
          today,
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
        ],
      );

      expect(badge('streak_3').isUnlocked([habit]), isTrue);
      expect(badge('streak_7').isUnlocked([habit]), isFalse);
    });

    test('completion badge uses total completions across habits', () {
      final firstHabit = createHabit(
        id: 'first',
        completedDates: List.generate(
          6,
          (index) => today.subtract(Duration(days: index)),
        ),
      );

      final secondHabit = createHabit(
        id: 'second',
        completedDates: List.generate(
          4,
          (index) => today.subtract(Duration(days: index + 10)),
        ),
      );

      expect(
        badge('completion_10').isUnlocked([firstHabit, secondHabit]),
        isTrue,
      );
    });

    test('perfect day requires at least three completed targets', () {
      final completedHabits = List.generate(
        3,
        (index) => createHabit(id: 'completed-$index', completedDates: [today]),
      );

      expect(badge('perfect_day').isUnlocked(completedHabits), isTrue);

      final incompleteHabits = [
        completedHabits[0],
        completedHabits[1],
        createHabit(id: 'incomplete'),
      ];

      expect(badge('perfect_day').isUnlocked(incompleteHabits), isFalse);
    });
  });

  group('Category badges', () {
    test('game development badge accepts category without period', () {
      final habit = createHabit(category: 'Oyun Dev', completedDates: [today]);

      expect(badge('gamedev_builder').isUnlocked([habit]), isTrue);
    });

    test('category completions ignore unrelated categories', () {
      final codingHabit = createHabit(
        category: 'Kodlama',
        completedDates: List.generate(
          4,
          (index) => today.subtract(Duration(days: index)),
        ),
      );

      final musicHabit = createHabit(
        category: 'Müzik',
        completedDates: List.generate(
          10,
          (index) => today.subtract(Duration(days: index)),
        ),
      );

      expect(
        badge('code_bug_hunter').isUnlocked([codingHabit, musicHabit]),
        isFalse,
      );

      codingHabit.completedDatesList.add(
        today.subtract(const Duration(days: 20)),
      );

      expect(
        badge('code_bug_hunter').isUnlocked([codingHabit, musicHabit]),
        isTrue,
      );
    });
  });

  group('Secret badges', () {
    test('completion time is preserved for early bird badge', () {
      final habit = createHabit();
      final earlyCompletion = DateTime(
        today.year,
        today.month,
        today.day,
        6,
        30,
      );

      habit.toggleDate(earlyCompletion);

      expect(habit.completedDatesList.single.hour, 6);
      expect(badge('secret_early_bird').isUnlocked([habit]), isTrue);
    });

    test('08:00 does not unlock early bird badge', () {
      final habit = createHabit(
        completedDates: [DateTime(today.year, today.month, today.day, 8)],
      );

      expect(badge('secret_early_bird').isUnlocked([habit]), isFalse);
    });

    test('exact midnight does not unlock night owl badge', () {
      final habit = createHabit(
        completedDates: [DateTime(today.year, today.month, today.day)],
      );

      expect(badge('secret_night_owl').isUnlocked([habit]), isFalse);
    });

    test('completion shortly after midnight unlocks night owl badge', () {
      final habit = createHabit(
        completedDates: [DateTime(today.year, today.month, today.day, 0, 1)],
      );

      expect(badge('secret_night_owl').isUnlocked([habit]), isTrue);
    });
  });
}
