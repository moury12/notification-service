import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_service/download_content.dart';
import 'package:notification_service/notification.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  NotificationService.initNotification();
  await FirebaseMessaging.instance.getInitialMessage();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print(("THIS IS EVENT :: :: $event"));
  });
  runApp(const MyApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  NotificationService.showLocalNotification(
    message.notification?.title ?? "No title",
    message.notification?.body ?? "No body",
    message.data['payload'] ?? 'Default payload',
  );
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

  TextEditingController numberOfDaysController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('notification'),
      ),
      body: Center(
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
                child: Text('download notification'))
          ],
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
