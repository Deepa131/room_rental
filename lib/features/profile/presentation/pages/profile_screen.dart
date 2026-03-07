import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/biometric_auth_service.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/presentation/pages/edit_profile_page.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:room_rental/features/onboarding/presentation/pages/onboardingthree_page.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _checkBiometricStatus();
    });
  }

  Future<void> _checkBiometricStatus() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();

    if (userId != null) {
      final isAvailable = await biometricService.canCheckBiometrics();
      final isEnabled = await biometricService.isBiometricEnabled(userId);
      setState(() {
        _biometricAvailable = isAvailable;
        _biometricEnabled = isEnabled;
      });
    }
  }

  Future<void> _refreshUserData() async {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    
    if (userId != null) {
    }
  }

  Future<void> _toggleBiometric() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final userSession = ref.read(userSessionServiceProvider);
    final authState = ref.read(authViewModelProvider);
    final userId = userSession.getUserId();
    final email = authState.authEntity?.email ?? userSession.getUserEmail();

    if (userId == null || email == null) {
      showMySnackBar(
        context: context,
        message: 'User information not found',
        color: Colors.red,
      );
      return;
    }

    if (_biometricEnabled) {
      await biometricService.disableBiometric(userId);
      setState(() {
        _biometricEnabled = false;
      });
      showMySnackBar(
        context: context,
        message: 'Fingerprint login disabled',
      );
    } else {
      String? confirmed;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final passwordController = TextEditingController();
          return AlertDialog(
            title: const Text('Enable Fingerprint Login'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your password to enable fingerprint login:'),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  confirmed = passwordController.text.trim();
                  Navigator.pop(dialogContext);
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (confirmed == null || confirmed!.isEmpty) return;

      final canCheck = await biometricService.canCheckBiometrics();
      if (!canCheck) {
        final isSupported = await biometricService.isDeviceSupported();
        if (!mounted) return;
        
        if (!isSupported) {
          showMySnackBar(
            context: context,
            message: 'Your device does not support fingerprint authentication',
            color: Colors.red,
          );
        } else {
          showMySnackBar(
            context: context,
            message: 'Please set up fingerprint in your device settings first',
            color: Colors.orange,
          );
        }
        return;
      }

      showMySnackBar(
        context: context,
        message: 'Verifying password...',
      );

      final authResult = await ref.read(authReposioryProvider).login(email, confirmed!);
      
      authResult.fold(
        (failure) {
          if (!mounted) return;
          showMySnackBar(
            context: context,
            message: 'Incorrect password. Please try again.',
            color: Colors.red,
          );
        },
        (_) async {
          if (!mounted) return;
          showMySnackBar(
            context: context,
            message: 'Password verified! Now scan your fingerprint to enable it...',
          );

          final fingerAuthenticated = await biometricService.authenticate(
            reason: 'Scan your fingerprint to enable fingerprint login',
          );

          if (!fingerAuthenticated) {
            if (!mounted) return;
            showMySnackBar(
              context: context,
              message: 'Fingerprint scan failed. Please try again.',
              color: Colors.red,
            );
            return;
          }

          if (!mounted) return;
          final success = await biometricService.enableBiometric(
            userId,
            email,
            confirmed!,
          );

          if (!mounted) return;

          if (success) {
            await biometricService.setLastBiometricUserId(userId);
            setState(() {
              _biometricEnabled = true;
            });
            showMySnackBar(
              context: context,
              message: 'Fingerprint login enabled successfully! Your fingerprint is now registered.',
            );
          } else {
            showMySnackBar(
              context: context,
              message: 'Failed to save fingerprint. Please try again.',
              color: Colors.red,
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.read(userSessionServiceProvider);
    final authState = ref.watch(authViewModelProvider);
    
    final fullName = authState.authEntity?.fullName ?? userSession.getUserFullName() ?? 'User';
    final email = authState.authEntity?.email ?? userSession.getUserEmail() ?? '';
    final role = authState.authEntity?.role ?? userSession.getUserRole() ?? '';
    
    final profilePicture = authState.authEntity?.profilePicture;
    
    String? profileImageUrl;
    if (profilePicture != null && 
        profilePicture.isNotEmpty && 
        profilePicture != 'default-profile.png' &&
        profilePicture != 'null' &&
        !profilePicture.contains('default')) {
      profileImageUrl = ImageUrlHelper.getProfilePictureUrl(profilePicture);
    }
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.95),
                          backgroundImage: profileImageUrl != null 
                              ? NetworkImage(profileImageUrl)
                              : null,
                          onBackgroundImageError: profileImageUrl != null
                              ? (exception, stackTrace) {
                                  debugPrintStack(label: 'Failed to load profile picture: $exception');
                                }
                              : null,
                          child: profileImageUrl == null
                              ? const Icon(Icons.person_rounded, size: 50, color: Colors.blue)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Edit Profile Button
                  MyIconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    text: 'Edit Profile',
                    icon: Icons.edit_rounded,
                    backgroundColor: AppColors.primary,
                  ),

                  const SizedBox(height: 12),

                  // Biometric Authentication Button
                  if (_biometricAvailable)
                    MyIconButton(
                      onPressed: _toggleBiometric,
                      text: _biometricEnabled
                          ? "Disable Fingerprint Login"
                          : "Enable Fingerprint Login",
                      icon: _biometricEnabled 
                          ? Icons.fingerprint_rounded 
                          : Icons.fingerprint_outlined,
                      backgroundColor: _biometricEnabled ? Colors.orange : Colors.green,
                    ),

                  if (_biometricAvailable) const SizedBox(height: 12),

                  // Logout Button
                  MyIconButton(
                    onPressed: () {
                      ref.read(authViewModelProvider.notifier).logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingThreePage(),
                        ),
                        (route) => false,
                      );
                    },
                    text: 'Logout',
                    icon: Icons.logout_rounded,
                    backgroundColor: Colors.red,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
