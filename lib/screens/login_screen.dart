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
  bool rememberMe = false;

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

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      // if (widget.userRole == "owner") {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const OwnerHome()),
      //   );
      // } else {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const RenterHome()),
      //   );
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdfe8ec),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/image3.jpg", height: 140, width: 500),
              const SizedBox(height: 20),

              const Text(
                "Login",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              MyTextformfield(
                controller: nameController,
                labelText: "Enter your name",
                hintText: "Enter your name", 
                isPassword: false,
              ),

              const SizedBox(height: 18),

              MyTextformfield(
                controller: passwordController,
                labelText: "Enter your password",
                hintText: "Password",
                isPassword: true,
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
                          builder: (context) =>
                              SignupScreen(userRole: widget.userRole),
                        ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
