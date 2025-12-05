import 'package:flutter/material.dart';
import 'package:room_rental/common/my_snackbar.dart';
import 'package:room_rental/screens/onboardingthree_screen.dart';
import 'package:room_rental/widgets/my_button.dart';

class OnboardingtwoScreen extends StatefulWidget {
  const OnboardingtwoScreen({super.key});

  @override
  State<OnboardingtwoScreen> createState() => _OnboardingtwoScreenState();
}

class _OnboardingtwoScreenState extends State<OnboardingtwoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7E4E7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF94BDC4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 60,
                    color: Colors.black87,
                  ),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.black87),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.location_on,
                    size: 30,
                    color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "RentEasy",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Find your perfect room in Nepal",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),

            MyButton(
              text: "Get Started",
              color: Colors.blue.shade800,
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) =>
                    const OnboardingthreeScreen(),
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