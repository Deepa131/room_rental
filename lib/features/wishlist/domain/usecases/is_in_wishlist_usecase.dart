import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';

final isInWishlistUsecaseProvider = Provider<IsInWishlistUsecase>((ref) {
  return IsInWishlistUsecase(ref.read(wishlistRepositoryProvider));
});

class IsInWishlistUsecase {
  final IWishlistRepository repository;

  IsInWishlistUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userId, String roomId) async {
    return await repository.isInWishlist(userId, roomId);
  }
}
