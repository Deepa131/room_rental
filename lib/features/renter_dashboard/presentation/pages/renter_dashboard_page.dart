import 'package:flutter/material.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/appointment_screen.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/profile_screen.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/home_screen.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/wishlist_screen.dart';

class RenterDashboardPage extends StatefulWidget {
  const RenterDashboardPage({super.key});

  @override
  State<RenterDashboardPage> createState() => _RenterDashboardPageState();
}

class _RenterDashboardPageState extends State<RenterDashboardPage> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const AppointmentScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}