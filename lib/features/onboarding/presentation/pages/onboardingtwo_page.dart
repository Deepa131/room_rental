import 'package:flutter/material.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/onboarding/presentation/pages/onboardingthree_page.dart';

class OnboardingTwoPage extends StatefulWidget {
  const OnboardingTwoPage({super.key});

  @override
  State<OnboardingTwoPage> createState() => _OnboardingTwoPageState();
}

class _OnboardingTwoPageState extends State<OnboardingTwoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/image2_background.png",
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, 
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
                          builder: (context) => const OnboardingThreePage(),
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
