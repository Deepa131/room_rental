import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/features/wishlist/presentation/state/wishlist_state.dart';
import '../../../../test_utils.dart';

void main() {
  test('initial has empty lists and not loading', () {
    final state = WishlistState.initial();
    expect(state.isLoading, isFalse);
    expect(state.wishlistRooms, isEmpty);
    expect(state.wishlistRoomIds, isEmpty);
  });

  test('copyWith updates loading and error', () {
    final state = WishlistState.initial();
    final updated = state.copyWith(isLoading: true, error: 'Error');
    expect(updated.isLoading, isTrue);
    expect(updated.error, 'Error');
  });

  test('copyWith updates wishlistRoomIds', () {
    final state = WishlistState.initial();
    final updated = state.copyWith(wishlistRoomIds: {'1', '2'});
    expect(updated.wishlistRoomIds.length, 2);
  });

  test('props equality works', () {
    final room = makeRoom(roomId: '1');
    final a = WishlistState(
      isLoading: false,
      wishlistRooms: [room],
      wishlistRoomIds: {'1'},
    );
    final b = WishlistState(
      isLoading: false,
      wishlistRooms: [room],
      wishlistRoomIds: {'1'},
    );

    expect(a, equals(b));
  });
}
