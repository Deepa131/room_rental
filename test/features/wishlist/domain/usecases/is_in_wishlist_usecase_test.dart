import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:room_rental/features/wishlist/domain/usecases/is_in_wishlist_usecase.dart';

class MockWishlistRepository extends Mock implements IWishlistRepository {}

void main() {
  late IsInWishlistUsecase usecase;
  late MockWishlistRepository mockRepository;

  setUp(() {
    mockRepository = MockWishlistRepository();
    usecase = IsInWishlistUsecase(mockRepository);
  });

  const tUserId = 'user123';
  const tRoomId = 'room123';

  group('IsInWishlistUsecase', () {
    test('should return true when room is in wishlist', () async {
      when(() => mockRepository.isInWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Right(true));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Right(true));
      verify(() => mockRepository.isInWishlist(tUserId, tRoomId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when room is not in wishlist', () async {
      when(() => mockRepository.isInWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Right(false));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Right(false));
      verify(() => mockRepository.isInWishlist(tUserId, tRoomId)).called(1);
    });

    test('should return ApiFailure when API call fails', () async {
      const failure = ApiFailure(message: 'Failed to check wishlist', statusCode: 500);
      when(() => mockRepository.isInWishlist(tUserId, tRoomId))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tUserId, tRoomId);

      expect(result, const Left(failure));
      verify(() => mockRepository.isInWishlist(tUserId, tRoomId)).called(1);
    });
  });
}
