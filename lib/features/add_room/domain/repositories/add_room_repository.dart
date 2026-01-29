import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';

abstract interface class IAddRoomRepository {
  Future<Either<Failure, List<AddRoomEntity>>> getAllRooms();
  Future<Either<Failure, List<AddRoomEntity>>> getRoomsByOwner(String ownerId);
  Future<Either<Failure, List<AddRoomEntity>>> getAvailableRooms();
  Future<Either<Failure, List<AddRoomEntity>>> getBookedRooms();
  Future<Either<Failure, AddRoomEntity>> getRoomById(String roomId);
  Future<Either<Failure, bool>> createRoom(AddRoomEntity room);
  Future<Either<Failure, bool>> updateRoom(AddRoomEntity room);
  Future<Either<Failure, bool>> deleteRoom(String roomId);
  Future<Either<Failure, String>> uploadRoomImage(File image);
  Future<Either<Failure, String>> uploadRoomVideo(File video);
}
