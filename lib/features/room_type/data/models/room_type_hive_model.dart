import 'package:hive/hive.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:uuid/uuid.dart';

part 'room_type_hive_model.g.dart';

// dart run build_runner build -d

@HiveType(typeId: AuthHiveConstants.roomTypeId)
class RoomTypeHiveModel extends HiveObject {
  @HiveField(0)
  final String? typeId;
  @HiveField(1)
  final String typeName;
  @HiveField(2)
  final String? status;

  RoomTypeHiveModel({String? typeId, required this.typeName, String? status})
    : typeId = typeId ?? Uuid().v4(),
      status = status ?? 'active';

  // TOENtity
  RoomTypeEntity toEntity() {
    return RoomTypeEntity(typeId: typeId, typeName: typeName, status: status);
  }

  // From Entity -> conversion
  factory RoomTypeHiveModel.fromEntity(RoomTypeEntity entity) {
    return RoomTypeHiveModel(typeId: entity.typeId, typeName: entity.typeName, status: entity.status);
  }

  // EntityList
  static List<RoomTypeEntity> toEntityList(List<RoomTypeHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
