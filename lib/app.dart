import 'package:flutter/material.dart';
import 'package:room_rental/screens/signup_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    home: SignupScreen(userRole: '',),

    );
  }
}