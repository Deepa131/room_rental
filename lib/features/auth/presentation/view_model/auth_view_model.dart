import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/login_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/register_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/update_profile_picture_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:room_rental/features/auth/presentation/state/auth_state.dart';

// Provider
final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final UpdateProfilePictureUsecase _updateProfilePictureUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _updateProfilePictureUsecase = ref.read(updateProfilePictureUsecaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(
      email: email,
      password: password,
    );

    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _forgotPasswordUsecase(email);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial);
      },
    );
  }

  Future<void> resetPassword(String token, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(token, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.initial);
      },
    );
  }

  Future<Either<Failure, AuthEntity>> updateProfile(String id, AuthEntity user, {File? imageFile}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _updateProfileUsecase(id, user, imageFile: imageFile);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return Left(failure);
      },
      (updatedUser) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: updatedUser,
        );
        return Right(updatedUser);
      },
    );
  }

  Future<Either<Failure, String>> updateProfilePicture(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _updateProfilePictureUsecase(image);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return Left(failure);
      },
      (imageUrl) {
        if (state.authEntity != null) {
          final updatedEntity = AuthEntity(
            userId: state.authEntity!.userId,
            fullName: state.authEntity!.fullName,
            email: state.authEntity!.email,
            password: state.authEntity!.password,
            role: state.authEntity!.role,
            profilePicture: imageUrl,
          );
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authEntity: updatedEntity,
          );
        }
        return Right(imageUrl);
      },
    );
  }
}
