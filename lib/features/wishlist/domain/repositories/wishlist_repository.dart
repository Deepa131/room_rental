import 'package:dartz/dartz.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';

abstract interface class IWishlistRepository {
  Future<Either<Failure, bool>> addToWishlist(String userId, String roomId);
  Future<Either<Failure, bool>> removeFromWishlist(String userId, String roomId);
  Future<Either<Failure, bool>> isInWishlist(String userId, String roomId);
  Future<Either<Failure, List<String>>> getWishlistRoomIds(String userId);
  Future<Either<Failure, List<AddRoomEntity>>> getWishlistRooms(String userId);
  Future<Either<Failure, bool>> clearWishlist(String userId);
}
