import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_all_rooms_usecase.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class MockAddRoomRepository extends Mock implements IAddRoomRepository {}

void main() {
  late GetAllRoomsUsecase usecase;
  late MockAddRoomRepository mockRepository;

  setUp(() {
    mockRepository = MockAddRoomRepository();
    usecase = GetAllRoomsUsecase(addRoomRepository: mockRepository);
  });

  final tRoomType = RoomTypeEntity(
    typeId: '1',
    typeName: 'Single Room',
    status: 'active',
  );

  final tRooms = [
    AddRoomEntity(
      roomId: '1',
      ownerId: 'owner1',
      ownerName: 'John Owner',
      ownerContactNumber: '9800000000',
      roomTitle: 'Cozy Room in Kathmandu',
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
      roomTitle: 'Spacious Room',
      monthlyPrice: 15000,
      location: 'Lalitpur',
      roomType: tRoomType,
      description: 'Spacious and bright',
      images: ['image2.jpg'],
      videos: [],
      isAvailable: true,
      approvalStatus: 'approved',
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  group('GetAllRoomsUsecase', () {
    test('should return list of rooms when successful', () async {
      when(() => mockRepository.getAllRooms())
          .thenAnswer((_) async => Right(tRooms));

      final result = await usecase();

      expect(result, Right(tRooms));
      expect((result as Right).value.length, 2);
      verify(() => mockRepository.getAllRooms()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no rooms available', () async {
      when(() => mockRepository.getAllRooms())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase();

      expect(result, const Right(<AddRoomEntity>[]));
      expect((result as Right).value.length, 0);
      verify(() => mockRepository.getAllRooms()).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch rooms', statusCode: 500);
      when(() => mockRepository.getAllRooms())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getAllRooms()).called(1);
    });
  });
}
