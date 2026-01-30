import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/add_room/presentation/pages/add_room_page.dart';

class OwnerHomeScreen extends ConsumerStatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  ConsumerState<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends ConsumerState<OwnerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userSession = ref.read(userSessionServiceProvider);
    final fullName = userSession.getUserFullName() ?? "Owner";

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, fullName),
              const SizedBox(height: 20),

              _sectionTitle("Your Statistics"),
              const SizedBox(height: 12),
              _buildStats(),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MyButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => const AddRoomPage(),
                      ),
                    );
                  },
                  text: "Add New Room",
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),
              _sectionTitle("My Listings"),
              const SizedBox(height: 40),
              _emptyListings(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER (SAME SHAPE AS RENTER)
  Widget _buildHeader(ThemeData theme, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back!",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE (SAME AS RENTER)
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.textPrimary,
        ),
      ),
    );
  }

  // STATS (LOOKS LIKE FEATURED AREAS)
  Widget _buildStats() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: const [
          _StatCard(title: "Total Listings", value: "0"),
          _StatCard(title: "Pending", value: "0"),
          _StatCard(title: "Approved", value: "0"),
        ],
      ),
    );
  }

  // EMPTY LISTINGS STATE
  Widget _emptyListings() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surfaceVariant,
            child: Icon(Icons.home, size: 36, color: context.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            "No Listings Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Add your first room to start receiving rental requests",
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// STAT CARD (SAME STYLE AS FEATURED AREA)
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
