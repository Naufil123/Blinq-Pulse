import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ import Firebase
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'App Data/NetworkConectivity_checker.dart';
import 'FireBase/PushNotification.dart';
import 'OneLink/OneLinkInquiryUI.dart';
import 'OneLink/OnelinkPaymentUI.dart';
import 'Spam/spamfile.dart';
import 'SplashScreen/splashScreen.dart';
import 'DashBoard/dashBoard.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart'; // only if using FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  final FirebaseApi firebaseApi = FirebaseApi();
  await firebaseApi.initNotifications();
  DependencyInjection.init();
  debugPaintSizeEnabled = false;
  debugPaintPointersEnabled = false;
  debugPaintBaselinesEnabled = false;
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => BlinqPulseSplashScreen(),
        '/dashboard': (context) => BlinqPulseHome(),
        '/OnelinkInquiryscreen': (context) => OneLinkInquiryUI(
          oneLinkData: [],
          inquiryStatuses: [],
          paymentStatuses: [],
        ),
        '/Onelinkpaymentscreen': (context) => OneLinkPaymentUI(
          oneLinkData: [],
          inquiryStatuses: [],
          paymentStatuses: [],
        ),
      },
    );
  }
}
