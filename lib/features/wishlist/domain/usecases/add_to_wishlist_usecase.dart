import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';

final addToWishlistUsecaseProvider = Provider<AddToWishlistUsecase>((ref) {
  return AddToWishlistUsecase(ref.read(wishlistRepositoryProvider));
});

class AddToWishlistUsecase {
  final IWishlistRepository repository;

  AddToWishlistUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userId, String roomId) async {
    return await repository.addToWishlist(userId, roomId);
  }
}
