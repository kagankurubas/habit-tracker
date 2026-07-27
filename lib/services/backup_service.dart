import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html; // 👈 Web indirmeleri için
import '../models/habit.dart';
import '../models/category_model.dart';

class BackupService {
  // 📤 1. JSON OLARAK DIŞA AKTAR (WEB + MOBIL UYUMLU)
  static Future<void> exportDataToJson(
      Box<Habit> habitsBox, Box<CategoryModel> categoriesBox) async {
    try {
      final habitsData = habitsBox.values
          .map((h) => {
                'id': h.id,
                'title': h.title,
                'category': h.category,
                'colorValue': h.colorValue,
                'frequencyType': h.frequencyType,
                'intervalDays': h.intervalDays,
                'iconCodePoint': h.iconCodePoint,
                'selectedWeekdays': h.selectedWeekdays,
                'isNotificationEnabled': h.isNotificationEnabled,
                'completedDates':
                    h.completedDatesList.map((d) => d.toIso8601String()).toList(),
              })
          .toList();

      final categoriesData = categoriesBox.values
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'icon': c.icon,
              })
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

      // 🌐 A) CHROME (WEB) İÇİN BROWSER DOWNLOAD
      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        // 👈 "final anchor =" kelimesini çıkardık, doğrudan çalıştırıyoruz:
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
          
        html.Url.revokeObjectUrl(url);
        return;
      }

      // 📱 B) MOBİL / DESKTOP İÇİN SHARE EKRANI
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(filePath)],
          text: 'Habit Tracker Veri Yedeği (JSON)');
    } catch (e) {
      rethrow;
    }
  }

  // 📥 2. JSON YEDEĞİNİ İÇE AKTAR (RESTORE)
  static Future<bool> importDataFromJson(
      Box<Habit> habitsBox, Box<CategoryModel> categoriesBox) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb, // 👈 Web ortamında byte okumak için
      );

      if (result != null && result.files.single.bytes != null ||
          (result?.files.single.path != null)) {
        String jsonString;

        if (kIsWeb) {
          jsonString = utf8.decode(result!.files.single.bytes!);
        } else {
          final file = File(result!.files.single.path!);
          jsonString = await file.readAsString();
        }

        final Map<String, dynamic> data = jsonDecode(jsonString);

        if (data.containsKey('habits')) {
          // 🏷️ KATEGORİLERİ İÇE AKTAR
          if (data.containsKey('categories')) {
            final List categoriesJson = data['categories'];
            for (var c in categoriesJson) {
              final cat = CategoryModel(
                id: c['id'],
                name: c['name'],
                icon: c['icon'] ?? '📌',
              );
              await categoriesBox.put(cat.id, cat);
            }
          }

          // 📝 HABIT'LERİ İÇE AKTAR
          final List habitsJson = data['habits'];
          for (var h in habitsJson) {
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
      return false;
    }
  }
}