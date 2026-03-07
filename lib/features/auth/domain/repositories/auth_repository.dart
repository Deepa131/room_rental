import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity user);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> resetPassword(String token, String password);
  Future<Either<Failure, AuthEntity>> updateProfile(String id, AuthEntity user, {File? imageFile});
  Future<Either<Failure, String>> updateProfilePicture(File image);
}