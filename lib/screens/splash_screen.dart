import 'dart:async';

import 'package:flutter/material.dart';
import 'package:room_rental/screens/onboardingone_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //Auto navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
       Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) =>
                      const OnboardingOneScreen(),
                    ),
                  );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 179, 200, 210),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Image.asset('assets/images/image.jpg', fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            const Text("RentEasy",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),)
          ],
        ),
      ),
    );
  }
}