

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'AccessFireBaseToken.dart';
class FirebaseApi {


  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_important_channel',
    'High Important Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

/*  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      AuthData.loadingunpaidapi=true;
      AuthData.loadingpaidapi=true;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    selectNotificationStream.stream.listen((payload) {
      if (payload != null) {
        final data = jsonDecode(payload);
        if (data["route"] == "/pay") {
          navigatorKey.currentState
              ?.pushNamed(data["route"] as String, arguments: data["payment_id"]);
        }
      }
    });

    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          selectNotificationStream.add(notificationResponse.payload);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }*/

/*  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      AuthData.loadingunpaidapi=true;
      AuthData.loadingpaidapi=true;
      saveBillStatus();
      print('message: $message');
      print('hm Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Payload: ${message.data}');
    }
    initPushNotifications();
  }*/

/*  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    if (kDebugMode) {
      print('message: $message');
      print('hm Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Payload: ${message.data}');
    }

    if (message.data != null) {
      if (message. data["route"] == "/pay") {
        navigatorKey.currentState?.pushNamed(message.data["route"] as String,
            arguments: message.data["payment_id"]);
      } else {
        // Handle other routes if necessary
      }
    }
  }*/

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token : $fcmToken');
    }
    AcesstokenFirebase accessTokenGetter= AcesstokenFirebase();
    String oauthtoken =await  accessTokenGetter.getAccesstoken();
    if (kDebugMode) {
      print (oauthtoken);
    }
    // Create storage
    const storage = FlutterSecureStorage();
    await storage.write(key: 'fcmToken', value: fcmToken);

    // initPushNotifications();
    initLocalNotifications();

  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

/* // void initAuth2reciver() {
  //   val accesstoken=AccessToken;
  // }*/
}

