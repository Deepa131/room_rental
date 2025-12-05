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
  // controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // validation function
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
      if (!mounted) {
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(userRole: widget.userRole)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffe5eef0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              SizedBox(height: height * 0.03),

              Container(
                color: const Color.fromARGB(255, 167, 197, 221),
                height: 200,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/image3.jpg",
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Create Your Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MyTextformfield(
                      controller: fullNameController,
                      labelText: "Enter full name",
                      hintText: "Full Name", isPassword: false,
                    ),
                    const SizedBox(height: 16),

                    MyTextformfield(
                      controller: phoneController,
                      labelText: "Phone Number",
                      hintText: "98XXXXXXXX", isPassword: false,
                    ),
                    const SizedBox(height: 16),

                    MyTextformfield(
                      controller: emailController,
                      labelText: "Email",
                      hintText: "example@gmail.com", isPassword: false,
                    ),
                    const SizedBox(height: 16),

                    MyTextformfield(
                      controller: passwordController,
                      labelText: "Password",
                      hintText: "******", isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    MyTextformfield(
                      controller: confirmPasswordController,
                      labelText: "Confirm password",
                      hintText: "******", isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    MyButton(
                      text: "Sign Up",
                      onPressed: handleSignup,
                      color: const Color(0xff24479a),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, 
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(userRole: widget.userRole),
                        ),
                      );
                    },
                    child: const Text(
                      " Login",
                      style: TextStyle(color: Colors.red),
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
