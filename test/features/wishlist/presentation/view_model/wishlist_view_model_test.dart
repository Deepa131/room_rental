import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import 'package:room_rental/features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import 'package:room_rental/features/wishlist/domain/usecases/get_wishlist_rooms_usecase.dart';
import 'package:room_rental/features/wishlist/domain/usecases/is_in_wishlist_usecase.dart';
import 'package:room_rental/features/wishlist/presentation/view_model/wishlist_view_model.dart';

class MockAddToWishlistUsecase extends Mock implements AddToWishlistUsecase {}
class MockRemoveFromWishlistUsecase extends Mock implements RemoveFromWishlistUsecase {}
class MockGetWishlistRoomsUsecase extends Mock implements GetWishlistRoomsUsecase {}
class MockIsInWishlistUsecase extends Mock implements IsInWishlistUsecase {}

void main() {
  late ProviderContainer container;
  late MockAddToWishlistUsecase mockAddToWishlistUsecase;
  late MockRemoveFromWishlistUsecase mockRemoveFromWishlistUsecase;
  late MockGetWishlistRoomsUsecase mockGetWishlistRoomsUsecase;
  late MockIsInWishlistUsecase mockIsInWishlistUsecase;

  setUp(() {
    mockAddToWishlistUsecase = MockAddToWishlistUsecase();
    mockRemoveFromWishlistUsecase = MockRemoveFromWishlistUsecase();
    mockGetWishlistRoomsUsecase = MockGetWishlistRoomsUsecase();
    mockIsInWishlistUsecase = MockIsInWishlistUsecase();

    container = ProviderContainer(
      overrides: [
        addToWishlistUsecaseProvider.overrideWithValue(mockAddToWishlistUsecase),
        removeFromWishlistUsecaseProvider.overrideWithValue(mockRemoveFromWishlistUsecase),
        getWishlistRoomsUsecaseProvider.overrideWithValue(mockGetWishlistRoomsUsecase),
        isInWishlistUsecaseProvider.overrideWithValue(mockIsInWishlistUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tRoomType = RoomTypeEntity(
    typeId: '1',
    typeName: 'Single Room',
    status: 'active',
  );

  final tWishlistRooms = [
    AddRoomEntity(
      roomId: '1',
      ownerId: 'owner1',
      ownerName: 'John',
      ownerContactNumber: '9800000000',
      roomTitle: 'Wishlist Room 1',
      monthlyPrice: 12000,
      location: 'Kathmandu',
      roomType: tRoomType,
      isAvailable: true,
      approvalStatus: 'approved',
    ),
  ];

  const tUserId = 'user123';
  const tRoomId = 'room123';

  group('WishlistViewModel', () {
    test('should load wishlist successfully', () async {
      when(() => mockGetWishlistRoomsUsecase(tUserId))
          .thenAnswer((_) async => Right(tWishlistRooms));

      final viewModel = container.read(wishlistViewModelProvider.notifier);

      await viewModel.loadWishlist(tUserId);

      expect(viewModel.state.wishlistRooms, tWishlistRooms);
      verify(() => mockGetWishlistRoomsUsecase(tUserId)).called(1);
    });

    test('should handle wishlist load error', () async {
      const failure = ApiFailure(message: 'Failed to load wishlist', statusCode: 500);
      when(() => mockGetWishlistRoomsUsecase(tUserId))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(wishlistViewModelProvider.notifier);

      await viewModel.loadWishlist(tUserId);

      expect(viewModel.state.error, 'Failed to load wishlist');
      verify(() => mockGetWishlistRoomsUsecase(tUserId)).called(1);
    });

    test('should toggle wishlist successfully', () async {
      when(() => mockAddToWishlistUsecase(tUserId, tRoomId))
          .thenAnswer((_) async => const Right(true));

      final viewModel = container.read(wishlistViewModelProvider.notifier);

      final result = await viewModel.toggleWishlist(tUserId, tRoomId);

      expect(result, true);
      verify(() => mockAddToWishlistUsecase(tUserId, tRoomId)).called(1);
    });

    test('should handle toggle error', () async {
      const failure = ApiFailure(message: 'Failed to add to wishlist', statusCode: 400);
      when(() => mockAddToWishlistUsecase(tUserId, tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(wishlistViewModelProvider.notifier);

      final result = await viewModel.toggleWishlist(tUserId, tRoomId);

      expect(result, false);
      verify(() => mockAddToWishlistUsecase(tUserId, tRoomId)).called(1);
    });
  });
}
