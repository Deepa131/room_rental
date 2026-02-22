// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentHiveModelAdapter extends TypeAdapter<AppointmentHiveModel> {
  @override
  final int typeId = 5;

  @override
  AppointmentHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentHiveModel(
      appointmentId: fields[0] as String?,
      roomId: fields[1] as String,
      ownerId: fields[2] as String,
      renterId: fields[3] as String,
      renterName: fields[4] as String,
      renterEmail: fields[5] as String,
      renterPhone: fields[6] as String,
      appointmentDate: fields[7] as DateTime,
      appointmentTime: fields[8] as String,
      message: fields[9] as String?,
      status: fields[10] as String,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.appointmentId)
      ..writeByte(1)
      ..write(obj.roomId)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.renterId)
      ..writeByte(4)
      ..write(obj.renterName)
      ..writeByte(5)
      ..write(obj.renterEmail)
      ..writeByte(6)
      ..write(obj.renterPhone)
      ..writeByte(7)
      ..write(obj.appointmentDate)
      ..writeByte(8)
      ..write(obj.appointmentTime)
      ..writeByte(9)
      ..write(obj.message)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
