import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String role;

  const RegisterUsecaseParams({
    required this.fullName, 
    required this.email, 
    required this.password, 
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, email, password, role];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authReposioryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
   : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      fullName: params.fullName, 
      email: params.email, 
      password: params.password, 
      role: params.role
    );
    return _authRepository.register(entity);
  }
}