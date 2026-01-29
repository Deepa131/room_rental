import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../view_model/add_room_viewmodel.dart';
import '../state/add_room_state.dart';
import '../widgets/my_room_card.dart';

class MyRoomsPage extends ConsumerStatefulWidget {
  const MyRoomsPage({super.key});

  @override
  ConsumerState<MyRoomsPage> createState() => _MyRoomsPageState();
}

class _MyRoomsPageState extends ConsumerState<MyRoomsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadMyRooms());
  }

  void _loadMyRooms() {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId();
    if (userId != null) {
      ref.read(addRoomViewModelProvider.notifier).getMyRooms(userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addRoomViewModelProvider);
    final availableRooms = state.availableRooms;
    final bookedRooms = state.bookedRooms;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(context, availableRooms.length, bookedRooms.length),
            const SizedBox(height: 20),
            Expanded(
              child: state.status == AddRoomStatus.loading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRoomList(availableRooms, true),
                        _buildRoomList(bookedRooms, false),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Rooms',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your rooms',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: context.softShadow,
            ),
            child: Icon(Icons.sort_rounded, color: context.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, int availableCount, int bookedCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.softShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: context.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          _buildTab(Icons.house_rounded, 'Available', availableCount),
          _buildTab(Icons.meeting_room_rounded, 'Booked', bookedCount),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int count) {
    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(List rooms, bool isAvailable) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.house_rounded : Icons.meeting_room_rounded,
              size: 64,
              color: context.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              isAvailable ? 'No available rooms' : 'No booked rooms',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];

        final status = room.approvalStatus ?? (room.isAvailable ? 'available' : 'rented');

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MyRoomCard(
            title: room.roomTitle,
            location: room.location,
            roomType: room.roomType.name,
            status: status,
            imageUrl: room.images != null && room.images!.isNotEmpty
                ? room.images!.first
                : null,
            onTap: () {},
            onEdit: () {},
            onDelete: () => _showDeleteDialog(context, room.roomId!),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Room',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(addRoomViewModelProvider.notifier).deleteRoom(roomId);
              // reload my rooms after deletion
              Future.delayed(const Duration(milliseconds: 300), () {
                _loadMyRooms();
              });
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
