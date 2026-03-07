import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';

final removeFromWishlistUsecaseProvider = Provider<RemoveFromWishlistUsecase>((ref) {
  return RemoveFromWishlistUsecase(ref.read(wishlistRepositoryProvider));
});

class RemoveFromWishlistUsecase {
  final IWishlistRepository repository;

  RemoveFromWishlistUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userId, String roomId) async {
    return await repository.removeFromWishlist(userId, roomId);
  }
}
