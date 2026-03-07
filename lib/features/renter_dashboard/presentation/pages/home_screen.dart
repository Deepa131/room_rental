import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/room_details_page.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';
import 'package:room_rental/features/wishlist/presentation/view_model/wishlist_view_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPriceRange = 'all';
  String _selectedRoomType = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addRoomViewModelProvider.notifier).getAllRooms();
      ref.read(typeViewmodelProvider.notifier).getAllTypes();

      // Load wishlist
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getUserId();
      if (userId != null && userId.isNotEmpty) {
        ref.read(wishlistViewModelProvider.notifier).loadWishlist(userId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 3; // Large tablets/desktops
    if (width >= 600) return 2; // Medium tablets
    return 1; // Mobile phones
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1200) return 0.75; // Large tablets/desktops
    if (width >= 600) return 0.85; // Medium tablets
    return 1.1; // Mobile phones
  }

  List<AddRoomEntity> _getFilteredRooms(List<AddRoomEntity> rooms) {
    final searchTerm = _searchController.text.trim().toLowerCase();

    return rooms.where((room) {
      // Search filter
      final matchesSearch =
          searchTerm.isEmpty ||
          room.roomTitle.toLowerCase().contains(searchTerm) ||
          room.location.toLowerCase().contains(searchTerm);

      // Type filter
      final matchesType =
          _selectedRoomType == 'all' ||
          room.roomType.typeId == _selectedRoomType;

      // Price filter
      final price = room.monthlyPrice;
      final matchesPrice =
          _selectedPriceRange == 'all' ||
          (_selectedPriceRange == 'lt-5000' && price < 5000) ||
          (_selectedPriceRange == '5000-10000' &&
              price >= 5000 &&
              price <= 10000) ||
          (_selectedPriceRange == 'gt-10000' && price > 10000);

      return matchesSearch && matchesType && matchesPrice;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final addRoomState = ref.watch(addRoomViewModelProvider);
    final roomTypeState = ref.watch(typeViewmodelProvider);
    final wishlistState = ref.watch(wishlistViewModelProvider);
    final filteredRooms = _getFilteredRooms(addRoomState.availableRooms);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final childAspectRatio = _getChildAspectRatio(screenWidth);
    final horizontalPadding = screenWidth >= 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            snap: false,
            floating: false,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Rooms',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your perfect rental space',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth >= 600 ? 800 : double.infinity,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search rooms, location...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPriceRange,
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPriceRange = value!;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('All Prices'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'lt-5000',
                                        child: Text('Below 5K'),
                                      ),
                                      DropdownMenuItem(
                                        value: '5000-10000',
                                        child: Text('5K - 10K'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'gt-10000',
                                        child: Text('Above 10K'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedRoomType,
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRoomType = value!;
                                      });
                                    },
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'all',
                                        child: Text('All Types'),
                                      ),
                                      if (roomTypeState.status ==
                                          RoomTypeStatus.loaded)
                                        ...roomTypeState.types
                                            .where(
                                              (type) => type.status == 'active',
                                            )
                                            .map(
                                              (type) => DropdownMenuItem(
                                                value: type.typeId,
                                                child: Text(type.typeName),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Listings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${filteredRooms.length} properties found',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${filteredRooms.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              20,
            ),
            sliver: addRoomState.status == AddRoomStatus.loading
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: Colors.blue),
                          const SizedBox(height: 16),
                          Text(
                            'Loading rooms...',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredRooms.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rooms found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildRoomCard(
                        context,
                        filteredRooms[index],
                        wishlistState,
                      );
                    }, childCount: filteredRooms.length),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    AddRoomEntity room,
    dynamic wishlistState,
  ) {
    final roomId = room.roomId ?? '';
    final isWishlisted = wishlistState.wishlistRoomIds.contains(roomId);
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RoomDetailsPage(room: room)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: room.images != null && room.images!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: ImageUrlHelper.getImageUrl(
                              room.images![0],
                            ),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[600],
                                size: 48,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.roomTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Wishlist Button
                      InkWell(
                        onTap: () async {
                          if (roomId.isNotEmpty &&
                              userId != null &&
                              userId.isNotEmpty) {
                            final isCurrentlyInWishlist = isWishlisted;
                            final success = await ref
                                .read(wishlistViewModelProvider.notifier)
                                .toggleWishlist(userId, roomId);

                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isCurrentlyInWishlist
                                        ? 'Removed from wishlist'
                                        : 'Added to wishlist',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: isCurrentlyInWishlist
                                      ? Colors.orange[700]
                                      : Colors.green[700],
                                ),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isWishlisted
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isWishlisted
                                ? Colors.amber[600]
                                : Colors.grey[400],
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NPR ${room.monthlyPrice.toStringAsFixed(0)}/month',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // View Details Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'View Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
