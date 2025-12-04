import 'package:flutter/material.dart';
import 'package:room_rental/common/my_snackbar.dart';
import 'package:room_rental/widgets/my_button.dart';
import 'package:room_rental/widgets/my_textformfield.dart';
import 'signup_screen.dart';   

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  void loginUser() {
    String name = nameController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      showMySnackBar(
        context: context,
        message: "All fields are required!",
        color: Colors.red,
      );
      return;
    }

    if (password.length < 6) {
      showMySnackBar(
        context: context,
        message: "Password must be at least 6 characters",
        color: Colors.red,
      );
      return;
    }

    // SUCCESS
    showMySnackBar(
      context: context,
      message: "Logged in successfully!",
      color: Colors.green,
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeScreen()),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdfe8ec),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(
                  "assets/images/image3.jpg",
                  height: 150,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              MyTextformfield(
                controller: nameController,
                labelText: "Enter your name",
                hintText: "Enter your name",
              ),

              const SizedBox(height: 18),

              MyTextformfield(
                controller: passwordController,
                labelText: "Enter your password",
                hintText: "Enter your password",
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember Me"),
                    ],
                  ),

                  const Text(
                    "Forgotten password?",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              MyButton(
                text: "Log In",
                color: const Color(0xff2e3e87),
                onPressed: loginUser,
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
