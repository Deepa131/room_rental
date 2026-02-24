import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/home_screen.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';
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

class FakeAddRoomViewModel extends AddRoomViewModel {
  FakeAddRoomViewModel(this._state);
  final AddRoomState _state;

  @override
  AddRoomState build() => _state;

  @override
  Future<void> getAllRooms() async {}
}

class FakeRoomTypeViewModel extends RoomTypeViewmodel {
  FakeRoomTypeViewModel(this._state);
  final RoomTypeState _state;

  @override
  RoomTypeState build() => _state;

  @override
  Future<void> getAllTypes() async {}
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

Widget createTestWidget({
  AddRoomState? addRoomState,
  RoomTypeState? roomTypeState,
  WishlistState? wishlistState,
}) {
  return ProviderScope(
    overrides: [
      addRoomViewModelProvider.overrideWith(() => FakeAddRoomViewModel(addRoomState ?? const AddRoomState())),
      typeViewmodelProvider.overrideWith(() => FakeRoomTypeViewModel(roomTypeState ?? const RoomTypeState())),
      wishlistViewModelProvider.overrideWith(() => FakeWishlistViewModel(wishlistState ?? WishlistState.initial())),
      userSessionServiceProvider.overrideWithValue(
        FakeUserSessionService(userId: null),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  final sampleRoom = makeRoom(roomId: '1');
  final loadedState = AddRoomState(
    status: AddRoomStatus.loaded,
    availableRooms: [sampleRoom],
  );

  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.text('Explore Rooms'), findsOneWidget);
    expect(find.text('Find your perfect rental space'), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.text('Search rooms, location...'), findsOneWidget);
  });

  testWidgets('shows properties count', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.text('1 properties found'), findsOneWidget);
  });

  testWidgets('shows room card details', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.text(sampleRoom.roomTitle), findsOneWidget);
    expect(find.text(sampleRoom.location), findsOneWidget);
    expect(
      find.text('NPR ${sampleRoom.monthlyPrice.toStringAsFixed(0)}/month'),
      findsOneWidget,
    );
  });

  testWidgets('shows view details button', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.text('View Details'), findsOneWidget);
  });

  testWidgets('shows wishlist outline icon when not wishlisted', (tester) async {
    await tester.pumpWidget(createTestWidget(addRoomState: loadedState));
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('shows empty state when no rooms', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        addRoomState: const AddRoomState(
          status: AddRoomStatus.loaded,
          availableRooms: [],
        ),
      ),
    );
    expect(find.text('No rooms found'), findsOneWidget);
    expect(find.text('Try adjusting your filters'), findsOneWidget);
  });

  testWidgets('shows loading state when fetching rooms', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        addRoomState: const AddRoomState(status: AddRoomStatus.loading),
      ),
    );
    expect(find.text('Loading rooms...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
