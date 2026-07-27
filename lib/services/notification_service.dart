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

  // 🚀 Tıklanan bildirimdeki habit.id'yi dinlemek için Notifier
  static final ValueNotifier<String?> selectNotificationStream = ValueNotifier(null);

  Future<void> init() async {
    if (kIsWeb) return; // 🌐 Web'de çalışıyorsa bildirimi es geç

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // 🚀 Cold Start (Kapalıyken açılma) kontrolü
  static Future<String?> getInitialNotificationPayload() async {
    if (kIsWeb) return null;

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await NotificationService()._notificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp) {
      final response = notificationAppLaunchDetails.notificationResponse;
      if (response != null && response.payload != null) {
        return response.payload;
      }
    }
    return null;
  }

  // 🖱️ Action Button veya Bildirime Tıklandığında Tetiklenen Metod
  static Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (kIsWeb) return;

    if (response.payload != null) {
      // ⚡ Tıklandığında eğer rutin bugün tamamlandıysa direkt detaya yönlendir, 
      // tamamlanmadıysa kullanıcı zaten tamamlayabilir.
      selectNotificationStream.value = response.payload;
    }
  }

  // 🧪 Test Bildirimi
  Future<void> showInstantTestNotification() async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Rutin Hatırlatıcıları',
      importance: Importance.max,
      priority: Priority.high,
    );
    await _notificationsPlugin.show(
      id: 999,
      title: '🧪 Test Bildirimi',
      body: MotivationService.getRandomQuote(),
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // 🔕 Bildirimi İptal Et
  Future<void> cancelHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    if (habit.selectedWeekdays.isNotEmpty) {
      for (int weekday in habit.selectedWeekdays) {
        final notificationId = (habit.id.hashCode ^ weekday).abs();
        await _notificationsPlugin.cancel(id: notificationId);
      }
    } else {
      await _notificationsPlugin.cancel(id: habit.id.hashCode.abs());
    }
  }

  // 🔔 Rutin Zamanla (⚡ Zaten o gün tamamlandıysa bildirim içeriğini / gönderimini bloke eder)
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    // ⚡ ÖNEMLİ KONTROL: Rutin bugün için zaten tamamlandıysa, bildirim kurmayı atla veya iptal et!
    final nowCheck = DateTime.now();
    final todayNormalized = DateTime(nowCheck.year, nowCheck.month, nowCheck.day);
    if (habit.isCompletedOn(todayNormalized)) {
      await cancelHabitNotification(habit);
      return;
    }

    // Bildirim kapalıysa veya saat tanımlanmamışsa iptal edip çık
    if (!habit.isNotificationEnabled ||
        habit.notificationHour == null ||
        habit.notificationMinute == null) {
      await cancelHabitNotification(habit);
      return;
    }

    // Önce bu habit'e ait eski bildirimleri temizleyelim
    await cancelHabitNotification(habit);

    final location = tz.getLocation('Europe/Istanbul');
    final now = tz.TZDateTime.now(location);
    final String motivationBody = MotivationService.getRandomQuote();

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Rutin Hatırlatıcıları',
      channelDescription: 'Alışkanlıklarınızı hatırlatan bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_habit',
          '🔍 Detayı Aç',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // 🗓️ A) ÖZEL GÜNLER SEÇİLDİYSE
    if (habit.selectedWeekdays.isNotEmpty) {
      for (int weekday in habit.selectedWeekdays) {
        var scheduledDate = tz.TZDateTime(
          location,
          now.year,
          now.month,
          now.day,
          habit.notificationHour!,
          habit.notificationMinute!,
        );

        while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        final notificationId = (habit.id.hashCode ^ weekday).abs();

        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: '🔥 ${habit.title}',
          body: motivationBody,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: habit.id,
        );
      }
    } 
    // 📆 B) ÖZEL GÜN SEÇİLMEDİYSE (Her Gün)
    else {
      var scheduledDate = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        habit.notificationHour!,
        habit.notificationMinute!,
      );

      if (scheduledDate.isBefore(now.subtract(const Duration(seconds: 30)))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notificationId = habit.id.hashCode.abs();

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: '🔥 ${habit.title}',
        body: motivationBody,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habit.id,
      );
    }
  }
}