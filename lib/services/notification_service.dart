import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

    await _notificationsPlugin.initialize(settings: settings);
  }

  // 🔕 Bildirimi İptal Et (Yukarı taşındı)
  Future<void> cancelHabitNotification(Habit habit) async {
    await _notificationsPlugin.cancel(id: habit.id.hashCode);
  }

  // 🔔 Rutin İçin Günlük Hatırlatma Bildirimi Zamanla
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (!habit.isNotificationEnabled ||
        habit.notificationHour == null ||
        habit.notificationMinute == null) {
      await cancelHabitNotification(habit);
      return;
    }

    final int notificationId = habit.id.hashCode;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.notificationHour!,
      habit.notificationMinute!,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Rutin Hatırlatıcıları',
      channelDescription: 'Alışkanlıklarınızı hatırlatan günlük bildirimler',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: '🔥 Rutin Zamanı!',
      body: 'Bugünün görevi: "${habit.title}" seni bekliyor!',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}