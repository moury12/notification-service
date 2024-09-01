import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> showScheduleNotification(
      DateTime scheduleTime, int? numberOfDays) async {
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

static  void showDownloadNotification(int progress,String? filePath) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('downloadId', 'downloadName',
            progress: progress,
            showProgress: true,
            importance: Importance.high,
            priority: Priority.high,
            maxProgress: 100, // Maximum progress value (100%)
            indeterminate: false,
            onlyAlertOnce: false,
            channelDescription:
            'Channel for download progress notifications');
final Uri fileUri =Uri.file(filePath!);
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        50, 'Downloading File $progress', 'Download Progress',
        notificationDetails);
  }

  static showLocalNotification(String title, String body, String payload) {
    const androidNotificationDetail = AndroidNotificationDetails('1', 'general',
        priority: Priority.high,
        autoCancel: true,
        fullScreenIntent: false,
        enableVibration: true,
        importance: Importance.high,
        playSound: true,
        visibility: NotificationVisibility.public);
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails,
        payload: payload);
  }
}
