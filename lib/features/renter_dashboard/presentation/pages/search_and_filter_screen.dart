import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';
import 'package:room_rental/features/add_room/presentation/widgets/my_room_card.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/room_details_page.dart';

class SearchAndFilterScreen extends ConsumerStatefulWidget {
  const SearchAndFilterScreen({super.key});

  @override
  ConsumerState<SearchAndFilterScreen> createState() =>
      _SearchAndFilterScreenState();
}

class _SearchAndFilterScreenState extends ConsumerState<SearchAndFilterScreen> {
  late TextEditingController _searchController;
  String _selectedType = 'all';
  RangeValues _priceRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addRoomViewModelProvider.notifier).getAllRooms();
      ref.read(typeViewmodelProvider.notifier).getAllTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredRooms(List<dynamic> rooms) {
    return rooms.where((room) {
      final matchesSearch = _searchController.text.isEmpty ||
          (room.roomTitle?.toLowerCase() ?? '')
              .contains(_searchController.text.toLowerCase()) ||
          (room.location?.toLowerCase() ?? '')
              .contains(_searchController.text.toLowerCase());

      final matchesType = _selectedType == 'all' ||
          room.roomType?.typeId == _selectedType ||
          room.roomType?.typeName == _selectedType;

      final matchesPrice =
          (room.monthlyPrice ?? 0) >= _priceRange.start &&
              (room.monthlyPrice ?? 0) <= _priceRange.end;

      final isAvailable = room.isAvailable;

      return matchesSearch && matchesType && matchesPrice && isAvailable;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final addRoomState = ref.watch(addRoomViewModelProvider);
    final roomTypeState = ref.watch(typeViewmodelProvider);
    final filteredRooms = _getFilteredRooms(addRoomState.availableRooms);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue, Colors.blue.shade600],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.blue, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Search Rooms',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your perfect space',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Room name or location...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Type Filter
                  Text(
                    'Room Type',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'All',
                          selected: _selectedType == 'all',
                          onTap: () => setState(() => _selectedType = 'all'),
                        ),
                        ...roomTypeState.types.map((type) {
                          return _buildFilterChip(
                            label: type.typeName,
                            selected: _selectedType == type.typeId ||
                                _selectedType == type.typeName,
                            onTap: () =>
                                setState(() => _selectedType = type.typeId ?? ''),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price Range Filter
                  Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${_priceRange.start.toStringAsFixed(0)} - ₹${_priceRange.end.toStringAsFixed(0)}/month',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey[300],
                    onChanged: (RangeValues values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // Results Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                '${filteredRooms.length} results found',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Results List or Empty State
          if (filteredRooms.isEmpty) 
            SliverFillRemaining(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No rooms found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = filteredRooms[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailsPage(room: room),
                            ),
                          );
                        },
                        child: MyRoomCard(
                          title: room.roomTitle ?? 'Untitled',
                          location: room.location ?? '',
                          roomType: room.roomType?.typeName ?? 'Studio',
                          status: 'Available',
                          imageUrl: room.images != null &&
                                  room.images!.isNotEmpty
                              ? room.images![0]
                              : null,
                          price: room.monthlyPrice?.toString() ?? '0',
                        ),
                      ),
                    );
                  },
                  childCount: filteredRooms.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: context.surfaceColor,
        selectedColor: AppColors.primary.withAlpha(51),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : context.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : context.dividerColor,
        ),
      ),
    );
  }
}
