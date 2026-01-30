import 'dart:io';
import 'package:room_rental/features/add_room/data/models/add_room_api_model.dart';
import 'package:room_rental/features/add_room/data/models/add_room_hive_model.dart';

abstract interface class IAddRoomLocalDataSource {
  Future<List<AddRoomHiveModel>> getAllRooms();
  Future<List<AddRoomHiveModel>> getRoomsByOwner(String ownerId);
  Future<AddRoomHiveModel?> getRoomById(String roomId);
  Future<bool> createRoom(AddRoomHiveModel room);
  Future<bool> updateRoom(AddRoomHiveModel room);
  Future<bool> deleteRoom(String roomId);
}

abstract interface class IAddRoomRemoteDataSource {
  Future<String> uploadRoomImage(File image);
  Future<String> uploadRoomVideo(File video);
  Future<AddRoomApiModel> createRoom(AddRoomApiModel room);
  Future<List<AddRoomApiModel>> getAllRooms();
  Future<AddRoomApiModel> getRoomById(String roomId);
  Future<List<AddRoomApiModel>> getRoomsByOwner(String ownerId);
  Future<bool> updateRoom(AddRoomApiModel room);
  Future<bool> deleteRoom(String roomId);
}
