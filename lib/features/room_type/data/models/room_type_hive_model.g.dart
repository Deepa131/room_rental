// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_type_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomTypeHiveModelAdapter extends TypeAdapter<RoomTypeHiveModel> {
  @override
  final int typeId = 2;

  @override
  RoomTypeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomTypeHiveModel(
      typeId: fields[0] as String?,
      typeName: fields[1] as String,
      status: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RoomTypeHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.typeId)
      ..writeByte(1)
      ..write(obj.typeName)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomTypeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
