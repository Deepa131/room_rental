import 'package:flutter/material.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/data/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffdbeaf3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              _sectionTitle("Featured Areas"),
              const SizedBox(height: 12),
              _buildFeaturedAreas(),
              const SizedBox(height: 24),
              _sectionTitle("Available Rooms"),
              const SizedBox(height: 14),

              _roomCard(
                image: "assets/images/room1.png",
                title: "1BHK room in Kapan",
                location: "Kapan, Kathmandu",
                price: "NPR 8,000/month",
                type: "1BHK",
              ),

              _roomCard(
                image: "assets/images/room1.png",
                title: "Furnished Room in Koteshwor",
                location: "Koteshwor, Kathmandu",
                price: "NPR 6,000/month",
                type: "Single Room",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xffdbeaf3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find Your Room",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search rooms in Nepal...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'OpenSans Bold',
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildFeaturedAreas() {
    return SizedBox(
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: const [
          _FeaturedArea(title: "Kathmandu", subtitle: "120+ rooms"),
          _FeaturedArea(title: "Pokhara", subtitle: "45+ rooms"),
          _FeaturedArea(title: "Lalitpur", subtitle: "80+ rooms"),
        ],
      ),
    );
  }

  Widget _roomCard({
    required String image,
    required String title,
    required String location,
    required String price,
    required String type,
  }) {
    bool isWishlisted = WishlistData.wishlistRooms.any(
      (room) => room['title'] == title,
    );

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.asset(
                  image,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _roomDetails(
                        title,
                        location,
                        price,
                        type,
                      ),
                    ),
                    _wishlistIcon(
                      isWishlisted,
                      onTap: () {
                        setLocalState(() {
                          if (isWishlisted) {
                            WishlistData.wishlistRooms.removeWhere(
                              (room) => room['title'] == title,
                            );
                            showMySnackBar(
                              context: context,
                              message: "Removed from wishlist",
                              color: Colors.red,
                            );
                          } else {
                            WishlistData.wishlistRooms.add({
                              'image': image,
                              'title': title,
                              'location': location,
                              'price': price,
                              'type': type,
                            });
                            showMySnackBar(
                              context: context,
                              message: "Added to wishlist",
                            );
                          }
                          isWishlisted = !isWishlisted;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _roomDetails(
    String title,
    String location,
    String price,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'OpenSans Bold',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          style: const TextStyle(
            fontFamily: 'OpenSans Regular',
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          price,
          style: const TextStyle(
            fontFamily: 'OpenSans Bold',
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          type,
          style: const TextStyle(
            fontFamily: 'OpenSans Italic',
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _wishlistIcon(bool isWishlisted, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.bookmark,
        size: 36,
        color: isWishlisted ? Colors.amber : Colors.black,
      ),
    );
  }
}

class _FeaturedArea extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FeaturedArea({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans Bold',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'OpenSans Regular',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
