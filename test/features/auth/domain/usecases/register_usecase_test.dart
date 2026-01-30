import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        fullName: 'fallback',
        email: 'fallback@mail.com',
        password: 'fallback',
        role: 'renter',
      ),
    );
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tRole = 'renter';

  group('RegisterUsecase', () {
    test('should return true when registration succeeds', () async {
      // Arrange
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct AuthEntity values to repository', () async {
      AuthEntity? captured;

      // Arrange
      when(() => mockRepository.register(any())).thenAnswer((invocation) {
        captured = invocation.positionalArguments[0] as AuthEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert – captured entity must match usecase params
      expect(captured?.fullName, tFullName);
      expect(captured?.email, tEmail);
      expect(captured?.password, tPassword);
      expect(captured?.role, tRole);
    });

    test('should return ApiFailure when registration fails', () async {
      const failure = ApiFailure(message: 'Email already exists');

      // Arrange
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when no internet', () async {
      const failure = NetworkFailure(message: 'No internet');

      // Arrange
      when(() => mockRepository.register(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          role: tRole,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });
  });

  group('RegisterUsecaseParams', () {
    test('should have correct props', () {
      const params = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        role: tRole,
      );

      expect(params.props, [tFullName, tEmail, tPassword, tRole]);
    });

    test('two identical params should be equal', () {
      const p1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        role: tRole,
      );
      const p2 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        role: tRole,
      );

      expect(p1, p2);
    });

    test('different params should not be equal', () {
      const p1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        role: tRole,
      );
      const p2 = RegisterUsecaseParams(
        fullName: 'Other User',
        email: tEmail,
        password: tPassword,
        role: tRole,
      );

      expect(p1, isNot(p2));
    });
  });
}
