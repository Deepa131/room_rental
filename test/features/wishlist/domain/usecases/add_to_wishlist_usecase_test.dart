import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';

class MockWishlistRepository extends Mock implements IWishlistRepository {}

void main() {
  late AddToWishlistUsecase usecase;
  late MockWishlistRepository mockRepository;

  setUp(() {
    mockRepository = MockWishlistRepository();
    usecase = AddToWishlistUsecase(mockRepository);
  });

  const tUserId = 'user123';
  const tRoomId = 'room123';

  group('AddToWishlistUsecase', () {
    test('should add room to wishlist successfully and return true', () async {
      when(() => mockRepository.addToWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Right(true));
      verify(() => mockRepository.addToWishlist(tUserId, tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when room already in wishlist', () async {
      when(() => mockRepository.addToWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Right(false));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Right(false));
      verify(() => mockRepository.addToWishlist(tUserId, tRoomId)).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to add to wishlist', statusCode: 400);
      when(() => mockRepository.addToWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Left(failure));
      verify(() => mockRepository.addToWishlist(tUserId, tRoomId)).called(1);
    });

    test('should return ApiFailure when user not authenticated', () async {
      const failure = ApiFailure(message: 'User not authenticated', statusCode: 401);
      when(() => mockRepository.addToWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Left(failure));
      verify(() => mockRepository.addToWishlist(tUserId, tRoomId)).called(1);
    });
  });
}
