import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';

final getWishlistRoomsUsecaseProvider = Provider<GetWishlistRoomsUsecase>((ref) {
  return GetWishlistRoomsUsecase(ref.read(wishlistRepositoryProvider));
});

class GetWishlistRoomsUsecase {
  final IWishlistRepository repository;

  GetWishlistRoomsUsecase(this.repository);

  Future<Either<Failure, List<AddRoomEntity>>> call(String userId) async {
    return await repository.getWishlistRooms(userId);
  }
}
