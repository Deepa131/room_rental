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

    test('should pass correct email and password to repository', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should succeed with correct credentials and fail with wrong credentials', () async {
      const wrongEmail = 'wrong@example.com';
      const wrongPassword = 'wrongpass';
      const failure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(any(), any())).thenAnswer(
        (invocation) async {
          final email = invocation.positionalArguments[0] as String;
          final password = invocation.positionalArguments[1] as String;

          if (email == tEmail && password == tPassword) {
            return const Right(tUser);
          }
          return const Left(failure);
        },
      );

      final successResult = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );
      expect(successResult, const Right(tUser));

      final wrongEmailResult = await usecase(
        const LoginUsecaseParams(email: wrongEmail, password: tPassword),
      );
      expect(wrongEmailResult, const Left(failure));

      final wrongPasswordResult = await usecase(
        const LoginUsecaseParams(email: tEmail, password: wrongPassword),
      );
      expect(wrongPasswordResult, const Left(failure));
    });
  });

  group('LoginUsecaseParams', () {
    test('should have correct props', () {
      const params = LoginUsecaseParams(email: tEmail, password: tPassword);
      expect(params.props, [tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      const p1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const p2 = LoginUsecaseParams(email: tEmail, password: tPassword);
      expect(p1, p2);
    });

    test('params with different values should not be equal', () {
      const p1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const p2 = LoginUsecaseParams(email: 'different@mail.com', password: tPassword);
      expect(p1, isNot(p2));
    });
  });
}
