import 'package:equatable/equatable.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class LocationCoordsEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationCoordsEntity({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

class AddRoomEntity extends Equatable {
  final String? roomId;
  final String? ownerId;
  final String? ownerName;
  final String ownerContactNumber;

  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final LocationCoordsEntity? locationCoords;
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
    this.ownerName,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    this.locationCoords,
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
        ownerName,
        ownerContactNumber,
        roomTitle,
        monthlyPrice,
        location,
        locationCoords,
        roomType,
        description,
        images,
        videos,
        isAvailable,
        approvalStatus,
        createdAt,
      ];
}
