import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/services/connectivity/network_info.dart';
import 'package:room_rental/features/auth/data/datasources/auth_datasource.dart';
import 'package:room_rental/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:room_rental/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:room_rental/features/auth/data/models/auth_api_model.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/repositories/auth_repository.dart';

final authReposioryProvider = Provider<IAuthRepository>((ref) {
  final datasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: datasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});
class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo, 
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async{
    try {
      final user = await _authDatasource.getCurrentUser();

      if (user != null) {
        return Right(user.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async{
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDatasource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Invalid credentials'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login Failed',
            statusCode: e.response?.statusCode
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDatasource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(LocalDatabaseFailure(message: 'Invalid email or password'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async{
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to logout'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async{
    if (await _networkInfo.isConnected) {
      // go to remote
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDatasource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration Failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final exisitingUser = await _authDatasource.getUserByEmail(user.email);
        if (exisitingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }

        final authModel = AuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          password: user.password,
          role: user.role,
          profilePicture: user.profilePicture,
        );
        await _authDatasource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}