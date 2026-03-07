import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/usecases/get_wishlist_rooms_usecase.dart';

class MockWishlistRepository extends Mock implements IWishlistRepository {}

void main() {
  late GetWishlistRoomsUsecase usecase;
  late MockWishlistRepository mockRepository;

  setUp(() {
    mockRepository = MockWishlistRepository();
    usecase = GetWishlistRoomsUsecase(mockRepository);
  });

  const tUserId = 'user123';

  final tRoomType = RoomTypeEntity(
    typeId: '1',
    typeName: 'Single Room',
    status: 'active',
  );

  final tWishlistRooms = [
    AddRoomEntity(
      roomId: '1',
      ownerId: 'owner1',
      ownerName: 'John Owner',
      ownerContactNumber: '9800000000',
      roomTitle: 'Wishlist Room 1',
      monthlyPrice: 12000,
      location: 'Kathmandu',
      roomType: tRoomType,
      description: 'Nice room',
      images: ['image1.jpg'],
      videos: [],
      isAvailable: true,
      approvalStatus: 'approved',
      createdAt: DateTime(2024, 1, 1),
    ),
    AddRoomEntity(
      roomId: '2',
      ownerId: 'owner2',
      ownerName: 'Jane Owner',
      ownerContactNumber: '9811111111',
      roomTitle: 'Wishlist Room 2',
      monthlyPrice: 15000,
      location: 'Lalitpur',
      roomType: tRoomType,
      description: 'Spacious room',
      images: ['image2.jpg'],
      videos: [],
      isAvailable: true,
      approvalStatus: 'approved',
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  group('GetWishlistRoomsUsecase', () {
    test('should return list of wishlist rooms when successful', () async {
      when(() => mockRepository.getWishlistRooms(tUserId))
          .thenAnswer((_) async => Right(tWishlistRooms));

      final result = await usecase(tUserId);

      expect(result, Right(tWishlistRooms));
      expect((result as Right).value.length, 2);
      verify(() => mockRepository.getWishlistRooms(tUserId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no rooms in wishlist', () async {
      when(() => mockRepository.getWishlistRooms(tUserId))
          .thenAnswer((_) async => const Right([]));

      final result = await usecase(tUserId);

      expect(result, const Right(<AddRoomEntity>[]));
      expect((result as Right).value.length, 0);
      verify(() => mockRepository.getWishlistRooms(tUserId)).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch wishlist', statusCode: 500);
      when(() => mockRepository.getWishlistRooms(tUserId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tUserId);

      expect(result, const Left(failure));
      verify(() => mockRepository.getWishlistRooms(tUserId)).called(1);
    });
  });
}
