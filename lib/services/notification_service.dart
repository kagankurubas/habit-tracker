import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';
import 'motivation_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<String?> selectNotificationStream =
      ValueNotifier<String?>(null);

  static const String _channelId = 'habit_reminders';

  static NotificationDetails get _notificationDetails => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'notification_channel_name'.tr(),
      channelDescription: 'notification_channel_desc'.tr(),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final permissionGranted = await androidImplementation
          .requestNotificationsPermission();

      debugPrint(
        'Bildirim izni: ${permissionGranted == true ? "verildi" : "verilmedi"}',
      );
    }
  }

  static Future<String?> getInitialNotificationPayload() async {
    if (kIsWeb) return null;

    final launchDetails = await NotificationService()._notificationsPlugin
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      return launchDetails?.notificationResponse?.payload;
    }

    return null;
  }

  static Future<void> _onNotificationResponse(
    NotificationResponse response,
  ) async {
    if (kIsWeb) return;

    final payload = response.payload;

    if (payload != null && payload.isNotEmpty) {
      selectNotificationStream.value = payload;
    }
  }

  Future<void> showInstantTestNotification() async {
    if (kIsWeb) return;

    await _notificationsPlugin.show(
      id: 999,
      title: 'test_notification_title'.tr(),
      body: MotivationService.getRandomQuote(),
      notificationDetails: _notificationDetails,
    );
  }

  Future<void> cancelHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    final pendingNotifications = await _notificationsPlugin
        .pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload == habit.id) {
        await _notificationsPlugin.cancel(id: notification.id);
      }
    }

    await _notificationsPlugin.cancel(id: habit.id.hashCode.abs());

    for (int weekday = 1; weekday <= 7; weekday++) {
      await _notificationsPlugin.cancel(
        id: (habit.id.hashCode ^ weekday).abs(),
      );
    }
  }

  int _createNotificationId(String habitId, int salt) {
    final id = Object.hash(habitId, salt) & 0x7fffffff;
    return id == 0 ? 1 : id;
  }

  tz.TZDateTime _nextNotificationTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _scheduleNotification({
    required Habit habit,
    required int id,
    required tz.TZDateTime date,
    DateTimeComponents? repeatComponents,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: '🔥 ${habit.title}',
      body: MotivationService.getRandomQuote(),
      scheduledDate: date,
      notificationDetails: _notificationDetails,

      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents: repeatComponents,
      payload: habit.id,
    );
  }

  Future<void> scheduleHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    await cancelHabitNotification(habit);

    if (!habit.isNotificationEnabled ||
        habit.notificationHour == null ||
        habit.notificationMinute == null) {
      return;
    }

    final initialDate = _nextNotificationTime(
      habit.notificationHour!,
      habit.notificationMinute!,
    );

    switch (habit.frequencyType) {
      case 0:
        await _scheduleNotification(
          habit: habit,
          id: _createNotificationId(habit.id, 0),
          date: initialDate,
          repeatComponents: DateTimeComponents.time,
        );
        break;

      case 1:
        await _scheduleWeeklyNotifications(habit, initialDate, const [
          1,
          2,
          3,
          4,
          5,
        ]);
        break;

      case 2:
        await _scheduleWeeklyNotifications(habit, initialDate, const [6, 7]);
        break;

      case 3:
        await _scheduleIntervalNotifications(habit, initialDate);
        break;

      case 4:
        await _scheduleWeeklyNotifications(
          habit,
          initialDate,
          habit.selectedWeekdays,
        );
        break;

      default:
        await _scheduleNotification(
          habit: habit,
          id: _createNotificationId(habit.id, 0),
          date: initialDate,
          repeatComponents: DateTimeComponents.time,
        );
    }
  }

  Future<void> _scheduleWeeklyNotifications(
    Habit habit,
    tz.TZDateTime initialDate,
    List<int> weekdays,
  ) async {
    for (final weekday in weekdays.toSet()) {
      if (weekday < DateTime.monday || weekday > DateTime.sunday) {
        continue;
      }

      var scheduledDate = initialDate;

      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _scheduleNotification(
        habit: habit,
        id: _createNotificationId(habit.id, weekday),
        date: scheduledDate,
        repeatComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _scheduleIntervalNotifications(
    Habit habit,
    tz.TZDateTime initialDate,
  ) async {
    var candidateDate = initialDate;
    int scheduledCount = 0;
    int scannedDays = 0;

    while (scheduledCount < 30 && scannedDays < 365) {
      final normalDate = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
      );

      if (habit.isTargetDate(normalDate)) {
        final dateSalt =
            candidateDate.year * 10000 +
            candidateDate.month * 100 +
            candidateDate.day;

        await _scheduleNotification(
          habit: habit,
          id: _createNotificationId(habit.id, dateSalt),
          date: candidateDate,
        );

        scheduledCount++;
      }

      candidateDate = candidateDate.add(const Duration(days: 1));

      scannedDays++;
    }
  }
}
