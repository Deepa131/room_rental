import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/features/add_room/presentation/pages/add_room_page.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/add_room/presentation/widgets/my_room_card.dart';

class OwnerHomeScreen extends ConsumerStatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  ConsumerState<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends ConsumerState<OwnerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyRooms();
    });
  }

  void _loadMyRooms() {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    if (userId != null) {
      ref.read(addRoomViewModelProvider.notifier).getMyRooms(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addRoomState = ref.watch(addRoomViewModelProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Rooms',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage and view your listings',
                          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.85)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildStats(
                    totalListings: addRoomState.myRooms.length,
                    approvedListings: addRoomState.availableRooms.length,
                    bookedListings: addRoomState.bookedRooms.length,
                  ),
                  const SizedBox(height: 16),
                  MyButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => const AddRoomPage(),
                        ),
                      ).then((_) => _loadMyRooms());
                    },
                    text: "Add New Room",
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'My Listings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: _buildMyListingsSliver(addRoomState),
          ),
        ],
      ),
    );
  }

  // STATS (DISPLAYS REAL ROOM COUNTS)
  Widget _buildStats({
    required int totalListings,
    required int approvedListings,
    required int bookedListings,
  }) {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: [
          _StatCard(title: "Total Listings", value: totalListings.toString()),
          _StatCard(title: "Available", value: approvedListings.toString()),
          _StatCard(title: "Rented", value: bookedListings.toString()),
        ],
      ),
    );
  }

  Widget _buildMyListingsSliver(dynamic addRoomState) {
    if (addRoomState.status.toString() == 'AddRoomStatus.loading') {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (addRoomState.myRooms.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No Listings Yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your first room to get started',
                style: TextStyle(fontSize: 12, color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final room = addRoomState.myRooms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: MyRoomCard(
              title: room.roomTitle ?? 'Untitled Room',
              location: room.location ?? '',
              roomType: room.roomType?.typeName ?? 'Studio',
              status: room.isAvailable ? 'Available' : 'Rented',
              price: room.monthlyPrice?.toString() ?? '0',
              imageUrl: room.images != null && room.images!.isNotEmpty
                  ? ImageUrlHelper.getImageUrl(room.images![0])
                  : null,
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddRoomPage(roomId: room.roomId),
                  ),
                ).then((_) => _loadMyRooms());
              },
              onDelete: () {
                _showDeleteConfirmation(room.roomId ?? '');
              },
              onToggleAvailability: () {
                _toggleRoomAvailability(room);
              },
            ),
          );
        },
        childCount: addRoomState.myRooms.length,
      ),
    );
  }

  Widget _buildMyListings(dynamic addRoomState) {
    if (addRoomState.status.toString() == 'AddRoomStatus.loading') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (addRoomState.myRooms.isEmpty) {
      return _emptyListings();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: addRoomState.myRooms.length,
        itemBuilder: (context, index) {
          final room = addRoomState.myRooms[index];
          return MyRoomCard(
            title: room.roomTitle ?? 'Untitled Room',
            location: room.location ?? '',
            roomType: room.roomType?.typeName ?? 'Studio',
            status: room.isAvailable ? 'Available' : 'Rented',
            price: room.monthlyPrice?.toString() ?? '0',
            imageUrl: room.images != null && room.images!.isNotEmpty
                ? ImageUrlHelper.getImageUrl(room.images![0])
                : null,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRoomPage(roomId: room.roomId),
                ),
              ).then((_) => _loadMyRooms());
            },
            onDelete: () {
              _showDeleteConfirmation(room.roomId ?? '');
            },
            onToggleAvailability: () {
              _toggleRoomAvailability(room);
            },
          );
        },
      ),
    );
  }

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

  void _showDeleteConfirmation(String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Room', style: TextStyle(color: context.textPrimary)),
        content: Text(
          'Are you sure you want to delete this room?',
          style: TextStyle(color: context.textSecondary),
        ),
        backgroundColor: context.surfaceColor,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRoom(roomId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteRoom(String roomId) {
    final userSession = ref.read(userSessionServiceProvider);
    final ownerId = userSession.getUserId();
    
    ref.read(addRoomViewModelProvider.notifier).deleteRoom(roomId, ownerId: ownerId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Room deleted successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete room'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _toggleRoomAvailability(dynamic room) {
    final newAvailabilityStatus = !room.isAvailable;
    ref
        .read(addRoomViewModelProvider.notifier)
        .updateRoom(
          roomId: room.roomId ?? '',
          ownerId: room.ownerId ?? '',
          ownerContactNumber: room.ownerContactNumber ?? '',
          roomTitle: room.roomTitle ?? 'Untitled',
          monthlyPrice: room.monthlyPrice ?? 0.0,
          location: room.location ?? '',
          roomType: room.roomType,
          description: room.description,
          images: room.images,
          videos: room.videos,
          isAvailable: newAvailabilityStatus,
        )
        .then((_) {
          _loadMyRooms();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newAvailabilityStatus ? 'Marked as Available' : 'Marked as Rented',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update room status'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        });
  }
}

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
