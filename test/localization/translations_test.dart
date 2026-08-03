import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readTranslations(String path) {
  final rawContent = File(path).readAsStringSync();
  final decoded = jsonDecode(rawContent);

  if (decoded is! Map<String, dynamic>) {
    throw StateError('$path must contain a JSON object.');
  }

  return decoded;
}

List<String> _sorted(Iterable<String> values) {
  return values.toList()..sort();
}

Set<String> _findLiteralTranslationKeysUsedInLib() {
  final usedKeys = <String>{};

  final translationPatterns = <RegExp>[
    RegExp(r"'([^'\r\n]+)'\.tr\("),
    RegExp(r'"([^"\r\n]+)"\.tr\('),
  ];

  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));

  for (final file in dartFiles) {
    final source = file.readAsStringSync();

    for (final pattern in translationPatterns) {
      for (final match in pattern.allMatches(source)) {
        final key = match.group(1)?.trim();

        if (key != null && key.isNotEmpty) {
          usedKeys.add(key);
        }
      }
    }
  }

  return usedKeys;
}

void main() {
  group('Translation files', () {
    late Map<String, dynamic> english;
    late Map<String, dynamic> turkish;

    setUpAll(() {
      english = _readTranslations('assets/translations/en.json');
      turkish = _readTranslations('assets/translations/tr.json');
    });

    test('English and Turkish files contain the same keys', () {
      final englishKeys = english.keys.toSet();
      final turkishKeys = turkish.keys.toSet();

      final missingInEnglish = _sorted(turkishKeys.difference(englishKeys));

      final missingInTurkish = _sorted(englishKeys.difference(turkishKeys));

      expect(
        missingInEnglish,
        isEmpty,
        reason: 'Missing from en.json: ${missingInEnglish.join(', ')}',
      );

      expect(
        missingInTurkish,
        isEmpty,
        reason: 'Missing from tr.json: ${missingInTurkish.join(', ')}',
      );
    });

    test('translation values are non-empty strings', () {
      final invalidEnglishEntries = _sorted(
        english.entries
            .where(
              (entry) =>
                  entry.value is! String ||
                  (entry.value as String).trim().isEmpty,
            )
            .map((entry) => entry.key),
      );

      final invalidTurkishEntries = _sorted(
        turkish.entries
            .where(
              (entry) =>
                  entry.value is! String ||
                  (entry.value as String).trim().isEmpty,
            )
            .map((entry) => entry.key),
      );

      expect(
        invalidEnglishEntries,
        isEmpty,
        reason:
            'Empty or invalid values in en.json: '
            '${invalidEnglishEntries.join(', ')}',
      );

      expect(
        invalidTurkishEntries,
        isEmpty,
        reason:
            'Empty or invalid values in tr.json: '
            '${invalidTurkishEntries.join(', ')}',
      );
    });

    test('literal translation keys used in lib exist in both files', () {
      final usedKeys = _findLiteralTranslationKeysUsedInLib();

      final missingInEnglish = _sorted(
        usedKeys.difference(english.keys.toSet()),
      );

      final missingInTurkish = _sorted(
        usedKeys.difference(turkish.keys.toSet()),
      );

      expect(
        missingInEnglish,
        isEmpty,
        reason:
            'Keys used in Dart but missing from en.json: '
            '${missingInEnglish.join(', ')}',
      );

      expect(
        missingInTurkish,
        isEmpty,
        reason:
            'Keys used in Dart but missing from tr.json: '
            '${missingInTurkish.join(', ')}',
      );
    });
  });
}
