




import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  static  AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  static initNotification() async {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    );
  }

  static showLocalNotification(String title, String body,String payload) {
    const androidNotificationDetail = AndroidNotificationDetails(
      '0',
      'general' ,
      priority: Priority.high,
      autoCancel: true,
      fullScreenIntent: false,
      enableVibration: true,
      importance: Importance.high,
      playSound: true,
      visibility: NotificationVisibility.public
    );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const  notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,

    );
    flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails,payload: payload);
  }
}