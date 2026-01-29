import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class UpdateRoomParams extends Equatable {
  final String roomId;
  final String ownerId;
  final String ownerContactNumber;
  final String roomTitle;
  final double monthlyPrice;
  final String location;
  final RoomTypeEntity roomType;
  final String? description;
  final List<String>? images;
  final List<String>? videos;
  final bool? isAvailable;
  final String? approvalStatus;

  const UpdateRoomParams({
    required this.roomId,
    required this.ownerId,
    required this.ownerContactNumber,
    required this.roomTitle,
    required this.monthlyPrice,
    required this.location,
    required this.roomType,
    this.description,
    this.images,
    this.videos,
    this.isAvailable,
    this.approvalStatus,
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
      ];
}

final updateRoomUsecaseProvider = Provider<UpdateRoomUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return UpdateRoomUsecase(addRoomRepository: addRoomRepository);
});

class UpdateRoomUsecase implements UsecaseWithParams<bool, UpdateRoomParams> {
  final IAddRoomRepository _addRoomRepository;

  UpdateRoomUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateRoomParams params) {
    final roomEntity = AddRoomEntity(
      roomId: params.roomId,
      ownerId: params.ownerId,
      ownerContactNumber: params.ownerContactNumber,
      roomTitle: params.roomTitle,
      monthlyPrice: params.monthlyPrice,
      location: params.location,
      roomType: params.roomType,
      description: params.description,
      images: params.images,
      videos: params.videos,
      isAvailable: params.isAvailable ?? true,
      approvalStatus: params.approvalStatus,
    );

    return _addRoomRepository.updateRoom(roomEntity);
  }
}
