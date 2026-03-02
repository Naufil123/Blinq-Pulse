import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:new_project/DashBoard/AuthData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlinqPulseSplashScreen extends StatefulWidget {
  @override
  _BlinqPulseSplashScreenState createState() =>
      _BlinqPulseSplashScreenState();
}

class _BlinqPulseSplashScreenState extends State<BlinqPulseSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = false;
  bool isObscure = true;
  bool isShown=false;


/*
  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // After 3 seconds show dialog
    Future.delayed(Duration(seconds: 3), () {
      showFirstTimeDialog();
    });
  }
*/
  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
    checkFirstTime();
  }
  Future<void> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('isShown') ?? false;
    await Future.delayed(Duration(seconds: 3));

    if (!shown) {
      showFirstTimeDialog();
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Container(

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
        ],
      ),
    );
  }

  Future<void> handleDeviceRegistration({
    required BuildContext context,
    required String mobile,
    required String pin,
    void Function()? onStart,
    void Function()? onFinish,
  }) async {
    if (mobile
        .trim()
        .isEmpty || pin
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Required fields cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mobile.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mobile number must be exactly 11 digits"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PIN must be exactly 6 digits"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (onStart != null) onStart(); // show loader

      final res = await AuthData.registerDevice(
        username: mobile.trim(),
        secretPin: pin.trim(),
      );

      if (onFinish != null) onFinish(); // hide loader

      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An Error Occured Please Try Again Later"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (res["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isShown', true);
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (res["status"] == "failure") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res["message"] ?? "Invalid PIN"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unknown error occurred"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (onFinish != null) onFinish(); // hide loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showFirstTimeDialog() {
    TextEditingController mobileController = TextEditingController();
    TextEditingController keyController = TextEditingController();
    bool isLoadingDialog = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF001F3F),
                          Color(0xFF003366),
                          Color(0xFF3366CC),
                          Color(0xFF6699FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/BlinqPulse.png',
                          height: 80,
                        ),
                        Text(
                          "Welcome To Blinq Pulse",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: mobileController,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: "Mobile Number (Username) *",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54)),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: keyController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          obscureText: isObscure,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            counterText: "",
                            labelText: "Enter 6 Digits PIN *",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white54),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                          ),
                          onPressed: () async {
                            await handleDeviceRegistration(
                              context: context,
                              mobile: mobileController.text,
                              pin: keyController.text,
                              onStart: () {
                                setState(() {
                                  isLoadingDialog = true;
                                });
                              },
                              onFinish: () {
                                setState(() {
                                  isLoadingDialog = false;
                                });
                              },
                            );
                          },
                          child: Text("Continue"),
                        ),
                      ],
                    ),
                  ),
                ),

                if (isLoadingDialog)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
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
    final waveHeight = 8.0;
    final waveLength = size.width / 4;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width * progress; x++) {
      double y = size.height / 2 +
          waveHeight * sin((2 * pi / waveLength) * x);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

//################### Push Notification Complete #########################