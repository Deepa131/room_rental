import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

//provider
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final authRepository = ref.read(authReposioryProvider);
  return GetCurrentUserUsecase(authRepository: authRepository);
});

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity>{
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() {
    return _authRepository.getCurrentUser();
  }
}