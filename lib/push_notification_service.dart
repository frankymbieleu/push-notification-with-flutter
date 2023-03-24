import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/main.dart';
import 'package:push_notification/second_page.dart';

class PushNotificationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void notificationTapBackground(NotificationResponse notificationResponse) {
    Map<String, String> data = jsonDecode(notificationResponse.payload ?? "");
    navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (builder) => const SecondPage()));
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  Future<void> initializeAndShow(RemoteMessage message) async {
    showFlutterNotification(message);
  }

  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    var androidDetails = const AndroidNotificationDetails('1', 'channelName',
        channelDescription: 'channelDescription',
        playSound: true,
        priority: Priority.high,
        ongoing: true,
        color: Colors.purple,
        //fullScreenIntent: true,
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/logo'),
        channelShowBadge: true,
        autoCancel: true,
        icon: '@mipmap/logo',
        styleInformation: BigTextStyleInformation(""),
        importance: Importance.max);

    var generalNotificationDetails =
        NotificationDetails(android: androidDetails);
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin?.show(notification.hashCode,
          notification.title, notification.body, generalNotificationDetails);
    }
  }

  Future initialise() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showFlutterNotification(message);
    });
  }
}
