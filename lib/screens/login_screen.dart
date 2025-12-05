import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:room_rental/common/my_snackbar.dart';
import 'package:room_rental/widgets/my_button.dart';
import 'package:room_rental/widgets/my_textformfield.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser() {
    if (nameController.text.isEmpty || passwordController.text.isEmpty) {
      showMySnackBar(
        context: context,
        message: "All fields are required!",
        color: Colors.red,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      showMySnackBar(
        context: context,
        message: "Password must be at least 6 characters",
        color: Colors.red,
      );
      return;
    }

    showMySnackBar(
      context: context,
      message: "Login Successful!",
      color: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌆 Background Image
          SizedBox.expand(
            child: Image.asset(
              "assets/images/onboarding_bg3.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🌒 Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.40),
          ),

          /// 🔥 Main Content with Glassmorphism
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 238, 237, 237),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.2,
                        ),
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
                          Text(
                            "RentEasy",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                              color: Colors.blue,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 3),
                                  blurRadius: 12,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// ✨ Welcome Title
                          const Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// 🎭 Show Role
                          Text(
                            "Login as ${widget.userRole.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue.shade700,
                            ),
                          ),

                          const SizedBox(height: 32),

                          /// 🧑 Username
                          MyTextformfield(
                            controller: nameController,
                            labelText: "Username",
                            hintText: "Enter your username",
                            isPassword: false,
                          ),

                          const SizedBox(height: 18),

                          /// 🔒 Password
                          MyTextformfield(
                            controller: passwordController,
                            labelText: "Password",
                            hintText: "Enter your password",
                            isPassword: true,
                          ),

                          const SizedBox(height: 28),

                          /// 🔵 Login Button
                          MyButton(
                            text: "Log In",
                            color: Colors.blue.shade700,
                            onPressed: loginUser,
                          ),

                          const SizedBox(height: 20),

                          /// ➕ Create Account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignupScreen(userRole: widget.userRole),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
