import 'package:flutter/material.dart';
import 'package:room_rental/data/wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdbeaf3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP SECTION
              Container(
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
                    const Text(
                      "Find Your Room",
                      style: TextStyle(
                        fontFamily: 'OpenSans Bold',
                        fontSize: 26,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SEARCH BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Search rooms in Nepal...",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontFamily: 'OpenSans Regular',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FEATURED AREAS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Featured Areas",
                  style: TextStyle(
                    fontFamily: 'OpenSans Bold',
                    fontSize: 18,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _featuredArea("Kathmandu", "120+ rooms"),
                    _featuredArea("Pokhara", "45+ rooms"),
                    _featuredArea("Lalitpur", "80+ rooms"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// AVAILABLE ROOMS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Available Rooms",
                  style: TextStyle(
                    fontFamily: 'OpenSans Bold',
                    fontSize: 18,
                  ),
                ),
              ),

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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// FEATURED AREA WIDGET
  Widget _featuredArea(String title, String subtitle) {
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
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 6),
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
                      child: Column(
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
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isWishlisted) {
                            WishlistData.wishlistRooms.removeWhere(
                              (room) => room['title'] == title,
                            );
                          } else {
                            WishlistData.wishlistRooms.add({
                              'image': image,
                              'title': title,
                              'location': location,
                              'price': price,
                              'type': type,
                            });
                          }
                          isWishlisted = !isWishlisted;
                        });
                      },
                      child: Icon(
                        Icons.bookmark,
                        size: 40,
                        color: isWishlisted ? Colors.amber : Colors.black,
                      ),
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
}