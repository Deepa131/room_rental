import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/sensors/shake_detector_service.dart';
import 'package:room_rental/core/services/sensors/gyroscope_detector_service.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:room_rental/features/onboarding/presentation/pages/onboardingthree_page.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/appointment_screen.dart';
import 'package:room_rental/features/profile/presentation/pages/profile_screen.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/home_screen.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/wishlist_screen.dart';

class RenterDashboardPage extends ConsumerStatefulWidget {
  const RenterDashboardPage({super.key});

  @override
  ConsumerState<RenterDashboardPage> createState() => _RenterDashboardPageState();
}

class _RenterDashboardPageState extends ConsumerState<RenterDashboardPage> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const AppointmentScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void _handleShakeLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Detected'),
        content: const Text('Shake detected! Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authViewModelProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingThreePage(),
                ),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleLeftTilt() {
    setState(() {
      _selectedIndex = (_selectedIndex - 1 + lstBottomScreen.length) % lstBottomScreen.length;
    });
    
    // Get screen name
    final screenNames = ['Home', 'Appointments', 'Wishlist', 'Profile'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 Tilted Left - ${screenNames[_selectedIndex]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleRightTilt() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % lstBottomScreen.length;
    });
    
    // Get screen name
    final screenNames = ['Home', 'Appointments', 'Wishlist', 'Profile'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 Tilted Right - ${screenNames[_selectedIndex]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GyroscopeDetectorWidget(
      onLeftTilt: _handleLeftTilt,
      onRightTilt: _handleRightTilt,
      child: ShakeDetectorWidget(
        onShakeDetected: _handleShakeLogout,
        child: Scaffold(
          body: lstBottomScreen[_selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded, size: 24),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_rounded, size: 24),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_rounded, size: 24),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded, size: 24),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}