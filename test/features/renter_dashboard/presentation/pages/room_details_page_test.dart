import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/appointment/presentation/state/appointment_state.dart';
import 'package:room_rental/features/appointment/presentation/view_model/appointment_viewmodel.dart';
import 'package:room_rental/features/renter_dashboard/presentation/pages/room_details_page.dart';
import 'package:room_rental/features/wishlist/presentation/state/wishlist_state.dart';
import 'package:room_rental/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import '../../../../test_utils.dart';

class FakeUserSessionService implements UserSessionService {
  @override
  Future<void> clearUserSession() async {}

  @override
  String? getUserEmail() => null;

  @override
  String? getUserFullName() => null;

  @override
  String? getUserId() => null;

  @override
  String? getUserProfileImage() => null;

  @override
  String? getUserRole() => null;

  @override
  bool isLoggedIn() => false;

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
}

class FakeAppointmentViewModel extends AppointmentViewModel {
  FakeAppointmentViewModel(this._state);
  final AppointmentState _state;

  @override
  AppointmentState build() => _state;
}

Widget createTestWidget() {
  final room = makeRoom(images: null, videos: null, ownerName: 'Owner Name');

  return ProviderScope(
    overrides: [
      wishlistViewModelProvider.overrideWith(
        () => FakeWishlistViewModel(WishlistState.initial()),
      ),
      appointmentViewModelProvider.overrideWith(
        () => FakeAppointmentViewModel(const AppointmentState()),
      ),
      userSessionServiceProvider.overrideWithValue(FakeUserSessionService()),
    ],
    child: MaterialApp(home: RoomDetailsPage(room: room)),
  );
}

void main() {
  testWidgets('shows room title and location', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Cozy Room'), findsOneWidget);
    expect(find.text('Kathmandu'), findsOneWidget);
  });

  testWidgets('shows price with /month', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('NPR'), findsOneWidget);
    expect(find.text('10000'), findsOneWidget);
    expect(find.text('/month'), findsOneWidget);
  });

  testWidgets('shows image placeholder when no media', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
  });

  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Room Details'), findsOneWidget);
  });

  testWidgets('shows contact owner section', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Contact Owner'), findsOneWidget);
    expect(find.text('Owner Name'), findsOneWidget);
  });

  testWidgets('shows book appointment button', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Book Appointment'), findsOneWidget);
  });
}
