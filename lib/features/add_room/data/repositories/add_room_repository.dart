import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/services/connectivity/network_info.dart';
import 'package:room_rental/features/add_room/data/datasources/add_room_datasource.dart';
import 'package:room_rental/features/add_room/data/datasources/local/add_room_local_datasource.dart';
import 'package:room_rental/features/add_room/data/datasources/remote/add_room_remote_datasource.dart';
import 'package:room_rental/features/add_room/data/models/add_room_api_model.dart';
import 'package:room_rental/features/add_room/data/models/add_room_hive_model.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

final addRoomRepositoryProvider = Provider<IAddRoomRepository>((ref) {
  final localDatasource = ref.read(addRoomLocalDatasourceProvider);
  final remoteDatasource = ref.read(addRoomRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AddRoomRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class AddRoomRepository implements IAddRoomRepository {
  final IAddRoomLocalDataSource _localDataSource;
  final IAddRoomRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AddRoomRepository({
    required IAddRoomLocalDataSource localDatasource,
    required IAddRoomRemoteDataSource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _localDataSource = localDatasource,
        _remoteDataSource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createRoom(AddRoomEntity room) async {
    if (await _networkInfo.isConnected) {
      try {
        final roomApiModel = AddRoomApiModel.fromEntity(room);
        await _remoteDataSource.createRoom(roomApiModel);
        
        // Also save to local Hive database for offline access
        final roomHiveModel = AddRoomHiveModel.fromEntity(room);
        await _localDataSource.createRoom(roomHiveModel);
        
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // If no internet, save to local database only
      try {
        final roomHiveModel = AddRoomHiveModel.fromEntity(room);
        await _localDataSource.createRoom(roomHiveModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRoom(String roomId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteRoom(roomId);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _localDataSource.deleteRoom(roomId);
        if (result) {
          return const Right(true);
        }
        return const Left(
          LocalDatabaseFailure(message: "Failed to delete room"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AddRoomEntity>>> getAllRooms() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllRooms();
        final entities = AddRoomApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getAllRooms();
        final entities = AddRoomHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AddRoomEntity>> getRoomById(String roomId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getRoomById(roomId);
        return Right(model.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _localDataSource.getRoomById(roomId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(LocalDatabaseFailure(message: 'Room not found'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AddRoomEntity>>> getRoomsByOwner(
      String ownerId) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getRoomsByOwner(ownerId);
        final entities = AddRoomApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getRoomsByOwner(ownerId);
        final entities = AddRoomHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AddRoomEntity>>> getAvailableRooms() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllRooms();
        final availableRooms =
            models.where((room) => room.isAvailable == true).toList();
        return Right(AddRoomApiModel.toEntityList(availableRooms));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getAllRooms();
        final availableRooms =
            models.where((room) => room.isAvailable == true).toList();
        return Right(AddRoomHiveModel.toEntityList(availableRooms));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AddRoomEntity>>> getBookedRooms() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllRooms();
        final bookedRooms =
            models.where((room) => room.isAvailable == false).toList();
        return Right(AddRoomApiModel.toEntityList(bookedRooms));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getAllRooms();
        final bookedRooms =
            models.where((room) => room.isAvailable == false).toList();
        return Right(AddRoomHiveModel.toEntityList(bookedRooms));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> updateRoom(AddRoomEntity room) async {
    if (await _networkInfo.isConnected) {
      try {
        final roomApiModel = AddRoomApiModel.fromEntity(room);
        await _remoteDataSource.updateRoom(roomApiModel);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final roomModel = AddRoomHiveModel.fromEntity(room);
        final result = await _localDataSource.updateRoom(roomModel);
        if (result) {
          return const Right(true);
        }
        return const Left(
          LocalDatabaseFailure(message: "Failed to update room"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadRoomImage(File image) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadRoomImage(image);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadRoomVideo(File video) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadRoomVideo(video);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
