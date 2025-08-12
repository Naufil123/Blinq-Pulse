import 'dart:async';
import 'package:flutter/material.dart';

import '../DashBoard/dashBoard.dart';


class BlinqPulseSplashScreen extends StatefulWidget {
  @override
  _BlinqPulseSplashScreenState createState() => _BlinqPulseSplashScreenState();
}

class _BlinqPulseSplashScreenState extends State<BlinqPulseSplashScreen> {
  @override
  void initState() {
    super.initState();


    Timer(Duration(seconds: 3), () {

      Navigator.of(context).pushReplacementNamed('/dashboard');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/blinq-logoo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Blinq Pulse',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[800],
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Your pulse to the future of connectivity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
