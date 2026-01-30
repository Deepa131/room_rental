import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/onboarding/presentation/pages/onboardingthree_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    
    return SizedBox.expand(
      child: Column(
        children: [
          Center(
            child: Text('Welcome to the profile screen'),
          ),

          const SizedBox(height: 30),

          MyButton(
            text: "Logout",
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
        ],
      ),
    );
  }
}