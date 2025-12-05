import 'package:flutter/material.dart';
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
      body: Stack(
        children: [
          // Background image (optional)
          SizedBox.expand(
            child: Image.asset(
              "assets/images/image2_background.png", // add a background image for consistency
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay for readability
          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // positions content at bottom
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon stack
                  Stack(
                    alignment: Alignment.center,
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "RentEasy",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "Find your perfect room in Nepal",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  MyButton(
                    text: "Get Started",
                    color: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingthreeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
