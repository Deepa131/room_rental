import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/hive/hive_service.dart';
import 'package:room_rental/features/room_type/data/datasources/room_type_datasource.dart';
import 'package:room_rental/features/room_type/data/models/room_type_hive_model.dart';

// create provider
final roomTypeLocalDatasourceProvider = Provider<RoomTypeLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return RoomTypeLocalDatasource(hiveService: hiveService);
});

class RoomTypeLocalDatasource implements IRoomTypeLocalDataSource {
  // Dependency Injection
  final HiveService _hiveService;

  RoomTypeLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> createType(RoomTypeHiveModel type) async {
    try {
      await _hiveService.createType(type);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteType(String typeId) async {
    try {
      await _hiveService.deleteType(typeId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<RoomTypeHiveModel>> getAllTypes() async {
    try {
      return _hiveService.getAllTypes();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<RoomTypeHiveModel?> getTypeById(String typeId) async {
    try {
      return _hiveService.getTypeById(typeId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateType(RoomTypeHiveModel type) async {
    try {
      _hiveService.updateType(type);
      return true;
    } catch (e) {
      return false;
    }
  }
}
