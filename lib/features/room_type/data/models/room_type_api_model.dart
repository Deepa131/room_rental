import 'package:json_annotation/json_annotation.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

part 'room_type_api_model.g.dart';

@JsonSerializable()
class RoomTypeApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String typeName;
  final String? status;

  RoomTypeApiModel({this.id, required this.typeName, this.status});

  // toJSON
  Map<String, dynamic> toJson() => _$RoomTypeApiModelToJson(this);

  // fromJSON
  factory RoomTypeApiModel.fromJson(Map<String, dynamic> json) =>
    _$RoomTypeApiModelFromJson(json);

  // toEntity
  RoomTypeEntity toEntity() {
    return RoomTypeEntity(
      typeId: id,
      typeName: 'UK - $typeName',
      status: status,
    );
  }

  // fromEntity
  factory RoomTypeApiModel.fromEntity(RoomTypeEntity entity) {
    return RoomTypeApiModel(typeName: entity.typeName);
  }

  // toEntityList
  static List<RoomTypeEntity> toEntityList(List<RoomTypeApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
