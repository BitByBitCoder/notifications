import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Daily Reminder')),
        body: const Center(
          child: ElevatedButton(
            onPressed: scheduleDailyNotification,
            child: Text('Schedule Daily Reminder at 2 PM'),
          ),
        ),
      ),
    );
  }
}

// ✅ Initialize Notifications
Future<void> initNotifications() async {
  // Initialize timezone database
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print('Notification clicked: ${response.payload}');
    },
  );
}

// ✅ Schedule a Daily Notification at 2 PM
Future<void> scheduleDailyNotification() async {
  try {
    // Request permissions
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Define 2 PM time
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      14, // 2 PM (24-hour format)
      57, // 00 minutes
    );

    // If 2 PM has already passed today, schedule for tomorrow
    final notificationTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Reminds you daily at 2 PM',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Schedule notification daily
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID (must be unique per notification)
      'Daily Reminder',
      'This is your reminder for 2 PM!',
      notificationTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
    );

    print('Notification scheduled for $notificationTime');
  } catch (e) {
    print('Error scheduling notification: $e');
  }
}
