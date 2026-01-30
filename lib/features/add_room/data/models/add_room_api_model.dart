import 'package:json_annotation/json_annotation.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

part 'add_room_api_model.g.dart';

@JsonSerializable()
class AddRoomApiModel {
  final String? id;
  final String? ownerId;
  final String ownerContactNumber;

  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final String roomType; 

  final String? description;
  final List<String>? images;
  final List<String>? videos;

  final bool isAvailable;
  final String? status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddRoomApiModel({
    this.id,
    this.ownerId,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    required this.roomType,
    this.description,
    this.images,
    this.videos,
    this.isAvailable = true,
    this.status,
    this.createdAt,
    this.updatedAt, 
  });

  Map<String, dynamic> toJson() {
    final json = {
      'roomTitle': roomTitle,
      'monthlyPrice': monthlyPrice,
      'location': location,
      'roomType': roomType,
      'ownerContactNumber': ownerContactNumber,
      'isAvailable': isAvailable,
      if (ownerId != null) 'ownerId': ownerId,
      if (description != null) 'description': description,
      if (images != null) 'images': images,
      if (videos != null) 'videos': videos,
    };
    print('DEBUG AddRoomApiModel.toJson() - roomType value: $roomType');
    return json;
  }

  factory AddRoomApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return value['_id'] as String?;
      return value as String?;
    }
    return AddRoomApiModel(
      id: json['_id'] as String?,
      ownerId: extractId(json['ownerId']),
      ownerContactNumber: json['ownerContactNumber'] as String,
      roomTitle: json['roomTitle'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      location: json['location'] as String,
      roomType: json['roomType'] is Map
          ? json['roomType']['_id'] as String
          : json['roomType'] as String,
      description: json['description'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      videos: json['videos'] != null
          ? List<String>.from(json['videos'])
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  AddRoomEntity toEntity() {
    return AddRoomEntity(
      roomId: id,
      ownerId: ownerId,
      ownerContactNumber: ownerContactNumber,
      roomTitle: roomTitle,
      monthlyPrice: monthlyPrice,
      location: location,
      roomType: RoomTypeEntity(typeId: roomType, typeName: ''),
      description: description,
      images: images,
      videos: videos,
      isAvailable: isAvailable,
      approvalStatus: status,
      createdAt: createdAt,
    );
  }

  factory AddRoomApiModel.fromEntity(AddRoomEntity entity) {
    print('DEBUG AddRoomApiModel.fromEntity() - entity.roomType.typeId: ${entity.roomType.typeId}');
    print('DEBUG AddRoomApiModel.fromEntity() - entity.roomType.typeName: ${entity.roomType.typeName}');
    return AddRoomApiModel(
      id: entity.roomId,
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
    List<AddRoomApiModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}
