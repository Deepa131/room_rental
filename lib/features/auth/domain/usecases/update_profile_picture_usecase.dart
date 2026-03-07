import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/data/repositories/auth_repository.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

final updateProfilePictureUsecaseProvider = Provider<UpdateProfilePictureUsecase>((ref) {
  return UpdateProfilePictureUsecase(ref.read(authReposioryProvider));
});

class UpdateProfilePictureUsecase {
  final IAuthRepository repository;

  UpdateProfilePictureUsecase(this.repository);

  Future<Either<Failure, String>> call(File image) async {
    return await repository.updateProfilePicture(image);
  }
}
