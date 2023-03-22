import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final fcm = FirebaseMessaging.instance;

  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await initializeAndShow(message);
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    print('Handling a background message ${message.messageId}');
  }

  Future<void> initializeAndShow(RemoteMessage message) async {
    await Firebase.initializeApp();
    showFlutterNotification(message);
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  void showFlutterNotification(RemoteMessage message) {
    setupFlutterNotifications();
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    var androidInit =
        const AndroidInitializationSettings('@mipmap/logo'); //for logo

    var initSetting = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(initSetting );
    var androidDetails = const AndroidNotificationDetails('1', 'channelName',
        channelDescription: 'channelDescription',
        playSound: true,
        priority: Priority.high,
        ongoing: true,
        color: Colors.purple,
        //fullScreenIntent: true,
        styleInformation: BigTextStyleInformation(""),
        importance: Importance.max);

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(notification.hashCode,
          notification.title, notification.body, generalNotificationDetails);
    }
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.

  Future initialise() async {
    /// foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("opppppppppppppppp");
    });
  }
}
