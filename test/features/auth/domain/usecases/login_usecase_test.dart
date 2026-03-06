import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tUser = AuthEntity(
    userId: '1',
    fullName: 'Test User',
    email: tEmail,
    password: tPassword,
    role: 'renter',
    profilePicture: 'https://example.com/profile.jpg',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when login fails', () async {
      const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when no internet connection', () async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.login(tEmail, tPassword))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });
  });
}
