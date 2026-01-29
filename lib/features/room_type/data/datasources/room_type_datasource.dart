import 'package:room_rental/features/room_type/data/models/room_type_api_model.dart';
import 'package:room_rental/features/room_type/data/models/room_type_hive_model.dart';

abstract interface class IRoomTypeLocalDataSource {
  Future<List<RoomTypeHiveModel>> getAllTypes();
  Future<RoomTypeHiveModel?> getTypeById(String typeId);
  Future<bool> createType(RoomTypeHiveModel type);
  Future<bool> updateType(RoomTypeHiveModel type);
  Future<bool> deleteType(String typeId);
}

abstract interface class IRoomTypeRemoteDataSource {
  Future<List<RoomTypeApiModel>> getAllTypes();
  Future<RoomTypeApiModel?> getTypeById(String typeId);
  Future<bool> createType(RoomTypeHiveModel type);
  Future<bool> updateType(RoomTypeApiModel type);
}
