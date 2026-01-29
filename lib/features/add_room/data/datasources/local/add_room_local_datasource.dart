import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/hive/hive_service.dart';
import 'package:room_rental/features/add_room/data/datasources/add_room_datasource.dart';
import 'package:room_rental/features/add_room/data/models/add_room_hive_model.dart';

final addRoomLocalDatasourceProvider =
    Provider<AddRoomLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return AddRoomLocalDatasource(hiveService: hiveService);
});

class AddRoomLocalDatasource implements IAddRoomLocalDataSource {
  final HiveService _hiveService;

  AddRoomLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> createRoom(AddRoomHiveModel room) async {
    try {
      await _hiveService.createRoom(room);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteRoom(String roomId) async {
    try {
      await _hiveService.deleteRoom(roomId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<AddRoomHiveModel>> getAllRooms() async {
    try {
      return _hiveService.getAllRooms();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<AddRoomHiveModel?> getRoomById(String roomId) async {
    try {
      return _hiveService.getRoomById(roomId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AddRoomHiveModel>> getRoomsByOwner(String ownerId) async {
    try {
      return _hiveService.getRoomsByOwner(ownerId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateRoom(AddRoomHiveModel room) async {
    try {
      await _hiveService.updateRoom(room);
      return true;
    } catch (e) {
      return false;
    }
  }
}
