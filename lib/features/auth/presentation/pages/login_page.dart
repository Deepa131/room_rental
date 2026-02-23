import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/storage/biometric_auth_service.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
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
  bool _hasBiometricUser = false;
  late ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();

    _authSubscription = ref.listenManual<AuthState>(authViewModelProvider, (previous, next) {
      // Check if widget is still mounted before using context
      if (!mounted) return;
      
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

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final hasUser = await biometricService.hasAnyBiometricUser();
    if (mounted) {
      setState(() {
        _hasBiometricUser = hasUser;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.close();
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

  Future<void> _handleBiometricLogin() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    
    // Get the last user who had biometric enabled
    final lastUserId = await biometricService.getLastBiometricUserId();
    if (lastUserId == null) {
      showMySnackBar(
        context: context,
        message: 'No biometric user found',
        color: Colors.red,
      );
      return;
    }

    // Get credentials using biometric authentication
    final credentials = await biometricService.getBiometricCredentials(lastUserId);
    
    if (credentials != null) {
      final email = credentials['email']!;
      final password = credentials['password']!;
      
      await ref.read(authViewModelProvider.notifier).login(
        email: email,
        password: password,
      );
    } else {
      showMySnackBar(
        context: context,
        message: 'Biometric authentication failed',
        color: Colors.red,
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decorative Top Element
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.withOpacity(0.2),
                              Colors.blue.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        "RentEasy",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        "Welcome back, ${widget.userRole}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Main Card
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyTextformfield(
                                controller: _emailController,
                                labelText: "Email Address",
                                hintText: "Enter your email",
                                errorMessage: "Email is required",
                                prefixIcon: Icons.email_rounded,
                              ),

                              const SizedBox(height: 18),

                              MyTextformfield(
                                controller: _passwordController,
                                labelText: "Password",
                                hintText: "Enter your password",
                                obscureText: _obscurePassword,
                                errorMessage: "Password is required",
                                prefixIcon: Icons.lock_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Login Button with Gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue,
                                      Colors.blue.shade700,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: authState.status == AuthStatus.loading
                                        ? null
                                        : _handleLogin,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 24,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (authState.status ==
                                              AuthStatus.loading)
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                                  CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.login_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          const SizedBox(width: 12),
                                          Text(
                                            authState.status ==
                                                    AuthStatus.loading
                                                ? "Logging In..."
                                                : "Log In",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Fingerprint Login Button
                              if (_hasBiometricUser) ...[
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: authState.status ==
                                              AuthStatus.loading
                                          ? null
                                          : _handleBiometricLogin,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 24,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.fingerprint_rounded,
                                              color: Colors.blue.shade700,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Fingerprint Login',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      "New here?",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade300,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Sign Up Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 24,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Create Account",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.blue,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
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
