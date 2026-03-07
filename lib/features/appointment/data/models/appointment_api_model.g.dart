// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDataModel _$RoomDataModelFromJson(Map<String, dynamic> json) =>
    RoomDataModel(
      id: json['id'] as String?,
      roomTitle: json['roomTitle'] as String,
      location: json['location'] as String?,
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble(),
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RoomDataModelToJson(RoomDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomTitle': instance.roomTitle,
      'location': instance.location,
      'monthlyPrice': instance.monthlyPrice,
      'images': instance.images,
    };

AppointmentApiModel _$AppointmentApiModelFromJson(Map<String, dynamic> json) =>
    AppointmentApiModel(
      id: json['_id'] as String?,
      roomId: json['roomId'] as String,
      ownerId: json['ownerId'] as String,
      renterId: json['renterId'] as String,
      renterName: json['renterName'] as String,
      renterEmail: json['renterEmail'] as String,
      renterPhone: json['renterPhone'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      message: json['message'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      room: json['room'] == null
          ? null
          : RoomDataModel.fromJson(json['room'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppointmentApiModelToJson(
        AppointmentApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'roomId': instance.roomId,
      'ownerId': instance.ownerId,
      'renterId': instance.renterId,
      'renterName': instance.renterName,
      'renterEmail': instance.renterEmail,
      'renterPhone': instance.renterPhone,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'appointmentTime': instance.appointmentTime,
      'message': instance.message,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'room': instance.room,
    };
