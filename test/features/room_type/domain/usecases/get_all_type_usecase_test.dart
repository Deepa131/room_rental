import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/usecases/get_all_type_usecase.dart';

class MockRoomTypeRepository extends Mock implements IRoomTypeRepository {}

void main() {
  late GetAllTypeUsecase usecase;
  late MockRoomTypeRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomTypeRepository();
    usecase = GetAllTypeUsecase(typeRepository: mockRepository);
  });

  final tRoomTypes = [
    RoomTypeEntity(
      typeId: '1',
      typeName: 'Single Room',
      status: 'active',
    ),
    RoomTypeEntity(
      typeId: '2',
      typeName: 'Double Room',
      status: 'active',
    ),
    RoomTypeEntity(
      typeId: '3',
      typeName: 'Shared Room',
      status: 'active',
    ),
  ];

  group('GetAllTypeUsecase', () {
    test('should return list of room types when successful', () async {
      when(() => mockRepository.getAllTypes())
          .thenAnswer((_) async => Right(tRoomTypes));

      final result = await usecase();

      expect(result, Right(tRoomTypes));
      expect((result as Right).value.length, 3);
      verify(() => mockRepository.getAllTypes()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no room types available', () async {
      when(() => mockRepository.getAllTypes())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase();

      expect(result, const Right(<RoomTypeEntity>[]));
      expect((result as Right).value.length, 0);
      verify(() => mockRepository.getAllTypes()).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch room types', statusCode: 500);
      when(() => mockRepository.getAllTypes())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getAllTypes()).called(1);
    });

    test('should return NetworkFailure when network is unavailable', () async {
      const failure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.getAllTypes())
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
      verify(() => mockRepository.getAllTypes()).called(1);
    });
  });
}
