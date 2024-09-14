import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_service/api_service.dart';
import 'package:notification_service/download_content.dart';
import 'package:notification_service/notification.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();  messaging.subscribeToTopic("general");
  NotificationService.initNotification();
  // if (message.data.isNotEmpty) {
  //   // Create custom notification
  //   NotificationService.showLocalNotification(
  //     message.data['title'] ?? "No Title",
  //     message.data['body'] ?? "No Body",
  //     message.data['payload'] ?? 'Default Payload',
  //   );
  // }
// if(message.notification!=null)
//   {
//     NotificationService.showLocalNotification(
//       message.notification?.title ?? "No title",
//       message.notification?.body ?? "No body",
//       message.data['payload'] ?? 'Default payload',
//     );
//   }
}
FirebaseMessaging messaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  NotificationService.initNotification();
  // Handle messages when app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message in the foreground!');
    if (message.notification != null) {
      NotificationService.showLocalNotification(
        message.notification!.title ?? 'Title',
        message.notification!.body ?? 'Body',
        message.data['payload'] ?? '',
      );
    }
  });
  messaging.subscribeToTopic("general");
  // WidgetsFlutterBinding.ensureInitialized();
  // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
  //   print('Handling background message: ${message.messageId}');
  //   await firebaseMessagingBackgroundHandler(message);
  // });  tz.initializeTimeZones();
  // await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyC-yxJYztZVJ9KLvRztKnaH65a1hpBLIm4",
  //     appId:"1:1017484569656:android:c9a61343398ca906a14acd",
  //     messagingSenderId: "1017484569656"	,
  //     projectId: "notification-service-3bca4"));
  // NotificationService.initNotification();
  // await FirebaseMessaging.instance.getInitialMessage();
  // await FirebaseMessaging.instance.requestPermission();
  // await FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //   print(("THIS IS EVENT :: :: $event"));
  // });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeOfDay? selectedTime;
  DateTime? scheduleTime;
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController numberOfDaysController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('notification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image.asset('assets/notification.jpg'),
              ElevatedButton(
                  onPressed: () {
                    NotificationService.showLocalNotification(
                        'title', 'body', 'payload');
                  },
                  child: Text('send notification with image')),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: numberOfDaysController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter number of days'),
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now());
                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                    });
                                    scheduleTime = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      selectedTime!.hour,
                                      selectedTime!.minute,
                                    );
                                  }
                                },
                                child: Text('select time')),
                            ElevatedButton(
                                onPressed: () {
                                  NotificationService.showScheduleNotification(
                                      scheduleTime!,
                                      numberOfDaysController.text.isEmpty
                                          ? null
                                          : int.parse(
                                              numberOfDaysController.text));
                                  Navigator.pop(context);
                                },
                                child: Text('Set notification'))
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text('schedule notification')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadContent(),
                        ));
                  },
                  child: Text('download notification')),
              TextField(
                decoration: InputDecoration(hintText: "Enter title"),
                controller: titleController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Enter body"),
                controller: bodyController,
              ),
              ElevatedButton(
                  onPressed: () {
                    FirebaseMessaging.instance.getToken().then((value) {
                      ApiService().sentNotification(titleController.text.isEmpty?'null':titleController.text,
                          bodyController.text.isEmpty?'null':bodyController.text, value.toString());
                    });
                  },
                  child: Text('sent notification from  node js server')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FirebaseMessaging.instance.getToken().then((value) {
            print("TOKEN IS :: :: $value");
          });
        },
        label: Text('get token'),
        tooltip: 'Increment',
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
