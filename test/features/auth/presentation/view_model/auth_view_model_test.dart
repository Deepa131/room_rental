import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/usecases/register_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/login_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/update_profile_picture_usecase.dart';
import 'package:room_rental/features/auth/presentation/state/auth_state.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}
class MockUpdateProfilePictureUsecase extends Mock implements UpdateProfilePictureUsecase {}

void main() {
  late ProviderContainer container;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockUpdateProfilePictureUsecase mockUpdateProfilePictureUsecase;

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockUpdateProfilePictureUsecase = MockUpdateProfilePictureUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        updateProfileUsecaseProvider.overrideWithValue(mockUpdateProfileUsecase),
        updateProfilePictureUsecaseProvider.overrideWithValue(mockUpdateProfilePictureUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  setUpAll(() {
    registerFallbackValue(const RegisterUsecaseParams(
      fullName: 'Test',
      email: 'test@test.com',
      password: 'password',
      role: 'renter',
    ));
    registerFallbackValue(const LoginUsecaseParams(
      email: 'test@test.com',
      password: 'password',
    ));
  });

  const tUser = AuthEntity(
    userId: '123',
    fullName: 'Test User',
    email: 'test@example.com',
    password: 'password',
    role: 'renter',
  );

  group('AuthViewModel', () {
    test('should register successfully', () async {
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.register(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        role: 'renter',
      );

      expect(viewModel.state.status, AuthStatus.registered);
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('should handle registration failure', () async {
      const failure = ApiFailure(message: 'Registration failed', statusCode: 400);
      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.register(
        fullName: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        role: 'renter',
      );

      expect(viewModel.state.status, AuthStatus.error);
    });

    test('should login successfully', () async {
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => const Right(tUser));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(viewModel.state.status, AuthStatus.authenticated);
    });

    test('should handle login failure', () async {
      const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.login(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(viewModel.state.status, AuthStatus.error);
    });
  });
}
