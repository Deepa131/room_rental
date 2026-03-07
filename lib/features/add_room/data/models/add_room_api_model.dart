import 'package:json_annotation/json_annotation.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

part 'add_room_api_model.g.dart';

@JsonSerializable()
class LocationCoordsApiModel {
  final double latitude;
  final double longitude;
  final String? address;

  LocationCoordsApiModel({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  factory LocationCoordsApiModel.fromJson(Map<String, dynamic> json) =>
      _$LocationCoordsApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationCoordsApiModelToJson(this);

  LocationCoordsEntity toEntity() {
    return LocationCoordsEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  factory LocationCoordsApiModel.fromEntity(LocationCoordsEntity entity) {
    return LocationCoordsApiModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
    );
  }
}

@JsonSerializable()
class AddRoomApiModel {
  final String? id;
  final String? ownerId;
  final String? ownerName;
  final String ownerContactNumber;

  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final LocationCoordsApiModel? locationCoords;
  final String roomType; 
  final String? roomTypeName;

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
    this.ownerName,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    this.locationCoords,
    required this.roomType,
    this.roomTypeName,
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
      if (locationCoords != null) 'locationCoords': locationCoords!.toJson(),
      if (description != null) 'description': description,
      if (images != null) 'images': images,
      if (videos != null) 'videos': videos,
    };
    return json;
  }

  factory AddRoomApiModel.fromJson(Map<String, dynamic> json) {
    String? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) return (value['_id'] ?? value['id']) as String?;
      return value as String?;
    }
    
    String? extractRoomTypeId(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return (value['id'] ?? value['_id']) as String?;
      }
      return value as String?;
    }

    String? extractRoomTypeName(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return value['typeName'] as String?;
      }
      return null;
    }
    
    String? extractOwnerName(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return value['fullName'] as String?;
      }
      return null;
    }
    
    return AddRoomApiModel(
      id: (json['id'] ?? json['_id']) as String?,
      ownerId: extractId(json['ownerId']),
      ownerName: extractOwnerName(json['ownerId']),
      ownerContactNumber: json['ownerContactNumber'] as String,
      roomTitle: json['roomTitle'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      location: json['location'] as String,
      locationCoords: json['locationCoords'] != null
          ? LocationCoordsApiModel.fromJson(json['locationCoords'] as Map<String, dynamic>)
          : null,
        roomType: json['roomType'] is Map
          ? extractRoomTypeId(json['roomType'])!
          : json['roomType'] as String,
        roomTypeName: extractRoomTypeName(json['roomType']),
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
      ownerName: ownerName,
      ownerContactNumber: ownerContactNumber,
      roomTitle: roomTitle,
      monthlyPrice: monthlyPrice,
      location: location,
      locationCoords: locationCoords?.toEntity(),
      roomType: RoomTypeEntity(typeId: roomType, typeName: roomTypeName ?? ''),
      description: description,
      images: images,
      videos: videos,
      isAvailable: isAvailable,
      approvalStatus: status,
      createdAt: createdAt,
    );
  }

  factory AddRoomApiModel.fromEntity(AddRoomEntity entity) {
    
    bool isValidMongoId(String? id) {
      if (id == null) return false;
      return id.length == 24 && RegExp(r'^[a-f0-9]{24}$').hasMatch(id);
    }
    
    final finalRoomType = isValidMongoId(entity.roomType.typeId) 
        ? entity.roomType.typeId!
        : entity.roomType.typeName;
    
    return AddRoomApiModel(
      id: entity.roomId,
      ownerId: entity.ownerId,
      ownerContactNumber: entity.ownerContactNumber,
      roomTitle: entity.roomTitle,
      monthlyPrice: entity.monthlyPrice,
      location: entity.location,
      locationCoords: entity.locationCoords != null
          ? LocationCoordsApiModel.fromEntity(entity.locationCoords!)
          : null,
      roomType: finalRoomType,
      roomTypeName: entity.roomType.typeName,
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
