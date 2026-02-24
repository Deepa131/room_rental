import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/wishlist_screen.dart';
import 'package:room_rental/features/wishlist/presentation/state/wishlist_state.dart';
import 'package:room_rental/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import '../../../../test_utils.dart';

class FakeUserSessionService implements UserSessionService {
  FakeUserSessionService({this.userId});

  final String? userId;

  @override
  Future<void> clearUserSession() async {}

  @override
  String? getUserEmail() => null;

  @override
  String? getUserFullName() => null;

  @override
  String? getUserId() => userId;

  @override
  String? getUserProfileImage() => null;

  @override
  String? getUserRole() => null;

  @override
  bool isLoggedIn() => userId != null;

  @override
  Future<void> saveUserSession({
    required String userId,
    required String fullName,
    required String email,
    required String role,
    String? profileImage,
  }) async {}

  @override
  getCurrentUserId() {}
}

class FakeWishlistViewModel extends WishlistViewModel {
  FakeWishlistViewModel(this._state);
  final WishlistState _state;

  @override
  WishlistState build() => _state;

  @override
  Future<void> loadWishlist(String userId) async {}

  @override
  Future<bool> toggleWishlist(String userId, String roomId) async => true;
}

Widget createTestWidget({WishlistState? wishlistState}) {
  return ProviderScope(
    overrides: [
      wishlistViewModelProvider.overrideWith(() => FakeWishlistViewModel(wishlistState ?? WishlistState.initial())),
      userSessionServiceProvider.overrideWithValue(
        FakeUserSessionService(userId: null),
      ),
    ],
    child: const MaterialApp(home: WishlistScreen()),
  );
}

void main() {
  testWidgets('shows wishlist title', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('My Wishlist'), findsOneWidget);
  });

  testWidgets('shows loading indicator when loading', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        wishlistState: const WishlistState(
          isLoading: true,
          wishlistRooms: [],
          wishlistRoomIds: {},
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when list is empty', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('No rooms in wishlist'), findsOneWidget);
    expect(find.text('Start adding rooms you like!'), findsOneWidget);
  });

  testWidgets('shows room card when wishlist has items', (tester) async {
    final room = makeRoom(roomId: '1');
    await tester.pumpWidget(
      createTestWidget(
        wishlistState: WishlistState(
          isLoading: false,
          wishlistRooms: [room],
          wishlistRoomIds: {'1'},
        ),
      ),
    );

    expect(find.text(room.roomTitle), findsOneWidget);
    expect(find.text(room.location), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });
}
