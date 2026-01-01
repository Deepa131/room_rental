import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

//provider
final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final authRepository = ref.read(authReposioryProvider);
  return LogoutUsecase(authRepository: authRepository);
});

class LogoutUsecase implements UsecaseWithoutParams<bool>{
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call() {
    return _authRepository.logout();
  }
}