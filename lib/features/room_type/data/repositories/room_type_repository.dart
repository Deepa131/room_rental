import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/services/connectivity/network_info.dart';
import 'package:room_rental/features/room_type/data/datasources/local/room_type_local_datasource.dart';
import 'package:room_rental/features/room_type/data/datasources/remote/room_type_remote_datasource.dart';
import 'package:room_rental/features/room_type/data/datasources/room_type_datasource.dart';
import 'package:room_rental/features/room_type/data/models/room_type_api_model.dart';
import 'package:room_rental/features/room_type/data/models/room_type_hive_model.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

// Create provider
final roomTypeRepositoryProvider = Provider<IRoomTypeRepository>((ref) {
  final roomTypeLocalDatasource = ref.read(roomTypeLocalDatasourceProvider);
  final roomTypeRemoteDataSource = ref.read(roomTypeRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return RoomTypeRepository(
    roomTypeDatasource: roomTypeLocalDatasource,
    roomTypeRemoteDataSource: roomTypeRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class RoomTypeRepository implements IRoomTypeRepository {
  final IRoomTypeLocalDataSource _roomTypeLocalDataSource;
  final IRoomTypeRemoteDataSource _roomTypeRemoteDataSource;
  final NetworkInfo _networkInfo;

  RoomTypeRepository({
    required IRoomTypeLocalDataSource roomTypeDatasource,
    required IRoomTypeRemoteDataSource roomTypeRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _roomTypeLocalDataSource = roomTypeDatasource,
       _roomTypeRemoteDataSource = roomTypeRemoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createType(RoomTypeEntity type) async {
    try {
      // conversion
      // entity lai model ma convert gara
      final typeModel = RoomTypeHiveModel.fromEntity(type);
      final result = await _roomTypeLocalDataSource.createType(typeModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to create a room type"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteType(String typeId) async {
    try {
      final result = await _roomTypeLocalDataSource.deleteType(typeId);
      if (result) {
        return Right(true);
      }

      return Left(LocalDatabaseFailure(message: ' Failed to delete room type'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoomTypeEntity>>> getAllTypes() async {
    // If internet available, always try to fetch fresh data from API first
    if (await _networkInfo.isConnected) {
      try {
        print('DEBUG RoomTypeRepository.getAllTypes() - Fetching fresh data from API');
        final apiModels = await _roomTypeRemoteDataSource.getAllTypes();
        print('DEBUG RoomTypeRepository.getAllTypes() - API returned ${apiModels.length} models');
        
        // Sync API data with local Hive cache 
        try {
          for (var apiModel in apiModels) {
            print('DEBUG RoomTypeRepository.getAllTypes() - Syncing API model: id=${apiModel.id}, typeName=${apiModel.typeName}');
            final entity = apiModel.toEntity();
            print('DEBUG RoomTypeRepository.getAllTypes() - After toEntity: typeId=${entity.typeId}, typeName=${entity.typeName}');
            final hiveModel = RoomTypeHiveModel.fromEntity(entity);
            print('DEBUG RoomTypeRepository.getAllTypes() - Saved to Hive: typeId=${hiveModel.typeId}, typeName=${hiveModel.typeName}');
            await _roomTypeLocalDataSource.updateType(hiveModel);
          }
          print('DEBUG RoomTypeRepository.getAllTypes() - Successfully synced all API data to Hive');
        } catch (e) {
          print('DEBUG RoomTypeRepository.getAllTypes() - Warning: Failed to sync to Hive: $e');
        }
        
        final result = RoomTypeApiModel.toEntityList(apiModels);
        print('DEBUG RoomTypeRepository.getAllTypes() - Converted to ${result.length} entities');
        result.forEach((e) => print('  - typeId: ${e.typeId}, typeName: ${e.typeName}'));
        return Right(result);
      } on DioException catch (e) {
        String errorMessage = 'Failed to fetch room types';
        
        if (e.response?.statusCode == 404) {
          errorMessage = 'Room types endpoint not found. Using local data if available.';
        } else if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
        
        print('DEBUG RoomTypeRepository.getAllTypes() - API error: $errorMessage');
        
        // Fallback to local data on API failure
        try {
          final models = await _roomTypeLocalDataSource.getAllTypes();
          final entities = RoomTypeHiveModel.toEntityList(models);
          print('DEBUG RoomTypeRepository.getAllTypes() - Falling back to ${entities.length} local entities');
          if (entities.isNotEmpty) {
            return Right(entities);
          }
        } catch (_) {}
        
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: errorMessage,
          ),
        );
      } catch (e) {
        print('DEBUG RoomTypeRepository.getAllTypes() - Unexpected error: $e');
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    } else {
      // No internet - use local data
      print('DEBUG RoomTypeRepository.getAllTypes() - No internet, using local Hive data');
      try {
        final models = await _roomTypeLocalDataSource.getAllTypes();
        final entities = RoomTypeHiveModel.toEntityList(models);
        print('DEBUG RoomTypeRepository.getAllTypes() - Found ${entities.length} entities in local Hive');
        entities.forEach((e) => print('  - typeId: ${e.typeId}, typeName: ${e.typeName}'));
        if (entities.isNotEmpty) {
          return Right(entities);
        }
      } catch (_) {}
      
      return Left(LocalDatabaseFailure(message: 'No room types available and no internet connection'));
    }
  }

  @override
  Future<Either<Failure, RoomTypeEntity>> getTypeById(String typeId) async {
    try {
      final model = await _roomTypeLocalDataSource.getTypeById(typeId);
      if (model != null) {
        final entity = model.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Room type not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateType(RoomTypeEntity type) async {
    try {
      final typeModel = RoomTypeHiveModel.fromEntity(type);
      final result = await _roomTypeLocalDataSource.updateType(typeModel);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update room type"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
