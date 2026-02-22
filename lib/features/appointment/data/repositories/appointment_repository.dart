import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/services/connectivity/network_info.dart';
import 'package:room_rental/features/appointment/data/datasources/local/appointment_local_datasource.dart';
import 'package:room_rental/features/appointment/data/datasources/remote/appointment_remote_datasource.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/domain/repositories/appointment_repository.dart';

final appointmentRepositoryProvider = Provider<IAppointmentRepository>((ref) {
  final localDataSource = ref.read(appointmentLocalDataSourceProvider);
  final remoteDataSource = ref.read(appointmentRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AppointmentRepository(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

class AppointmentRepository implements IAppointmentRepository {
  final AppointmentLocalDataSource _localDataSource;
  final AppointmentRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AppointmentRepository({
    required AppointmentLocalDataSource localDataSource,
    required AppointmentRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AppointmentEntity>> bookAppointment(AppointmentEntity appointment) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.bookAppointment(appointment);
        final entity = model.toEntity();
        
        await _localDataSource.saveAppointment(entity);
        
        return Right(entity);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        await _localDataSource.saveAppointment(appointment);
        return Right(appointment);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getOwnerAppointments(String ownerId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getOwnerAppointments(ownerId);
        final entities = models.map((m) => m.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getOwnerAppointments(ownerId);
        final entities = models.map((m) => m.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getRenterAppointments(String renterId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getRenterAppointments(renterId);
        final entities = models.map((m) => m.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getMyAppointments(renterId);
        final entities = models.map((m) => m.toEntity()).toList();
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String appointmentId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getAppointmentById(appointmentId);
        return Right(model.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _localDataSource.getAppointmentById(appointmentId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return Left(LocalDatabaseFailure(message: 'Appointment not found'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> updateAppointment(
      String appointmentId, DateTime appointmentDate, String appointmentTime, String message) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.updateAppointment(appointmentId, appointmentDate, appointmentTime, message);
        final entity = model.toEntity();
        
        // Update local storage
        await _localDataSource.saveAppointment(entity);
        
        return Right(entity);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> updateAppointmentStatus(
      String appointmentId, String status) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.updateAppointmentStatus(appointmentId, status);
        return Right(model.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelAppointment(String appointmentId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.cancelAppointment(appointmentId);
        if (result) {
          await _localDataSource.deleteAppointment(appointmentId);
        }
        return Right(result);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        await _localDataSource.deleteAppointment(appointmentId);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
