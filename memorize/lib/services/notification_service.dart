import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inisialisasi Timezone
    tz.initializeTimeZones();

    // Konfigurasi Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ganti jika pakai ikon custom

    // Konfigurasi iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Minta Izin Notifikasi (Android 13+)
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();


    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // Handler saat notifikasi diterima (iOS foreground)
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Tampilkan dialog atau lakukan sesuatu
    print('iOS foreground notification received: $title');
  }

  // Handler saat notifikasi DIKLIK
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('notification payload: $payload');
      // TODO: Navigasi ke halaman detail memo jika perlu
    }
  }

  // --- Fungsi Utama: Jadwalkan Notifikasi ---
  Future<void> scheduleNotification({
    required int id, // Gunakan ID memo
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Pastikan waktu ada di masa depan
    if (scheduledTime.isBefore(DateTime.now())) {
      print("Waktu notifikasi sudah lewat, tidak dijadwalkan.");
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local), // Gunakan timezone lokal HP
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'memo_channel_id', // ID unik channel
          'Memo Reminders',  // Nama channel (terlihat di setting Android)
          channelDescription: 'Channel for memo reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'memo_$id', // Data tambahan saat notif diklik
    );
    print("Notifikasi dijadwalkan untuk ID $id pada $scheduledTime");
  }

  // --- Fungsi Utama: Batalkan Notifikasi ---
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("Notifikasi dibatalkan untuk ID $id");
  }
}