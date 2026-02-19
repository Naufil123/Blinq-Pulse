import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class BlinqPulseSplashScreen extends StatefulWidget {
  @override
  _BlinqPulseSplashScreenState createState() =>
      _BlinqPulseSplashScreenState();
}

class _BlinqPulseSplashScreenState extends State<BlinqPulseSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Navigate to dashboard after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    });

    // Animation for wave line
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F3F), // very dark navy
              Color(0xFF002A5C), // dark navy
              Color(0xFF003366), // medium navy
              Color(0xFF004080), // medium-light navy
              Color(0xFF3366CC), // soft blue
              Color(0xFF6699FF), // lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo with Bounce effect
                  BounceInDown(
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                      child: Image.asset(
                        'assets/images/BlinqPulse.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  SizedBox(height: 12),

                  // Subtitle with FadeIn
                  FadeIn(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      'Your pulse to the future of connectivity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Curved frequency wave
                  SizedBox(
                    height: 20,
                    width: 200,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WavePainter(_animation.value),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class WavePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = 8.0; // wave amplitude
    final waveLength = size.width / 4; // number of waves across width

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width * progress; x++) {
      double y = size.height / 2 +
          waveHeight * sin((2 * pi / waveLength) * x); // sine wave
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
