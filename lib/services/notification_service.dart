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

    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // 1. Standart Bildirim İznini İste
      await androidImplementation.requestNotificationsPermission();

      // 2. Tam Saatli Alarm İznini Doğrudan İste (Android 12+)
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // 🧪 ANLIK TEST BİLDİRİMİ (Sistemin çalışıp çalışmadığını anlamak için)
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
      body: 'Bildirim motoru sorunsuz çalışıyor!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  // 🔕 Bildirimi İptal Et
  Future<void> cancelHabitNotification(Habit habit) async {
    await _notificationsPlugin.cancel(id: habit.id.hashCode);
    print('🔕 Bildirim İptal Edildi: ${habit.title}');
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

    // Türkiye / Yerel Lokasyonu Garanti Al
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

    // Eğer seçilen saat geçmişte kalmışsa erteleme mantığı (Saniye kaymasını önlemek için 1 dakika tolerans)
    if (scheduledDate.isBefore(now.subtract(const Duration(seconds: 30)))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Rutin Hatırlatıcıları',
      channelDescription: 'Alışkanlıklarınızı hatırlatan günlük bildirimler',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Kilitli ekranda bildirimi uyandırmak için
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
      // Exact alarm modunu zorunlu kılıyoruz:
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('🔔 BİLDİRİM ZAMANLANDI: ${habit.title} -> Kurulan Saat: ${scheduledDate.hour}:${scheduledDate.minute} (Hedef Zaman: $scheduledDate)');
  }
}