import 'package:hive/hive.dart';

class BadgeService {
  const BadgeService._();

  static Future<bool> claimIfNew(
    Box<dynamic> settingsBox,
    String badgeId,
  ) async {
    final key = 'badge_shown_$badgeId';

    if (settingsBox.get(key, defaultValue: false) == true) {
      return false;
    }

    await settingsBox.put(key, true);
    return true;
  }
}
