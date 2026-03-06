import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/usecases/create_room_usecase.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class MockAddRoomRepository extends Mock implements IAddRoomRepository {}

void main() {
  late CreateRoomUsecase usecase;
  late MockAddRoomRepository mockRepository;

  setUp(() {
    mockRepository = MockAddRoomRepository();
    usecase = CreateRoomUsecase(addRoomRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(AddRoomEntity(
      ownerId: 'fallback',
      ownerContactNumber: '9800000000',
      roomTitle: 'Fallback',
      monthlyPrice: 10000,
      location: 'Kathmandu',
      roomType: RoomTypeEntity(typeId: '1', typeName: 'Single', status: 'active'),
      isAvailable: true,
      approvalStatus: 'pending',
    ));
  });

  const tParams = CreateRoomParams(
    ownerId: 'owner123',
    ownerContactNumber: '9800000000',
    roomTitle: 'Cozy Room',
    monthlyPrice: 12000,
    location: 'Kathmandu',
    roomType: RoomTypeEntity(typeId: '1', typeName: 'Single Room', status: 'active'),
    description: 'A nice cozy room',
    images: ['image1.jpg', 'image2.jpg'],
    videos: ['video1.mp4'],
    locationCoords: {
      'latitude': 27.7172,
      'longitude': 85.3240,
      'address': 'Kathmandu, Nepal',
    },
  );

  group('CreateRoomUsecase', () {
    test('should create room successfully and return true', () async {
      when(() => mockRepository.createRoom(any()))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.createRoom(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when room creation fails', () async {
      when(() => mockRepository.createRoom(any()))
          .thenAnswer((_) async => const Right(false));

      final result = await usecase(tParams);

      expect(result, const Right(false));
      verify(() => mockRepository.createRoom(any())).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to create room', statusCode: 400);
      when(() => mockRepository.createRoom(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left(failure));
      verify(() => mockRepository.createRoom(any())).called(1);
    });

    test('should return ApiFailure for invalid data', () async {
      const failure = ApiFailure(message: 'Invalid room data', statusCode: 400);
      when(() => mockRepository.createRoom(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left(failure));
      verify(() => mockRepository.createRoom(any())).called(1);
    });
  });
}
