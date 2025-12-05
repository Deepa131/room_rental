import 'dart:ui';
import 'package:flutter/material.dart';
import '../common/my_snackbar.dart';
import '../widgets/my_button.dart';
import '../widgets/my_textformfield.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String userRole;

  const SignupScreen({super.key, required this.userRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void handleSignup() {
    String fullName = fullNameController.text.trim();
    String phone = phoneController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMySnackBar(
        context: context,
        message: "All fields are required!",
        color: Colors.red,
      );
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      showMySnackBar(
        context: context,
        message: "Enter a valid email address!",
        color: Colors.red,
      );
      return;
    }

    if (password != confirmPassword) {
      showMySnackBar(
        context: context,
        message: "Passwords do not match!",
        color: Colors.red,
      );
      return;
    }

    showMySnackBar(
      context: context,
      message: "Signup Successful!",
      color: Colors.green,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(userRole: widget.userRole),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/onboarding_bg3.png",
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.40),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
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
                              color: Colors.blue,
                              letterSpacing: 1.4,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 12,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Signup as ${widget.userRole.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(height: 30),

                          MyTextformfield(
                            controller: fullNameController,
                            labelText: "Full Name",
                            hintText: "Enter full name",
                            isPassword: false,
                          ),
                          const SizedBox(height: 16),

                          MyTextformfield(
                            controller: phoneController,
                            labelText: "Phone Number",
                            hintText: "98XXXXXXXX",
                            isPassword: false,
                          ),
                          const SizedBox(height: 16),

                          MyTextformfield(
                            controller: emailController,
                            labelText: "Email",
                            hintText: "example@gmail.com",
                            isPassword: false,
                          ),
                          const SizedBox(height: 16),

                          MyTextformfield(
                            controller: passwordController,
                            labelText: "Password",
                            hintText: "******",
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),

                          MyTextformfield(
                            controller: confirmPasswordController,
                            labelText: "Confirm Password",
                            hintText: "******",
                            isPassword: true,
                          ),

                          const SizedBox(height: 26),

                          /// Button
                          MyButton(
                            text: "Sign Up",
                            color: Colors.blue.shade700,
                            onPressed: handleSignup,
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LoginScreen(userRole: widget.userRole),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 10),
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
