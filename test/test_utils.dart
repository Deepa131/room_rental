import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

RoomTypeEntity makeRoomType({
  String? typeId,
  String typeName = 'Single Room',
  String? status = 'active',
}) {
  return RoomTypeEntity(typeId: typeId, typeName: typeName, status: status);
}

AddRoomEntity makeRoom({
  String? roomId,
  String? ownerId,
  String? ownerName,
  String ownerContactNumber = '9800000000',
  String roomTitle = 'Cozy Room',
  double monthlyPrice = 10000,
  String location = 'Kathmandu',
  LocationCoordsEntity? locationCoords,
  RoomTypeEntity? roomType,
  String? description = 'Nice and cozy',
  List<String>? images,
  List<String>? videos,
  bool isAvailable = true,
  String? approvalStatus,
  DateTime? createdAt,
}) {
  return AddRoomEntity(
    roomId: roomId,
    ownerId: ownerId,
    ownerName: ownerName,
    ownerContactNumber: ownerContactNumber,
    roomTitle: roomTitle,
    monthlyPrice: monthlyPrice,
    location: location,
    locationCoords: locationCoords,
    roomType: roomType ?? makeRoomType(),
    description: description,
    images: images,
    videos: videos,
    isAvailable: isAvailable,
    approvalStatus: approvalStatus,
    createdAt: createdAt,
  );
}
