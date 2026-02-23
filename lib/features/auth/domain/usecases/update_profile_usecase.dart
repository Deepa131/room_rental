import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  return UpdateProfileUsecase(ref.read(authReposioryProvider));
});

class UpdateProfileUsecase {
  final IAuthRepository repository;

  UpdateProfileUsecase(this.repository);

  Future<Either<Failure, AuthEntity>> call(String id, AuthEntity user, {File? imageFile}) async {
    return await repository.updateProfile(id, user, imageFile: imageFile);
  }
}
