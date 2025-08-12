import 'package:flutter/material.dart';
import 'App Data/NetworkConectivity_checker.dart';
import 'Spam/spamfile.dart';
import 'SplashScreen/splashScreen.dart';
import 'DashBoard/dashBoard.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

/*void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SpamFile(),
  ));
}*/
void main() {
  DependencyInjection.init();
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
      initialRoute: '/',  // Initial route is splash screen
      routes: {
        '/': (context) => BlinqPulseSplashScreen(),  // Splash screen route
        '/dashboard': (context) => BlinqPulseHome(),
      },
    );
  }
}

