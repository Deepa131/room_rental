
import 'package:flutter/material.dart';
import 'package:room_rental/screens/login_screen.dart';
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Choose your role to get started",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 40),

                RoleCard(
                  icon: Icons.house_outlined,
                  title: "House Owner",
                  subtitle: "List your properties and manage rentals",
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userRole: "owner"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                RoleCard(
                  icon: Icons.search,
                  title: "Renter / Room Seeker",
                  subtitle: "Find and book your perfect room",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userRole: "renter"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
