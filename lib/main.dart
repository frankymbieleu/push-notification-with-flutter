import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/push_notification_service.dart';
import 'package:push_notification/push_notification_service.dart';
import 'package:push_notification/second_page.dart';
import 'package:http/http.dart' as http;

PushNotificationService pushNotificationService = PushNotificationService();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  pushNotificationService.initializeAndShow(message);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    pushNotificationService.setupFlutterNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    RemoteMessage message = const RemoteMessage(
        notification: RemoteNotification(
            android: AndroidNotification(
                imageUrl: "app/src/main/res/mipmap-hdpi/logo.png")));

    pushNotificationService.showFlutterNotification(message);
    setState(() {
      _counter++;
    });
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? fltNotification;

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    /*   if (initialMessage != null) {
      _handleMessage(initialMessage);
    }*/

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.push(
        context, MaterialPageRoute(builder: (builder) => const SecondPage()));
  }

  PushNotificationService pushNotificationService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    getToken();
    pushNotificationService.initialise();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(const RemoteMessage());
      }
    });
    setupInteractedMessage();
  }

  getToken() async {
    String? token = await messaging.getToken();
    messaging.subscribeToTopic("all");
    print("Mon token");
    print(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), //
    );
  }

  void initMessaging() {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/logo'); //for logo

    var initSetting = InitializationSettings(android: androidInit);
    fltNotification = FlutterLocalNotificationsPlugin();
    fltNotification?.initialize(initSetting);
    var androidDetails = const AndroidNotificationDetails('1', 'channelName',
        channelDescription: 'channelDescription',
        playSound: true,
        priority: Priority.high,
        ongoing: true,
        color: Colors.purple,
        fullScreenIntent: true,
        styleInformation: BigTextStyleInformation(''),
        importance: Importance.max);

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showMessage(notification, generalNotificationDetails);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.data.containsKey("DETAIL_PAGE")) {
        int id = int.parse(event.data["DETAIL_PAGE"]);
        print("Je pars vers le detail de la page $id");
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => const SecondPage()));
      }
    });
    try {
      FirebaseMessaging.onBackgroundMessage((message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          showMessage(notification, generalNotificationDetails);
        }
        return Future.value();
      });
    } catch (err) {
      // Dont do anything
    }
  }

  void showMessage(RemoteNotification notification,
      NotificationDetails generalNotificationDetails) {
    fltNotification?.show(notification.hashCode, notification.title,
        notification.body, generalNotificationDetails);
  }
}
