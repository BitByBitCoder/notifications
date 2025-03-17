// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.init();
//   await FlutterLocalNotificationsPlugin()
//       .pendingNotificationRequests()
//       .then((value) {
//     log('Pending notification requests: ${value.length}');
//     for (var request in value) {
//       log('Pending notification: ${request.id}, ${request.title}, ${request.body},$request');
//     }
//   });
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const NotificationScheduler(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class NotificationScheduler extends StatefulWidget {
//   const NotificationScheduler({super.key});

//   @override
//   State<NotificationScheduler> createState() => _NotificationSchedulerState();
// }

// class _NotificationSchedulerState extends State<NotificationScheduler> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _bodyController = TextEditingController();
//   DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 15));

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }

//   void _scheduleNotification() {
//     if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     if (_selectedDateTime.isBefore(DateTime.now())) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a future time')),
//       );
//       return;
//     }

//     NotificationService.scheduleReminder(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
//       _titleController.text,
//       _bodyController.text,
//       _selectedDateTime,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Notification scheduled for ${DateFormat('MMM d, y – h:mm a').format(_selectedDateTime)}',
//         ),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showIOSDateTimePicker() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 300,
//           color: Colors.white,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 40,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CupertinoButton(
//                       child: const Text('Cancel'),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     CupertinoButton(
//                       child: const Text('Done'),
//                       onPressed: () {
//                         setState(() {});
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: CupertinoDatePicker(
//                   initialDateTime: _selectedDateTime,
//                   minimumDate: DateTime.now(),
//                   maximumDate: DateTime.now().add(const Duration(days: 365)),
//                   mode: CupertinoDatePickerMode.dateAndTime,
//                   onDateTimeChanged: (DateTime newDateTime) {
//                     setState(() {
//                       _selectedDateTime = newDateTime;
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Schedule Notification'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Notification Title',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _bodyController,
//               decoration: const InputDecoration(
//                 labelText: 'Notification Message',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 24),
//             InkWell(
//               onTap: _showIOSDateTimePicker,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       DateFormat('MMM d, y – h:mm a').format(_selectedDateTime),
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const Icon(Icons.calendar_today),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _scheduleNotification,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text(
//                 'Schedule Notification',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 NotificationService.showInstantReminder(
//                   0,
//                   'Test Notification',
//                   'This is an immediate notification',
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: Colors.amber,
//               ),
//               child: const Text(
//                 'Send Test Notification',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class NotificationService {
//   static final _notifications = FlutterLocalNotificationsPlugin();

//   // ✅ Initialize the notification service
//   static Future<void> init() async {
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const ios = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const settings = InitializationSettings(android: android, iOS: ios);

//     await _notifications.initialize(settings);
//     await requestPermissions();
//   }

//   static Future<void> requestPermissions() async {
//     if (await Permission.notification.request().isGranted) {
//       log('Notification Permission: Granted');
//     } else {
//       log('Notification Permission: Denied');
//     }

//     // Request exact alarm permission (for Android 12+)
//     if (await Permission.scheduleExactAlarm.request().isGranted) {
//       log('Exact Alarm Permission: Granted');
//     } else {
//       log('Exact Alarm Permission: Denied');
//     }

//     // Request iOS permissions
//     final ios = _notifications.resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>();
//     await ios?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }

//   static Future<void> scheduleReminder(
//       int id, String title, String body, DateTime dateTime) async {
//     final localTime = tz.TZDateTime.from(dateTime, tz.local);
//     log('Current Time: ${DateTime.now()}');
//     log('Scheduling notification for: $localTime');

//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'reminder_channel',
//         'Reminders',
//         channelDescription: 'Reminder Notifications',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _notifications.zonedSchedule(
//       id,
//       title,
//       body,
//       localTime,
//       details,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//     log('Notification scheduled successfully.');
//   }

//   static Future<void> showInstantReminder(
//       int id, String title, String body) async {
//     const details = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'instant_channel',
//         'Instant Notifications',
//         channelDescription: 'Immediate Notification Test',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );

//     await _notifications.show(id, title, body, details);
//     log('Instant notification sent.');
//   }
// }

////////////////////////////awesome notification
library;

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Awesome Notifications
//   await NotificationService.init();

//   // Check for pending notifications
//   await NotificationService.checkPendingNotifications();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const NotificationScheduler(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class NotificationScheduler extends StatefulWidget {
  const NotificationScheduler({super.key});

  @override
  State<NotificationScheduler> createState() => _NotificationSchedulerState();
}

class _NotificationSchedulerState extends State<NotificationScheduler> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 15));

  @override
  void initState() {
    super.initState();
    // Request permission when the app starts
    ScheduleNotification.requestPermissions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _scheduleNotification() {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time')),
      );
      return;
    }
    log(_selectedDateTime.toString());
    ScheduleNotification.scheduleReminder(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      _titleController.text,
      _bodyController.text,
      _selectedDateTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification scheduled for ${DateFormat('MMM d, y – h:mm a').format(_selectedDateTime)}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDateTimePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        ).then((selectedTime) {
          if (selectedTime != null) {
            setState(() {
              _selectedDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Notification'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ScheduleNotification.cancelAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cancelled')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Notification Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Notification Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _showDateTimePicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM d, y – h:mm a').format(_selectedDateTime),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _scheduleNotification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Schedule Notification',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScheduleNotification.showInstantReminder(
                  0,
                  'Test Notification',
                  'This is an immediate notification',
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.amber,
              ),
              child: const Text(
                'Send Test Notification',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleNotification {
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
