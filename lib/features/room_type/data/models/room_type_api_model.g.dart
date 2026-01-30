// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_type_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomTypeApiModel _$RoomTypeApiModelFromJson(Map<String, dynamic> json) =>
    RoomTypeApiModel(
      id: json['_id'] as String?,
      typeName: json['typeName'] as String,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$RoomTypeApiModelToJson(RoomTypeApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'typeName': instance.typeName,
      'status': instance.status,
    };
