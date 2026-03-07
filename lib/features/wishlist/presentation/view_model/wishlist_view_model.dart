import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'package:room_rental/features/wishlist/domain/usecases/get_wishlist_rooms_usecase.dart';
import 'package:room_rental/features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'package:room_rental/features/wishlist/presentation/state/wishlist_state.dart';

final wishlistViewModelProvider =
    NotifierProvider<WishlistViewModel, WishlistState>(WishlistViewModel.new);

class WishlistViewModel extends Notifier<WishlistState> {
  late final AddToWishlistUsecase _addToWishlistUsecase;
  late final RemoveFromWishlistUsecase _removeFromWishlistUsecase;
  late final GetWishlistRoomsUsecase _getWishlistRoomsUsecase;

  @override
  WishlistState build() {
    _addToWishlistUsecase = ref.read(addToWishlistUsecaseProvider);
    _removeFromWishlistUsecase = ref.read(removeFromWishlistUsecaseProvider);
    _getWishlistRoomsUsecase = ref.read(getWishlistRoomsUsecaseProvider);
    return WishlistState.initial();
  }

  Future<void> loadWishlist(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getWishlistRoomsUsecase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (rooms) {
        final roomIds = rooms.map((room) => room.roomId ?? '').toSet();
        state = state.copyWith(
          isLoading: false,
          wishlistRooms: rooms,
          wishlistRoomIds: roomIds,
          error: null,
        );
      },
    );
  }

  Future<bool> toggleWishlist(String userId, String roomId) async {
    final isInWishlist = state.wishlistRoomIds.contains(roomId);

    if (isInWishlist) {
      final result = await _removeFromWishlistUsecase(userId, roomId);
      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return false;
        },
        (success) {
          if (success) {
            final updatedIds = Set<String>.from(state.wishlistRoomIds)
              ..remove(roomId);
            final updatedRooms = state.wishlistRooms
                .where((room) => room.roomId != roomId)
                .toList();
            state = state.copyWith(
              wishlistRoomIds: updatedIds,
              wishlistRooms: updatedRooms,
              error: null,
            );
          }
          return success;
        },
      );
    } else {
      final result = await _addToWishlistUsecase(userId, roomId);
      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return false;
        },
        (success) {
          if (success) {
            final updatedIds = Set<String>.from(state.wishlistRoomIds)
              ..add(roomId);
            state = state.copyWith(
              wishlistRoomIds: updatedIds,
              error: null,
            );
          }
          return success;
        },
      );
    }
  }

  bool isRoomInWishlist(String roomId) {
    return state.wishlistRoomIds.contains(roomId);
  }
}
