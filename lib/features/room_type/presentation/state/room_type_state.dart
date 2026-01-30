import 'package:equatable/equatable.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

enum RoomTypeStatus { initial, loading, loaded, error, created, updated, deleted }

class RoomTypeState extends Equatable {
  final RoomTypeStatus status;
  final List<RoomTypeEntity> types;
  final RoomTypeEntity? selectedType;
  final String? errorMessage;

  const RoomTypeState({
    this.status = RoomTypeStatus.initial,
    this.types = const [],
    this.selectedType,
    this.errorMessage,
  });

  RoomTypeState copyWith({
    RoomTypeStatus? status,
    List<RoomTypeEntity>? types,
    RoomTypeEntity? selectedType,
    String? errorMessage,
  }) {
    return RoomTypeState(
      status: status ?? this.status,
      types: types ?? this.types,
      selectedType: selectedType ?? this.selectedType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, types, selectedType, errorMessage];
}
