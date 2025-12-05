import 'package:flutter/material.dart';
import 'package:room_rental/screens/signup_screen.dart';
import 'package:room_rental/widgets/role_card.dart';

class OnboardingthreeScreen extends StatefulWidget {
  const OnboardingthreeScreen({super.key});

  @override
  State<OnboardingthreeScreen> createState() => _OnboardingthreeScreenState();
}

class _OnboardingthreeScreenState extends State<OnboardingthreeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),

                    const Text(
                      "Choose your role to get started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    RoleCard(
                      icon: Icons.house_outlined, 
                      title: "House Owner", 
                      subtitle: "List your properties and manage rentals", 
                      color: Colors.teal.shade300, 
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(
                              userRole: "owner",
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    //Renter card
                    RoleCard(
                      icon: Icons.search, 
                      title: "Renter/ Room Seeker", 
                      subtitle: "Find and book your perfect room", 
                      color: Colors.blue.shade300, 
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(
                              userRole: "renter",
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}