import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class CreateRoomParams extends Equatable {
  final String ownerId;
  final String ownerContactNumber;
  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final RoomTypeEntity roomType;
  final String? description;
  final List<String>? images;
  final List<String>? videos;
  final Map<String, dynamic>? locationCoords;

  const CreateRoomParams({
    required this.ownerId,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    required this.roomType,
    this.description,
    this.images,
    this.videos,
    this.locationCoords,
  });

  @override
  List<Object?> get props => [
        ownerId,
        ownerContactNumber,
        roomTitle,
        monthlyPrice,
        location,
        roomType,
        description,
        images,
        videos,
        locationCoords,
      ];
}

final createRoomUsecaseProvider = Provider<CreateRoomUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return CreateRoomUsecase(addRoomRepository: addRoomRepository);
});

class CreateRoomUsecase implements UsecaseWithParams<bool, CreateRoomParams> {
  final IAddRoomRepository _addRoomRepository;

  CreateRoomUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, bool>> call(CreateRoomParams params) {
    final roomEntity = AddRoomEntity(
      ownerId: params.ownerId,
      ownerContactNumber: params.ownerContactNumber,
      roomTitle: params.roomTitle,
      monthlyPrice: params.monthlyPrice,
      location: params.location,
      locationCoords: params.locationCoords != null
          ? LocationCoordsEntity(
              latitude: params.locationCoords!['latitude'] as double,
              longitude: params.locationCoords!['longitude'] as double,
              address: params.locationCoords!['address'] as String?,
            )
          : null,
      roomType: params.roomType,
      description: params.description,
      images: params.images,
      videos: params.videos,
    );

    return _addRoomRepository.createRoom(roomEntity);
  }
}
