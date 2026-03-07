import 'package:hive_flutter/hive_flutter.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

part 'appointment_hive_model.g.dart';

@HiveType(typeId: 5)
class AppointmentHiveModel {
  @HiveField(0)
  final String? appointmentId;

  @HiveField(1)
  final String roomId;

  @HiveField(2)
  final String ownerId;

  @HiveField(3)
  final String renterId;

  @HiveField(4)
  final String renterName;

  @HiveField(5)
  final String renterEmail;

  @HiveField(6)
  final String renterPhone;

  @HiveField(7)
  final DateTime appointmentDate;

  @HiveField(8)
  final String appointmentTime;

  @HiveField(9)
  final String? message;

  @HiveField(10)
  final String status;

  @HiveField(11)
  final DateTime? createdAt;

  @HiveField(12)
  final DateTime? updatedAt;

  AppointmentHiveModel({
    this.appointmentId,
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
  });

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      appointmentId: appointmentId,
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
    );
  }

  factory AppointmentHiveModel.fromEntity(AppointmentEntity entity) {
    return AppointmentHiveModel(
      appointmentId: entity.appointmentId,
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
    );
  }
}
