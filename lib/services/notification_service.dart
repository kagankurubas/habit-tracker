import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  static const String _channelName = 'Rutin Hatırlatıcıları';

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Alışkanlıklarınızı hatırlatan bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

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
      title: '🧪 HABITTO Test Bildirimi',
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

    // Eski sürümde oluşturulmuş bildirimleri de temizle.
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

      // Habit tracker için tam saniye hassasiyeti gerekmiyor.
      // Böylece özel exact-alarm iznine bağımlı kalmıyoruz.
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
      // Her gün
      case 0:
        await _scheduleNotification(
          habit: habit,
          id: _createNotificationId(habit.id, 0),
          date: initialDate,
          repeatComponents: DateTimeComponents.time,
        );
        break;

      // Hafta içi
      case 1:
        await _scheduleWeeklyNotifications(habit, initialDate, const [
          1,
          2,
          3,
          4,
          5,
        ]);
        break;

      // Hafta sonu
      case 2:
        await _scheduleWeeklyNotifications(habit, initialDate, const [6, 7]);
        break;

      // X günde bir
      case 3:
        await _scheduleIntervalNotifications(habit, initialDate);
        break;

      // Haftanın belirli günleri
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

    // Önümüzdeki 30 uygun tarihi zamanla.
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
