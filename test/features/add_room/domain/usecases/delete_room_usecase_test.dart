import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/usecases/delete_room_usecase.dart';

class MockAddRoomRepository extends Mock implements IAddRoomRepository {}

void main() {
  late DeleteRoomUsecase usecase;
  late MockAddRoomRepository mockRepository;

  setUp(() {
    mockRepository = MockAddRoomRepository();
    usecase = DeleteRoomUsecase(addRoomRepository: mockRepository);
  });

  const tRoomId = 'room123';
  const tParams = DeleteRoomParams(roomId: tRoomId);

  group('DeleteRoomUsecase', () {
    test('should delete room successfully and return true', () async {
      when(() => mockRepository.deleteRoom(tRoomId))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase(tParams);

      expect(result, const Right(true));
      verify(() => mockRepository.deleteRoom(tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when room deletion fails', () async {
      when(() => mockRepository.deleteRoom(tRoomId))
          .thenAnswer((_) async => const Right(false));

      final result = await usecase(tParams);

      expect(result, const Right(false));
      verify(() => mockRepository.deleteRoom(tRoomId)).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to delete room', statusCode: 500);
      when(() => mockRepository.deleteRoom(tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left(failure));
      verify(() => mockRepository.deleteRoom(tRoomId)).called(1);
    });

    test('should return ApiFailure when room not found', () async {
      const failure = ApiFailure(message: 'Room not found', statusCode: 404);
      when(() => mockRepository.deleteRoom(tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tParams);

      expect(result, const Left(failure));
      verify(() => mockRepository.deleteRoom(tRoomId)).called(1);
    });
  });
}
