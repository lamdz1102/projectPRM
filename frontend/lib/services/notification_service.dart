import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void Function(int piggyId)? onPiggyNotificationTap;

  bool _initialized = false;
  int? _pendingPiggyId;

  static const String _channelId = 'piggy_context_channel';
  static const String _channelName = 'Piggy context notifications';
  static const String _channelDescription =
      'Thông báo theo ngữ cảnh cho mục tiêu tiết kiệm';

  Future<void> init() async {
    if (_initialized) return;

    if (!kIsWeb) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    _pendingPiggyId = _extractPiggyId(
      launchDetails?.notificationResponse?.payload,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    await requestPermission();

    _initialized = true;
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  NotificationDetails get _notificationDetails {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  Future<void> showPiggyNotification({
    required int notificationId,
    required String title,
    required String body,
    required int piggyId,
  }) async {
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: _notificationDetails,
      payload: _buildPiggyPayload(piggyId),
    );
  }

  Future<void> schedulePiggyNotification({
    required int notificationId,
    required String title,
    required String body,
    required int piggyId,
    required DateTime scheduledAt,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    if (kIsWeb) {
      debugPrint('Web không hỗ trợ scheduled notification. Bỏ qua: $title');
      return;
    }

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: _notificationDetails,
      payload: _buildPiggyPayload(piggyId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleDailySavingReminder({
    required int notificationId,
    int hour = 20,
    int minute = 0,
  }) async {
    if (kIsWeb) {
      debugPrint('Web không hỗ trợ repeating notification. Bỏ qua daily reminder.');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Đến giờ tiết kiệm rồi 🐷',
      body: 'Hôm nay bạn đã bỏ tiền vào Piggy chưa?',
      scheduledDate: scheduledDate,
      notificationDetails: _notificationDetails,
      payload: jsonEncode({'type': 'daily_saving_reminder'}),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int notificationId) async {
    await _plugin.cancel(id: notificationId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  int? consumePendingPiggyId() {
    final piggyId = _pendingPiggyId;
    _pendingPiggyId = null;
    return piggyId;
  }

  void _handleNotificationTap(NotificationResponse response) {
    final piggyId = _extractPiggyId(response.payload);

    if (piggyId == null) return;

    final callback = onPiggyNotificationTap;
    if (callback != null) {
      callback(piggyId);
    } else {
      _pendingPiggyId = piggyId;
    }
  }

  String _buildPiggyPayload(int piggyId) {
    return jsonEncode({
      'type': 'piggy_detail',
      'piggyId': piggyId,
    });
  }

  int? _extractPiggyId(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['type'] != 'piggy_detail') return null;
      return data['piggyId'] as int?;
    } catch (_) {
      return null;
    }
  }
}
