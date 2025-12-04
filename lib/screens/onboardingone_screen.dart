import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import 'onboardingtwo_screen.dart';

class OnboardingOneScreen extends StatefulWidget {
  const OnboardingOneScreen({super.key});

  @override
  State<OnboardingOneScreen> createState() => _OnboardingOneScreenState();
}

class _OnboardingOneScreenState extends State<OnboardingOneScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 194, 208, 215),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/image2.jpg",
              height: 250,
            ),
            const SizedBox(height: 30),
            const Text(
              "Welcome to RentEasy",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "This app will help you stay productive and organized.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),

            MyButton(
              text: "Next",
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingtwoScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
