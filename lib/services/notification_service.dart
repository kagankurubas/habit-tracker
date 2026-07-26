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

  // 🖱️ Action Button veya Bildirime Tıklandığında Tetiklenen Metod
  static Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      print('🚀 Bildirim tıklandı, Habit ID: ${response.payload}');
      // ID'yi akışa veriyoruz, böylece ekran tespiti yapabilecek
      selectNotificationStream.value = response.payload;
    }
  }

  // 🧪 Test Bildirimi
  Future<void> showInstantTestNotification() async {
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
    await _notificationsPlugin.cancel(id: habit.id.hashCode);
    print('🔕 Bildirim İptal Edildi: ${habit.title}');
  }

  // 🔔 Rutin Zamanla
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (!habit.isNotificationEnabled ||
        habit.notificationHour == null ||
        habit.notificationMinute == null) {
      await cancelHabitNotification(habit);
      return;
    }

    final int notificationId = habit.id.hashCode;

    final location = tz.getLocation('Europe/Istanbul');
    final now = tz.TZDateTime.now(location);

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

    final String motivationBody = MotivationService.getRandomQuote();

    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Rutin Hatırlatıcıları',
      channelDescription: 'Alışkanlıklarınızı hatırlatan günlük bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'open_habit',
          '🔍 Detayı Aç',
          showsUserInterface: true, // Uygulamayı ön plana getirir
          cancelNotification: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

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

    print('🔔 BİLDİRİM ZAMANLANDI: ${habit.title} -> Kurulan Saat: ${scheduledDate.hour}:${scheduledDate.minute} (Hedef Zaman: $scheduledDate)');
  }
}