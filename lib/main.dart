import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'FireBase/AccessFireBaseToken.dart';
import 'SplashScreen/splashScreen.dart';
import 'DashBoard/dashBoard.dart';
import 'OneLink/OneLinkInquiryUI.dart';
import 'OneLink/OnelinkPaymentUI.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'FireBase/PushNotification.dart';
import 'App Data/NetworkConectivity_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {

    await Firebase.initializeApp();
    final FirebaseApi firebaseApi = FirebaseApi();
    await firebaseApi.initNotifications();
     print("✅ Firebase initialized successfully");

    DependencyInjection.init();
    print("✅ Dependencies initialized successfully");
  } catch (e, stack) {
    print("❌ Initialization error: $e");
    print(stack);
  }

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
        '/': (context) =>  BlinqPulseSplashScreen(),
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
