import 'package:equatable/equatable.dart';

class RoomTypeEntity extends Equatable {
  final String? typeId;
  final String typeName;
  final String? status;

  const RoomTypeEntity({this.typeId, required this.typeName, this.status});

  @override
  List<Object?> get props => [typeId, typeName, status];
}