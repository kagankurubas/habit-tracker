import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

import '../models/category_model.dart';
import '../models/habit.dart';

class BackupService {
  static const int currentBackupVersion = 1;

  static Map<String, dynamic> createBackupData({
    required Iterable<Habit> habits,
    required Iterable<CategoryModel> categories,
    DateTime? exportDate,
  }) {
    final habitsData = habits
        .map(
          (habit) => {
            'id': habit.id,
            'title': habit.title,
            'category': habit.category,
            'colorValue': habit.colorValue,
            'frequencyType': habit.frequencyType,
            'intervalDays': habit.intervalDays,
            'iconCodePoint': habit.iconCodePoint,
            'selectedWeekdays': habit.selectedWeekdays,
            'isNotificationEnabled': habit.isNotificationEnabled,
            'notificationHour': habit.notificationHour,
            'notificationMinute': habit.notificationMinute,
            'completedDates': habit.completedDatesList
                .map((date) => date.toIso8601String())
                .toList(),
          },
        )
        .toList();

    final categoriesData = categories
        .map(
          (category) => {
            'id': category.id,
            'name': category.name,
            'icon': category.icon,
            'colorValue': category.colorValue,
            'iconCodePoint': category.iconCodePoint,
          },
        )
        .toList();

    return {
      'version': currentBackupVersion,
      'exportDate': (exportDate ?? DateTime.now()).toIso8601String(),
      'categories': categoriesData,
      'habits': habitsData,
    };
  }

  static String createBackupJson({
    required Iterable<Habit> habits,
    required Iterable<CategoryModel> categories,
    DateTime? exportDate,
  }) {
    return jsonEncode(
      createBackupData(
        habits: habits,
        categories: categories,
        exportDate: exportDate,
      ),
    );
  }

  static Future<void> exportDataToJson(
    Box<Habit> habitsBox,
    Box<CategoryModel> categoriesBox,
  ) async {
    try {
      final jsonString = createBackupJson(
        habits: habitsBox.values,
        categories: categoriesBox.values,
      );

      final fileName =
          'habit_tracker_backup_'
          '${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();

        html.Url.revokeObjectUrl(url);
        return;
      }

      final tempDirectory = await getTemporaryDirectory();
      final filePath = '${tempDirectory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'backup_file_share_text'.tr(),
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Dışa aktarma sırasında hata: $error');
      }

      rethrow;
    }
  }

  static Future<bool> restoreFromJson(
    String jsonString,
    Box<Habit> habitsBox,
    Box<CategoryModel> categoriesBox,
  ) async {
    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map) {
        return false;
      }

      final data = Map<String, dynamic>.from(decoded);

      final rawHabits = data['habits'];
      final rawCategories = data['categories'];

      if (rawHabits is! List) {
        return false;
      }

      if (rawCategories != null && rawCategories is! List) {
        return false;
      }

      final parsedCategories = <CategoryModel>[];
      final parsedHabits = <Habit>[];

      if (rawCategories is List) {
        for (final rawCategory in rawCategories) {
          if (rawCategory is! Map) {
            return false;
          }

          final categoryData = Map<String, dynamic>.from(rawCategory);

          final id = categoryData['id'];
          final name = categoryData['name'];

          if (id is! String || name is! String) {
            return false;
          }

          parsedCategories.add(
            CategoryModel(
              id: id,
              name: name,
              icon: categoryData['icon'] is String
                  ? categoryData['icon'] as String
                  : '📌',
              colorValue: _readInt(categoryData['colorValue'], 0xFF6366F1),
              iconCodePoint: _readInt(categoryData['iconCodePoint'], 0xe3af),
            ),
          );
        }
      }

      for (final rawHabit in rawHabits) {
        if (rawHabit is! Map) {
          return false;
        }

        final habitData = Map<String, dynamic>.from(rawHabit);

        final id = habitData['id'];
        final title = habitData['title'];

        if (id is! String || title is! String) {
          return false;
        }

        final selectedWeekdays = _readIntList(habitData['selectedWeekdays']);

        if (selectedWeekdays == null && habitData['selectedWeekdays'] != null) {
          return false;
        }

        final completedDates = _readDateList(habitData['completedDates']);

        if (completedDates == null && habitData['completedDates'] != null) {
          return false;
        }

        parsedHabits.add(
          Habit(
            id: id,
            title: title,
            colorValue: _readInt(habitData['colorValue'], 0xFF6366F1),
            category: habitData['category'] is String
                ? habitData['category'] as String
                : 'Genel',
            frequencyType: _readInt(habitData['frequencyType'], 0),
            intervalDays: _readInt(habitData['intervalDays'], 2),
            iconCodePoint: _readInt(habitData['iconCodePoint'], 0xe3af),
            selectedWeekdays: selectedWeekdays,
            isNotificationEnabled: habitData['isNotificationEnabled'] is bool
                ? habitData['isNotificationEnabled'] as bool
                : false,
            notificationHour: _readNullableInt(habitData['notificationHour']),
            notificationMinute: _readNullableInt(
              habitData['notificationMinute'],
            ),
            completedDates: completedDates ?? <DateTime>[],
          ),
        );
      }

      // Veriyi ancak bütün JSON başarıyla doğrulandıktan sonra yazıyoruz.
      // Böylece bozuk bir dosya yarım restore oluşturmaz.
      for (final category in parsedCategories) {
        await categoriesBox.put(category.id, category);
      }

      for (final habit in parsedHabits) {
        await habitsBox.put(habit.id, habit);
      }

      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('İçe aktarma sırasında hata: $error');
      }

      return false;
    }
  }

  static Future<bool> importDataFromJson(
    Box<Habit> habitsBox,
    Box<CategoryModel> categoriesBox,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final selectedFile = result.files.single;
      String jsonString;

      if (kIsWeb) {
        final bytes = selectedFile.bytes;

        if (bytes == null) {
          return false;
        }

        jsonString = utf8.decode(bytes);
      } else {
        final path = selectedFile.path;

        if (path == null) {
          return false;
        }

        jsonString = await File(path).readAsString();
      }

      return restoreFromJson(jsonString, habitsBox, categoriesBox);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('İçe aktarma sırasında hata: $error');
      }

      return false;
    }
  }

  static int _readInt(dynamic value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  static List<int>? _readIntList(dynamic value) {
    if (value == null) {
      return <int>[];
    }

    if (value is! List) {
      return null;
    }

    final result = <int>[];

    for (final item in value) {
      if (item is! num) {
        return null;
      }

      result.add(item.toInt());
    }

    return result;
  }

  static List<DateTime>? _readDateList(dynamic value) {
    if (value == null) {
      return <DateTime>[];
    }

    if (value is! List) {
      return null;
    }

    final result = <DateTime>[];

    for (final item in value) {
      if (item is! String) {
        return null;
      }

      result.add(DateTime.parse(item));
    }

    return result;
  }
}
