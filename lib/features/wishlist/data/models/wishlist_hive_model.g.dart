// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WishlistHiveModelAdapter extends TypeAdapter<WishlistHiveModel> {
  @override
  final int typeId = 4;

  @override
  WishlistHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishlistHiveModel(
      userId: fields[0] as String,
      roomIds: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, WishlistHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.roomIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
