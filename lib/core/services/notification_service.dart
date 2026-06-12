import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _isInitialized = true;

    // Request permission for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'stokwarung_alerts',
      'Peringatan StokWarung',
      channelDescription: 'Notifikasi untuk stok rendah dan kedaluwarsa',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF10A87A),
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Kirim notifikasi batch untuk semua peringatan stok & kedaluwarsa
  Future<void> sendAlertNotifications({
    required List<Map<String, String>> alerts,
  }) async {
    // Kirim satu notifikasi ringkasan
    if (alerts.isEmpty) return;

    final stokAlerts = alerts.where((a) => a['type']!.startsWith('stok')).length;
    final expAlerts = alerts.where((a) => a['type']!.startsWith('kadaluarsa')).length;

    final parts = <String>[];
    if (stokAlerts > 0) parts.add('$stokAlerts barang stok rendah/habis');
    if (expAlerts > 0) parts.add('$expAlerts barang mendekati/sudah kedaluwarsa');

    await showNotification(
      id: 0,
      title: '⚠️ Peringatan StokWarung',
      body: 'Perlu perhatian: ${parts.join(', ')}. Buka aplikasi untuk detail.',
    );

    // Kirim detail per item (max 5 agar tidak spam)
    final limited = alerts.take(5).toList();
    for (var i = 0; i < limited.length; i++) {
      await showNotification(
        id: i + 1,
        title: limited[i]['title']!,
        body: limited[i]['body']!,
      );
    }
  }
}
