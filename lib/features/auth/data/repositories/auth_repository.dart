import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/data/datasources/auth_datasource.dart';
import 'package:room_rental/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

final authReposioryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: datasource);
});
class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepository({required IAuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async{
    try {
      final user = await _authDatasource.getCurrentUser();

      if (user != null) {
        return Right(user.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: 'No user logged in'),
      );
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async{
    try {
      final user = await _authDatasource.login(email, password);
      if (user != null) {
        return Right(user.toEntity());
      }
      return const Left(
        LocalDatabaseFailure(message: 'Invalid email or password'),
      );
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to logout'),
      );
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async{
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.register(model);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to register user'),
      );
    } catch (e) {
      return Left(
        LocalDatabaseFailure(message: e.toString()),
      );
    }
  }
}