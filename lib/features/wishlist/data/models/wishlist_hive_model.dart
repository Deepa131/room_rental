import 'package:hive_flutter/hive_flutter.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';

part 'wishlist_hive_model.g.dart';

@HiveType(typeId: AuthHiveConstants.wishlistTypeId)
class WishlistHiveModel {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final List<String> roomIds;

  WishlistHiveModel({
    required this.userId,
    required this.roomIds,
  });

  // Add room to wishlist
  WishlistHiveModel addRoom(String roomId) {
    if (!roomIds.contains(roomId)) {
      return WishlistHiveModel(
        userId: userId,
        roomIds: [...roomIds, roomId],
      );
    }
    return this;
  }

  // Remove room from wishlist
  WishlistHiveModel removeRoom(String roomId) {
    return WishlistHiveModel(
      userId: userId,
      roomIds: roomIds.where((id) => id != roomId).toList(),
    );
  }

  // Check if room is in wishlist
  bool hasRoom(String roomId) {
    return roomIds.contains(roomId);
  }
}
