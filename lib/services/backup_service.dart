import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:universal_html/html.dart' as html;
import '../models/habit.dart';
import '../models/category_model.dart';

class BackupService {
  // 📤 1. EXPORT AS JSON (WEB + MOBILE COMPATIBLE)
  static Future<void> exportDataToJson(
    Box<Habit> habitsBox,
    Box<CategoryModel> categoriesBox,
  ) async {
    try {
      final habitsData = habitsBox.values
          .map(
            (h) => {
              'id': h.id,
              'title': h.title,
              'category': h.category,
              'colorValue': h.colorValue,
              'frequencyType': h.frequencyType,
              'intervalDays': h.intervalDays,
              'iconCodePoint': h.iconCodePoint,
              'selectedWeekdays': h.selectedWeekdays,
              'isNotificationEnabled': h.isNotificationEnabled,
              'completedDates': h.completedDatesList
                  .map((d) => d.toIso8601String())
                  .toList(),
            },
          )
          .toList();

      final categoriesData = categoriesBox.values
          .map((c) => {'id': c.id, 'name': c.name, 'icon': c.icon})
          .toList();

      final backupData = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'categories': categoriesData,
        'habits': habitsData,
      };

      final jsonString = jsonEncode(backupData);
      final fileName =
          'habit_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json';

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

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'backup_file_share_text'.tr(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Dışa aktarma sırasında hata: $e');
      }
      rethrow;
    }
  }

  // 📥 2. IMPORT JSON BACKUP (RESTORE)
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

      if (result != null && result.files.isNotEmpty) {
        final selectedFile = result.files.single;
        String jsonString;

        if (kIsWeb) {
          if (selectedFile.bytes == null) return false;
          jsonString = utf8.decode(selectedFile.bytes!);
        } else {
          if (selectedFile.path == null) return false;
          final file = File(selectedFile.path!);
          jsonString = await file.readAsString();
        }

        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (data.containsKey('habits')) {
          if (data.containsKey('categories')) {
            final List categoriesJson = data['categories'];
            for (final c in categoriesJson) {
              final cat = CategoryModel(
                id: c['id'],
                name: c['name'],
                icon: c['icon'] ?? '📌',
              );
              await categoriesBox.put(cat.id, cat);
            }
          }

          final List habitsJson = data['habits'];
          for (final h in habitsJson) {
            final habit = Habit(
              id: h['id'],
              title: h['title'],
              colorValue: h['colorValue'] ?? 0xFF6366F1,
              category: h['category'] ?? 'Genel',
              frequencyType: h['frequencyType'] ?? 0,
              intervalDays: h['intervalDays'] ?? 2,
              iconCodePoint: h['iconCodePoint'] ?? 0xe3af,
              selectedWeekdays: h['selectedWeekdays'] != null
                  ? List<int>.from(h['selectedWeekdays'])
                  : null,
              isNotificationEnabled: h['isNotificationEnabled'] ?? false,
              completedDates: h['completedDates'] != null
                  ? (h['completedDates'] as List)
                        .map((d) => DateTime.parse(d))
                        .toList()
                  : [],
            );
            await habitsBox.put(habit.id, habit);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('İçe aktarma sırasında hata: $e');
      }
      return false;
    }
  }
}
