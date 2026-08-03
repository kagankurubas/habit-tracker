import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/services/badge_service.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<dynamic> settingsBox;

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'habitto_badge_tests_',
    );

    Hive.init(temporaryDirectory.path);
  });

  setUp(() async {
    settingsBox = await Hive.openBox<dynamic>(
      'badge_settings_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    final boxName = settingsBox.name;

    await settingsBox.close();
    await Hive.deleteBoxFromDisk(boxName);
  });

  tearDownAll(() async {
    await Hive.close();

    if (temporaryDirectory.existsSync()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('new badge can be claimed once', () async {
    final firstClaim = await BadgeService.claimIfNew(settingsBox, 'first_step');

    final secondClaim = await BadgeService.claimIfNew(
      settingsBox,
      'first_step',
    );

    expect(firstClaim, isTrue);
    expect(secondClaim, isFalse);
    expect(settingsBox.get('badge_shown_first_step'), isTrue);
  });

  test('different badges are tracked independently', () async {
    expect(await BadgeService.claimIfNew(settingsBox, 'streak_3'), isTrue);

    expect(await BadgeService.claimIfNew(settingsBox, 'streak_7'), isTrue);

    expect(await BadgeService.claimIfNew(settingsBox, 'streak_3'), isFalse);
  });
}
