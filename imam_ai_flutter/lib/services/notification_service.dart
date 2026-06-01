import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklanınca yapılacaklar (opsiyonel)
      },
    );

    // Android 13+ bildirim izni
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Ana namaz vakti bildirimi + 5 dakika öncesi hatırlatıcı
  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = time;

    // Vakit geçmişse yarına kur
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // ── 1) Tam vakit bildirimi ────────────────────────────────────────────
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: '🕌 $prayerName Vakti Girdi',
      body: '$prayerName namazı için vakit geldi. Namazını eda etmeyi unutma! 🤲',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Namaz Vakitleri',
          channelDescription: 'Ezan vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // ── 2) 5 dakika öncesi hatırlatıcı ───────────────────────────────────
    final reminderDate = scheduledDate.subtract(const Duration(minutes: 5));

    // 5 dk öncesi zaten geçmişse kurma
    if (reminderDate.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        // 5 dk hatırlatıcı ID'si: orijinal ID + 100 (çakışmasın)
        id: id + 100,
        title: '⏰ $prayerName Vaktine 5 Dakika Kaldı',
        body: 'Hazırlanma vaktin geldi! $prayerName namazına 5 dakika kaldı. 🕌',
        scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminder_channel',
            'Namaz Hatırlatıcısı',
            channelDescription: 'Namaza 5 dakika kala hatırlatma',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            color: Color(0xFF00B27A),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // Sadece 5 dakika hatırlatıcısını iptal et
  Future<void> cancelReminderNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id + 100);
  }

  Future<void> cancelNotification(int id) async {
    // Hem tam vakit hem de 5 dk hatırlatıcısını iptal et
    await flutterLocalNotificationsPlugin.cancel(id: id);
    await flutterLocalNotificationsPlugin.cancel(id: id + 100);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Anlık test bildirimi gönder (debug için)
  Future<void> sendTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: '🕌 Test Bildirimi',
      body: 'İmam AI bildirimleri çalışıyor! Namaz vakitlerini kaçırmayacaksınız. 🤲',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Namaz Vakitleri',
          channelDescription: 'Ezan vakti bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
