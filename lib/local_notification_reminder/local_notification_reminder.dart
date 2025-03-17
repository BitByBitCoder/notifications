import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  // Define notification channels
  static const String _channelKey = 'reminder_channel';
  static const String _channelGroupKey = 'reminder_channel_group';

  // ✅ Initialize awesome notifications
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // no default icon
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: 'Reminder Notifications',
          channelDescription: 'Notification channel for reminders',
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          locked: true, // Makes notification persist on screen
          defaultRingtoneType: DefaultRingtoneType.Notification,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: _channelGroupKey,
          channelGroupName: 'Reminder Group',
        )
      ],
      debug: true,
    );

    // Set up notification action listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // ✅ Check for pending notifications (useful for debugging)
  static Future<void> checkPendingNotifications() async {
    final List<NotificationModel> pendingNotifications =
        await AwesomeNotifications().listScheduledNotifications();
    log('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {}
  }

  // ✅ Request notification permissions
  static Future<void> requestPermissions() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    log('Notification Permission: ${isAllowed ? 'Granted' : 'Denied'}');
  }

  // ✅ Schedule a notification with a specific date and time
  static Future<void> scheduleReminder(
      int id, String title, String body, DateTime dateTime) async {
    log('Current Time: ${DateTime.now()}');
    log('Scheduling notification for: $dateTime');

    bool success = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        displayOnBackground: true,
        displayOnForeground: true,
        criticalAlert: true,
      ),
      schedule: NotificationCalendar.fromDate(date: dateTime),
    );

    if (success) {
      log('Notification scheduled successfully.');
      await checkPendingNotifications();
    } else {
      log('Failed to schedule notification');
    }
  }

  // ✅ Show an instant notification immediately
  static Future<void> showInstantReminder(
      int id, String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
        displayOnBackground: true,
        displayOnForeground: true,
      ),
    );
    log('Instant notification sent.');
  }

  // ✅ Cancel all pending notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();

    log('All notifications canceled');
  }

  // Required methods for AwesomeNotifications listeners

  // Triggered when a notification is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    log('Notification created: ${receivedNotification.id}');
  }

  // Triggered when a notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    log('Notification displayed: ${receivedNotification.id}');
  }

  // Triggered when user taps on a notification
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Notification action received: ${receivedAction.id}');
    // You can navigate to a specific screen here if needed
  }

  // Triggered when user dismisses a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Notification dismissed: ${receivedAction.id}');
  }
}
