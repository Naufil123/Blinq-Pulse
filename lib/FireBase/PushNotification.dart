import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'AccessFireBaseToken.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  final _androidChannel = const AndroidNotificationChannel(
    'high_important_channel',
    'High Important Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
    playSound: true,
  );

  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();
  Future<String?> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $fcmToken');
    }

    const storage = FlutterSecureStorage();
    await storage.write(key: 'fcmToken', value: fcmToken);

    // iOS foreground presentation (optional but helpful)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initLocalNotifications();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message → ${message.messageId}');
        print('Title: ${message.notification?.title ?? "No title"}');
        print('Body:  ${message.notification?.body  ?? "No body"}');
      }

      _showLocalNotification(message);
    });

    // Request Android notification permission (newer Android versions)
    _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Initialize local notifications with tap handler
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_blinqpulse'),
        // iOS: add DarwinInitializationSettings() if needed
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        selectNotificationStream.add(details.payload);
        // Here you can add navigation logic, e.g. using Navigator or global key
      },
    );

    // Your OAuth part
    // // AcesstokenFirebase accessTokenGetter = AcesstokenFirebase();
    // String oauthtoken = await accessTokenGetter.getAccesstoken();
    // if (kDebugMode) print('OAuth token: $oauthtoken');
    return fcmToken;   // ← now matches the return type
  }
  // ('@drawable/ic_launcher')
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_stat_blinqpulse');

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings:settings);

    final androidImpl = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(_androidChannel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
     id: notification.hashCode, // unique id
      title:notification.title,
      body :notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: _androidChannel.importance,
          priority: Priority.high,
          playSound: true,
          // sound: ... if you have custom sound
        ),
        // iOS: DarwinNotificationDetails(...)
      ),
      payload: message.data['payload'], // optional: pass data for tap handling
    );
  }
}