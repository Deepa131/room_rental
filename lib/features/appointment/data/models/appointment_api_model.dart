import 'package:json_annotation/json_annotation.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

part 'appointment_api_model.g.dart';

@JsonSerializable()
class RoomDataModel {
  final String? id;
  final String roomTitle;
  final String? location;
  final double? monthlyPrice;
  final List<String>? images;

  RoomDataModel({
    this.id,
    required this.roomTitle,
    this.location,
    this.monthlyPrice,
    this.images,
  });

  factory RoomDataModel.fromJson(Map<String, dynamic> json) =>
      _$RoomDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomDataModelToJson(this);

  RoomData toEntity() {
    return RoomData(
      id: id,
      roomTitle: roomTitle,
      location: location,
      monthlyPrice: monthlyPrice,
      images: images,
    );
  }
}

@JsonSerializable()
class AppointmentApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String roomId;
  final String ownerId;
  final String renterId;
  final String renterName;
  final String renterEmail;
  final String renterPhone;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String? message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RoomDataModel? room;

  AppointmentApiModel({
    this.id,
    required this.roomId,
    required this.ownerId,
    required this.renterId,
    required this.renterName,
    required this.renterEmail,
    required this.renterPhone,
    required this.appointmentDate,
    required this.appointmentTime,
    this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.room,
  });

  factory AppointmentApiModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentApiModelToJson(this);

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      appointmentId: id,
      roomId: roomId,
      ownerId: ownerId,
      renterId: renterId,
      renterName: renterName,
      renterEmail: renterEmail,
      renterPhone: renterPhone,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      room: room?.toEntity(),
    );
  }

  factory AppointmentApiModel.fromEntity(AppointmentEntity entity) {
    return AppointmentApiModel(
      id: entity.appointmentId,
      roomId: entity.roomId,
      ownerId: entity.ownerId,
      renterId: entity.renterId,
      renterName: entity.renterName,
      renterEmail: entity.renterEmail,
      renterPhone: entity.renterPhone,
      appointmentDate: entity.appointmentDate,
      appointmentTime: entity.appointmentTime,
      message: entity.message,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      room: null, 
    );
  }
}
