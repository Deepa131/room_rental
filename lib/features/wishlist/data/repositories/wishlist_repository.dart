import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:room_rental/features/wishlist/domain/repositories/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<IWishlistRepository>((ref) {
  final localDatasource = ref.read(wishlistLocalDatasourceProvider);
  final roomRepository = ref.read(addRoomRepositoryProvider);
  return WishlistRepository(
    localDatasource: localDatasource,
    roomRepository: roomRepository,
  );
});

class WishlistRepository implements IWishlistRepository {
  final WishlistLocalDatasource _localDatasource;
  final IAddRoomRepository _roomRepository;

  WishlistRepository({
    required WishlistLocalDatasource localDatasource,
    required IAddRoomRepository roomRepository,
  })  : _localDatasource = localDatasource,
        _roomRepository = roomRepository;

  @override
  Future<Either<Failure, bool>> addToWishlist(String userId, String roomId) async {
    try {
      final result = await _localDatasource.addToWishlist(userId, roomId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to add to wishlist'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromWishlist(String userId, String roomId) async {
    try {
      final result = await _localDatasource.removeFromWishlist(userId, roomId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to remove from wishlist'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String userId, String roomId) async {
    try {
      final result = await _localDatasource.isInWishlist(userId, roomId);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWishlistRoomIds(String userId) async {
    try {
      final roomIds = await _localDatasource.getWishlistRoomIds(userId);
      return Right(roomIds);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AddRoomEntity>>> getWishlistRooms(String userId) async {
    try {
      // Get wishlist room IDs
      final roomIds = await _localDatasource.getWishlistRoomIds(userId);
      
      if (roomIds.isEmpty) {
        return const Right([]);
      }

      // Get all rooms
      final allRoomsResult = await _roomRepository.getAllRooms();
      
      return allRoomsResult.fold(
        (failure) => Left(failure),
        (allRooms) {
          final wishlistRooms = allRooms
              .where((room) => roomIds.contains(room.roomId))
              .toList();
          return Right(wishlistRooms);
        },
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clearWishlist(String userId) async {
    try {
      final result = await _localDatasource.clearWishlist(userId);
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to clear wishlist'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
