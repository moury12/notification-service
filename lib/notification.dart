import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:timezone/timezone.dart' as tz;

// import 'package:timezone/data/latest.dart' as tz;
class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  static AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  static initNotification() async {
    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        '123', // ID
        'Notifications', // Name
        description: 'Notification Channel', // Description
        importance: Importance.high,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Initialize the plugin
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null && details.payload!.isNotEmpty) {
          await OpenFilex.open(details.payload!);
        }
      },
    );
  }

/*  static initNotification() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveBackgroundNotificationResponse: ,
      onDidReceiveNotificationResponse: (details) async {
        if (details.payload != null && details.payload!.isNotEmpty) {
          await OpenFilex.open(details.payload!);
        }
      },
    );
  }*/

  static Future<void> showScheduleNotification(
      DateTime scheduleTime, int? numberOfDays) async {
    const sound = 'notification_sound';
    tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduleTime, tz.local);
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    if (numberOfDays != null) {
      for (int i = 0; i < numberOfDays; i++) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            i,
            'scheduled title',
            'scheduled body',
            scheduledTime.add(Duration(days: i)),
            const NotificationDetails(
                android: AndroidNotificationDetails('123', 'your channel name',
                    channelDescription: 'your channel description',
                    // audioAttributesUsage: AudioAttributesUsage.alarm,
                    importance: Importance.max,
                    // playSound: true,
                    priority: Priority.max,
                    autoCancel: true,
                    sound: RawResourceAndroidNotificationSound(sound),
                    fullScreenIntent: false,
                    enableVibration: true,
                    visibility: NotificationVisibility.public)),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'scheduled title',
          'scheduled body',
          scheduledTime,
          const NotificationDetails(
              android: AndroidNotificationDetails('123', 'your channel name',
                  channelDescription: 'your channel description',
                  // audioAttributesUsage: AudioAttributesUsage.alarm,
                  importance: Importance.max,
                  // playSound: true,
                  priority: Priority.max,
                  autoCancel: true,
                  fullScreenIntent: false,
                  enableVibration: true,
                  visibility: NotificationVisibility.public)),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  static void showDownloadNotification(int progress, String? filePath) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('downloadId', 'downloadName',
            progress: progress,
            showProgress: true,
            importance: Importance.high,
            priority: Priority.high,
            maxProgress: 100, // Maximum progress value (100%)
            indeterminate: false,
            onlyAlertOnce: true,
            channelDescription: 'Channel for download progress notifications');
    // final Uri fileUri = Uri.file(filePath!);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        50,
        progress < 100 ? 'Downloading File $progress%' : 'Download Complete',
        progress < 100 ? 'Download Progress' : 'Tap to open file',
        payload: progress < 100 ? null : filePath,
        notificationDetails);
  }

  static showLocalNotification(
      String title, String body, String payload) async {
    final ByteData imageData = await rootBundle.load('assets/notification.jpg');
    final Uint8List bytes = imageData.buffer.asUint8List();
    final androidNotificationDetail = AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        fullScreenIntent: false,
        styleInformation: BigPictureStyleInformation(
            ByteArrayAndroidBitmap(bytes),
            largeIcon: ByteArrayAndroidBitmap(bytes)),
        visibility: NotificationVisibility.public);
    final iosNotificatonDetail = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    flutterLocalNotificationsPlugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, notificationDetails,
        payload: payload);
  }
}
