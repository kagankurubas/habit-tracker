import 'package:flutter/foundation.dart'; // 🚀 kIsWeb kontrolü için eklendi
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
    if (kIsWeb) return null; // 🌐 Web'de çalışıyorsa null dön

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
      print('🚀 Bildirim tıklandı, Habit ID: ${response.payload}');
      selectNotificationStream.value = response.payload;
    }
  }

  // 🧪 Test Bildirimi
  Future<void> showInstantTestNotification() async {
    if (kIsWeb) return; // 🌐 Web'de çalışıyorsa çalıştırma

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

  // 🔕 Bildirimi İptal Et (Seçili günlerin tüm ID'lerini temizler)
  Future<void> cancelHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    // Özel gün seçildiyse her günün ID'sini iptal et
    if (habit.selectedWeekdays != null && habit.selectedWeekdays!.isNotEmpty) {
      for (int weekday in habit.selectedWeekdays!) {
        final notificationId = (habit.id.hashCode ^ weekday).abs();
        await _notificationsPlugin.cancel(id: notificationId);
      }
    } else {
      await _notificationsPlugin.cancel(id: habit.id.hashCode.abs());
    }
    print('🔕 Bildirim(ler) İptal Edildi: ${habit.title}');
  }

  // 🔔 Rutin Zamanla (Sadece Hedef Günlerde Çalar)
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (kIsWeb) return;

    // Bildirim kapalıysa veya saat tanımlanmamışsa iptal etip çık
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

    // 🗓️ A) ÖZEL GÜNLER SEÇİLDİYSE (Sadece O Günlerde Çal)
    if (habit.selectedWeekdays != null && habit.selectedWeekdays!.isNotEmpty) {
      for (int weekday in habit.selectedWeekdays!) {
        // weekday: 1 (Pazartesi) .. 7 (Pazar)
        var scheduledDate = tz.TZDateTime(
          location,
          now.year,
          now.month,
          now.day,
          habit.notificationHour!,
          habit.notificationMinute!,
        );

        // Hedef güne kadar tarihi ileri saralım
        while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        // Her gün için çakışmayan benzersiz ID
        final notificationId = (habit.id.hashCode ^ weekday).abs();

        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: '🔥 ${habit.title}',
          body: motivationBody,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // 👈 SADECE SEÇİLİ HAFTANIN GÜNÜNDE
          payload: habit.id,
        );

        print('🔔 GÜNLÜK BİLDİRİM ZAMANLANDI: ${habit.title} -> Gün: $weekday, Saat: ${scheduledDate.hour}:${scheduledDate.minute}');
      }
    } 
    // 📆 B) ÖZEL GÜN SEÇİLMEDİYSE (Her Gün Çal)
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
        matchDateTimeComponents: DateTimeComponents.time, // 👈 HER GÜN
        payload: habit.id,
      );

      print('🔔 HER GÜN BİLDİRİM ZAMANLANDI: ${habit.title} -> Saat: ${scheduledDate.hour}:${scheduledDate.minute}');
    }
  }
}