import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  // ✅ Initialize the notification service
  static Future<void> init() async {
    tz.initializeTimeZones(); // Load timezone data
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set IST timezone

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);
    await requestPermissions();
  }

  // ✅ Request Notification and Exact Alarm Permissions
  static Future<void> requestPermissions() async {
    // Request notification permission
    if (await Permission.notification.request().isGranted) {
      log('Notification Permission: Granted');
    } else {
      log('Notification Permission: Denied');
    }

    // Request exact alarm permission (for Android 12+)
    if (await Permission.scheduleExactAlarm.request().isGranted) {
      log('Exact Alarm Permission: Granted');
    } else {
      log('Exact Alarm Permission: Denied');
    }
  }

  // ✅ Schedule a notification with a specific date and time
  static Future<void> scheduleReminder(
      int id, String title, String body, DateTime dateTime) async {
    // Ensure local timezone is used
    final localTime = tz.TZDateTime.from(dateTime, tz.local);
    log('Current Time: ${DateTime.now()}');
    log('Scheduling notification for: $localTime');

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Reminder Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      localTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    log('Notification scheduled successfully.');
  }

  // ✅ Show an instant notification immediately
  static Future<void> showInstantReminder(
      int id, String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_channel',
        'Instant Notifications',
        channelDescription: 'Immediate Notification Test',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(id, title, body, details);
    log('Instant notification sent.');
  }
}

    // await _notifications.show(
    //   0,
    //   'Test Notification',
    //   'This is an immediate notification',
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'test_channel',
    //       'Test Channel',
    //       channelDescription: 'Immediate Notification Test',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //   ),
    // );
//