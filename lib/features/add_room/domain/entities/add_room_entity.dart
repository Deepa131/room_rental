import 'package:equatable/equatable.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class AddRoomEntity extends Equatable {
  final String? roomId;
  final String? ownerId;
  final String ownerContactNumber;

  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final RoomTypeEntity roomType;
  final String? description;

  final List<String>? images;
  final List<String>? videos;

  final bool isAvailable;
  final String? approvalStatus; 
  final DateTime? createdAt;

  const AddRoomEntity({
    this.roomId,
    this.ownerId,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    required this.roomType,
    this.description,
    this.images,
    this.videos,
    this.isAvailable = true,
    this.approvalStatus,
    this.createdAt, 
  });

  @override
  List<Object?> get props => [
        roomId,
        ownerId,
        ownerContactNumber,
        roomTitle,
        monthlyPrice,
        location,
        roomType,
        description,
        images,
        videos,
        isAvailable,
        approvalStatus,
        createdAt,
      ];
}
