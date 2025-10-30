import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'App Data/NetworkConectivity_checker.dart';
import 'Spam/spamfile.dart';
import 'SplashScreen/splashScreen.dart';
import 'DashBoard/dashBoard.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  // Disable Flutter debug visuals
  debugPaintSizeEnabled = false;      // disables layout outline highlights
  debugPaintPointersEnabled = false;
  debugPaintBaselinesEnabled = false;    // also disable baseline guides if any
  DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blinq Pulse',
      debugShowCheckedModeBanner: false, // removes debug banner
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,

      ),
      initialRoute: '/',
      routes:  {
        '/': (context) => BlinqPulseSplashScreen(),
        '/dashboard': (context) => BlinqPulseHome(),
      },
    );
  }
}
