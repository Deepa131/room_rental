import 'package:hive/hive.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:uuid/uuid.dart';

part 'add_room_hive_model.g.dart';

@HiveType(typeId: AuthHiveConstants.addRoomTypeId)
class AddRoomHiveModel extends HiveObject {
  @HiveField(0)
  final String? roomId;

  @HiveField(1)
  final String? ownerId;

  @HiveField(2)
  final String ownerContactNumber;

  @HiveField(3)
  final String roomTitle;

  @HiveField(4)
  final double monthlyPrice;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String roomType;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final List<String>? images;

  @HiveField(9)
  List<String>? videos;

  @HiveField(10)
  final bool isAvailable;

  @HiveField(11)
  final String status;

  @HiveField(12)
  final DateTime createdAt;

  AddRoomHiveModel({
    String? roomId,
    this.ownerId,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    required this.roomType,
    this.description,
    this.images,
    this.videos,
    bool? isAvailable,
    String? status,
    DateTime? createdAt,
  })  : roomId = roomId ?? const Uuid().v4(),
        isAvailable = isAvailable ?? true,
        status = status ?? 'pending',
        createdAt = createdAt ?? DateTime.now();

  AddRoomEntity toEntity() {
    return AddRoomEntity(
      roomId: roomId,
      ownerId: ownerId,
      ownerContactNumber: ownerContactNumber,
      roomTitle: roomTitle,
      monthlyPrice: monthlyPrice,
      location: location,
      roomType: RoomTypeEntity(typeName: roomType),
      description: description,
      images: images,
      videos: videos,
      isAvailable: isAvailable,
      approvalStatus: status,
      createdAt: createdAt,
    );
  }

  factory AddRoomHiveModel.fromEntity(AddRoomEntity entity) {
    return AddRoomHiveModel(
      roomId: entity.roomId,
      ownerId: entity.ownerId,
      ownerContactNumber: entity.ownerContactNumber,
      roomTitle: entity.roomTitle,
      monthlyPrice: entity.monthlyPrice,
      location: entity.location,
      roomType: entity.roomType.typeName,
      description: entity.description,
      images: entity.images,
      videos: entity.videos,
      isAvailable: entity.isAvailable,
      status: entity.approvalStatus,
      createdAt: entity.createdAt,
    );
  }

  static List<AddRoomEntity> toEntityList(
    List<AddRoomHiveModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}
