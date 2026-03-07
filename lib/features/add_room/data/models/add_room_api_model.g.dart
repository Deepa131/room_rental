// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_room_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationCoordsApiModel _$LocationCoordsApiModelFromJson(
        Map<String, dynamic> json) =>
    LocationCoordsApiModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
    );

Map<String, dynamic> _$LocationCoordsApiModelToJson(
        LocationCoordsApiModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
    };

AddRoomApiModel _$AddRoomApiModelFromJson(Map<String, dynamic> json) =>
    AddRoomApiModel(
      id: json['id'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerContactNumber: json['ownerContactNumber'] as String,
      roomTitle: json['roomTitle'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      location: json['location'] as String,
      locationCoords: json['locationCoords'] == null
          ? null
          : LocationCoordsApiModel.fromJson(
              json['locationCoords'] as Map<String, dynamic>),
      roomType: json['roomType'] as String,
      roomTypeName: json['roomTypeName'] as String?,
      description: json['description'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      videos:
          (json['videos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      status: json['status'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AddRoomApiModelToJson(AddRoomApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'ownerContactNumber': instance.ownerContactNumber,
      'roomTitle': instance.roomTitle,
      'monthlyPrice': instance.monthlyPrice,
      'location': instance.location,
      'locationCoords': instance.locationCoords,
      'roomType': instance.roomType,
      'roomTypeName': instance.roomTypeName,
      'description': instance.description,
      'images': instance.images,
      'videos': instance.videos,
      'isAvailable': instance.isAvailable,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
