import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'screens/notification_service.dart';
import 'screens/task_list_screen.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "id", // id
  "name", // name
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotify =
      FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  flutterLocalNotify.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {},
  );

  log('A new background message was received! Title: ${message.data['title']}');

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotify.show(
      notification.hashCode,
      message.data['title'],
      message.data['message'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_ID',
          'channel name',
          channelDescription: 'channel description',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          ticker: 'test ticker',
        ),
      ),
      payload: json.encode(message.data),
    );
  }
}

Future<void> onSelectNotification(String? payload) async {
  if (payload != null) {
    Map data = json.decode(payload);
    log('Notification data: $data');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  PushNotificationsManager().init();

  runApp(const MyApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TaskProvider()),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Task App',
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeMode, // Use themeMode from ValueNotifier
              home: TaskListScreen(),
            );
          },
        ));
  }
}
