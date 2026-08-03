import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/models/category_model.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/backup_service.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<Habit> habitsBox;
  late Box<CategoryModel> categoriesBox;

  var boxCounter = 0;

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'habitto_backup_tests_',
    );

    Hive.init(temporaryDirectory.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
  });

  setUp(() async {
    boxCounter++;

    habitsBox = await Hive.openBox<Habit>('backup_test_habits_$boxCounter');

    categoriesBox = await Hive.openBox<CategoryModel>(
      'backup_test_categories_$boxCounter',
    );
  });

  tearDown(() async {
    final habitsBoxName = habitsBox.name;
    final categoriesBoxName = categoriesBox.name;

    await habitsBox.close();
    await categoriesBox.close();

    await Hive.deleteBoxFromDisk(habitsBoxName);
    await Hive.deleteBoxFromDisk(categoriesBoxName);
  });

  tearDownAll(() async {
    await Hive.close();

    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('Backup export', () {
    test('includes all habit and category fields', () {
      final completionDate = DateTime(2026, 8, 3, 14, 30);
      final exportDate = DateTime(2026, 8, 3, 20);

      final habit = Habit(
        id: 'habit-1',
        title: 'Read',
        colorValue: 0xFF123456,
        category: 'Books',
        frequencyType: 4,
        intervalDays: 3,
        iconCodePoint: 0xe865,
        selectedWeekdays: [1, 3, 5],
        isNotificationEnabled: true,
        notificationHour: 9,
        notificationMinute: 45,
        completedDates: [completionDate],
      );

      final category = CategoryModel(
        id: 'category-1',
        name: 'Books',
        icon: '📚',
        colorValue: 0xFF654321,
        iconCodePoint: 0xe865,
      );

      final backup = BackupService.createBackupData(
        habits: [habit],
        categories: [category],
        exportDate: exportDate,
      );

      expect(backup['version'], BackupService.currentBackupVersion);
      expect(backup['exportDate'], exportDate.toIso8601String());

      final habitData = Map<String, dynamic>.from(
        (backup['habits'] as List).single as Map,
      );

      expect(habitData['id'], 'habit-1');
      expect(habitData['title'], 'Read');
      expect(habitData['category'], 'Books');
      expect(habitData['colorValue'], 0xFF123456);
      expect(habitData['frequencyType'], 4);
      expect(habitData['intervalDays'], 3);
      expect(habitData['iconCodePoint'], 0xe865);
      expect(habitData['selectedWeekdays'], [1, 3, 5]);
      expect(habitData['isNotificationEnabled'], isTrue);
      expect(habitData['notificationHour'], 9);
      expect(habitData['notificationMinute'], 45);
      expect(habitData['completedDates'], [completionDate.toIso8601String()]);

      final categoryData = Map<String, dynamic>.from(
        (backup['categories'] as List).single as Map,
      );

      expect(categoryData['id'], 'category-1');
      expect(categoryData['name'], 'Books');
      expect(categoryData['icon'], '📚');
      expect(categoryData['colorValue'], 0xFF654321);
      expect(categoryData['iconCodePoint'], 0xe865);
    });

    test('creates valid JSON', () {
      final jsonString = BackupService.createBackupJson(
        habits: const [],
        categories: const [],
        exportDate: DateTime(2026, 8, 3),
      );

      final decoded = jsonDecode(jsonString);

      expect(decoded, isA<Map>());
      expect(decoded['habits'], isEmpty);
      expect(decoded['categories'], isEmpty);
    });
  });

  group('Backup restore', () {
    test('restores all habit and category fields', () async {
      final completionDate = DateTime(2026, 8, 1);

      final jsonString = jsonEncode({
        'version': 1,
        'categories': [
          {
            'id': 'category-1',
            'name': 'Coding',
            'icon': '💻',
            'colorValue': 0xFF112233,
            'iconCodePoint': 0xe86f,
          },
        ],
        'habits': [
          {
            'id': 'habit-1',
            'title': 'Write code',
            'category': 'Coding',
            'colorValue': 0xFF445566,
            'frequencyType': 4,
            'intervalDays': 2,
            'iconCodePoint': 0xe86f,
            'selectedWeekdays': [1, 3, 5],
            'isNotificationEnabled': true,
            'notificationHour': 10,
            'notificationMinute': 15,
            'completedDates': [completionDate.toIso8601String()],
          },
        ],
      });

      final restored = await BackupService.restoreFromJson(
        jsonString,
        habitsBox,
        categoriesBox,
      );

      expect(restored, isTrue);
      expect(habitsBox.length, 1);
      expect(categoriesBox.length, 1);

      final habit = habitsBox.get('habit-1');

      expect(habit, isNotNull);
      expect(habit!.title, 'Write code');
      expect(habit.category, 'Coding');
      expect(habit.colorValue, 0xFF445566);
      expect(habit.frequencyType, 4);
      expect(habit.intervalDays, 2);
      expect(habit.iconCodePoint, 0xe86f);
      expect(habit.selectedWeekdays, [1, 3, 5]);
      expect(habit.isNotificationEnabled, isTrue);
      expect(habit.notificationHour, 10);
      expect(habit.notificationMinute, 15);
      expect(habit.completedDatesList, [completionDate]);

      final category = categoriesBox.get('category-1');

      expect(category, isNotNull);
      expect(category!.name, 'Coding');
      expect(category.icon, '💻');
      expect(category.colorValue, 0xFF112233);
      expect(category.iconCodePoint, 0xe86f);
    });

    test('keeps unrelated existing records', () async {
      await habitsBox.put(
        'existing-habit',
        Habit(
          id: 'existing-habit',
          title: 'Existing habit',
          colorValue: 0xFF6366F1,
        ),
      );

      final jsonString = jsonEncode({
        'version': 1,
        'habits': [
          {'id': 'restored-habit', 'title': 'Restored habit'},
        ],
      });

      final restored = await BackupService.restoreFromJson(
        jsonString,
        habitsBox,
        categoriesBox,
      );

      expect(restored, isTrue);
      expect(habitsBox.length, 2);
      expect(habitsBox.get('existing-habit'), isNotNull);
      expect(habitsBox.get('restored-habit'), isNotNull);
    });

    test(
      'restoring the same backup twice does not duplicate records',
      () async {
        final jsonString = jsonEncode({
          'version': 1,
          'habits': [
            {'id': 'habit-1', 'title': 'Repeated habit'},
          ],
        });

        final firstRestore = await BackupService.restoreFromJson(
          jsonString,
          habitsBox,
          categoriesBox,
        );

        final secondRestore = await BackupService.restoreFromJson(
          jsonString,
          habitsBox,
          categoriesBox,
        );

        expect(firstRestore, isTrue);
        expect(secondRestore, isTrue);
        expect(habitsBox.length, 1);
        expect(habitsBox.get('habit-1')!.title, 'Repeated habit');
      },
    );

    test('invalid backup does not partially change stored data', () async {
      await habitsBox.put(
        'existing-habit',
        Habit(
          id: 'existing-habit',
          title: 'Existing habit',
          colorValue: 0xFF6366F1,
        ),
      );

      await categoriesBox.put(
        'existing-category',
        CategoryModel(id: 'existing-category', name: 'Existing category'),
      );

      final invalidJson = jsonEncode({
        'categories': [
          {'id': 'new-category', 'name': 'New category'},
        ],
        'habits': [
          {
            'id': 'broken-habit',
            // title intentionally missing
          },
        ],
      });

      final restored = await BackupService.restoreFromJson(
        invalidJson,
        habitsBox,
        categoriesBox,
      );

      expect(restored, isFalse);

      expect(habitsBox.length, 1);
      expect(habitsBox.get('existing-habit'), isNotNull);
      expect(habitsBox.get('broken-habit'), isNull);

      expect(categoriesBox.length, 1);
      expect(categoriesBox.get('existing-category'), isNotNull);
      expect(categoriesBox.get('new-category'), isNull);
    });

    test('older backups restore with safe default values', () async {
      final legacyJson = jsonEncode({
        'version': 1,
        'habits': [
          {'id': 'legacy-habit', 'title': 'Legacy habit'},
        ],
      });

      final restored = await BackupService.restoreFromJson(
        legacyJson,
        habitsBox,
        categoriesBox,
      );

      expect(restored, isTrue);

      final habit = habitsBox.get('legacy-habit');

      expect(habit, isNotNull);
      expect(habit!.category, 'Genel');
      expect(habit.colorValue, 0xFF6366F1);
      expect(habit.frequencyType, 0);
      expect(habit.intervalDays, 2);
      expect(habit.isNotificationEnabled, isFalse);
      expect(habit.notificationHour, isNull);
      expect(habit.notificationMinute, isNull);
      expect(habit.completedDatesList, isEmpty);
    });

    test('malformed JSON is rejected', () async {
      final restored = await BackupService.restoreFromJson(
        '{not valid json',
        habitsBox,
        categoriesBox,
      );

      expect(restored, isFalse);
      expect(habitsBox, isEmpty);
      expect(categoriesBox, isEmpty);
    });
  });
}
