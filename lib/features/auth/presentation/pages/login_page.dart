import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/core/widgets/my_textformfield.dart';
import 'package:room_rental/features/auth/presentation/state/auth_state.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:room_rental/features/owner_dashboard/presentation/pages/owner_dashboard_page.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/renter_dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String userRole;

  const LoginPage({
    super.key,
    required this.userRole,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        if (widget.userRole == "owner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const OwnerDashboardPage(),
            ),
            result: false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const RenterDashboardPage(),
            ),
            (route) => false,
          );
        }
      } else if (next.status == AuthStatus.error &&
          next.errorMessage != null) {
        showMySnackBar(
          context: context,
          message: next.errorMessage!,
          color: Colors.red,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).login(
            email: _emailController.text.trim(), 
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

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
            color: Colors.black.withOpacity(0.4),
          ),

          SafeArea(
            child: Center(
              child: Padding(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "RentEasy",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                letterSpacing: 1.4,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "Login as ${widget.userRole.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),

                            const SizedBox(height: 30),

                            MyTextformfield(
                              controller: _emailController,
                              labelText: "Email / Username",
                              hintText: "Enter your email",
                              errorMessage: "Email is required",
                            ),

                            const SizedBox(height: 16),

                            MyTextformfield(
                              controller: _passwordController,
                              labelText: "Password",
                              hintText: "Enter your password",
                              obscureText: _obscurePassword,
                              errorMessage: "Password is required",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off: Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 28),

                            MyButton(
                              text: "Log In",
                              color: Colors.blue.shade700,
                              isLoading:
                                  authState.status == AuthStatus.loading,
                              onPressed: _handleLogin,
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegisterPage(
                                          userRole: widget.userRole,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
