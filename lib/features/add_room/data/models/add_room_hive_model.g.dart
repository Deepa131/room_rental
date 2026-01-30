// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_room_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddRoomHiveModelAdapter extends TypeAdapter<AddRoomHiveModel> {
  @override
  final int typeId = 3;

  @override
  AddRoomHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddRoomHiveModel(
      roomId: fields[0] as String?,
      ownerId: fields[1] as String?,
      ownerContactNumber: fields[2] as String,
      roomTitle: fields[3] as String,
      monthlyPrice: fields[4] as double,
      location: fields[5] as String,
      roomType: fields[6] as String,
      description: fields[7] as String?,
      images: (fields[8] as List?)?.cast<String>(),
      videos: (fields[9] as List?)?.cast<String>(),
      isAvailable: fields[10] as bool?,
      status: fields[11] as String?,
      createdAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AddRoomHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.roomId)
      ..writeByte(1)
      ..write(obj.ownerId)
      ..writeByte(2)
      ..write(obj.ownerContactNumber)
      ..writeByte(3)
      ..write(obj.roomTitle)
      ..writeByte(4)
      ..write(obj.monthlyPrice)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.roomType)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.images)
      ..writeByte(9)
      ..write(obj.videos)
      ..writeByte(10)
      ..write(obj.isAvailable)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddRoomHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
