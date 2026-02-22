import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/wishlist/data/models/wishlist_hive_model.dart';

final wishlistLocalDatasourceProvider = Provider<WishlistLocalDatasource>((ref) {
  return WishlistLocalDatasource();
});

class WishlistLocalDatasource {
  Future<Box<WishlistHiveModel>> get _box async {
    if (Hive.isBoxOpen(AuthHiveConstants.wishlistTable)) {
      return Hive.box<WishlistHiveModel>(AuthHiveConstants.wishlistTable);
    }
    return await Hive.openBox<WishlistHiveModel>(AuthHiveConstants.wishlistTable);
  }

  // Get wishlist for a user
  Future<WishlistHiveModel?> getWishlist(String userId) async {
    final box = await _box;
    return box.get(userId);
  }

  // Add room to wishlist
  Future<bool> addToWishlist(String userId, String roomId) async {
    try {
      final box = await _box;
      final wishlist = box.get(userId) ?? WishlistHiveModel(userId: userId, roomIds: []);
      final updatedWishlist = wishlist.addRoom(roomId);
      await box.put(userId, updatedWishlist);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove room from wishlist
  Future<bool> removeFromWishlist(String userId, String roomId) async {
    try {
      final box = await _box;
      final wishlist = box.get(userId);
      if (wishlist != null) {
        final updatedWishlist = wishlist.removeRoom(roomId);
        await box.put(userId, updatedWishlist);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if room is in wishlist
  Future<bool> isInWishlist(String userId, String roomId) async {
    final box = await _box;
    final wishlist = box.get(userId);
    return wishlist?.hasRoom(roomId) ?? false;
  }

  // Get all wishlist room IDs for a user
  Future<List<String>> getWishlistRoomIds(String userId) async {
    final box = await _box;
    final wishlist = box.get(userId);
    return wishlist?.roomIds ?? [];
  }

  // Clear wishlist for a user
  Future<bool> clearWishlist(String userId) async {
    try {
      final box = await _box;
      await box.delete(userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
