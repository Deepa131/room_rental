import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/features/add_room/domain/usecases/create_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/delete_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_all_rooms_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_room_by_id_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_room_by_user_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/update_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/upload_room_image_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/upload_room_video_usecase.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

final addRoomViewModelProvider =
    NotifierProvider<AddRoomViewModel, AddRoomState>(
  AddRoomViewModel.new,
);

class AddRoomViewModel extends Notifier<AddRoomState> {
  late final GetAllRoomsUsecase _getAllRoomsUsecase;
  late final GetRoomByIdUsecase _getRoomByIdUsecase;
  late final GetRoomByUserUsecase _getRoomByUserUsecase;
  late final CreateRoomUsecase _createRoomUsecase;
  late final UpdateRoomUsecase _updateRoomUsecase;
  late final DeleteRoomUsecase _deleteRoomUsecase;
  late final UploadRoomImageUsecase _uploadRoomImageUsecase;
  late final UploadRoomVideoUsecase _uploadRoomVideoUsecase;

  @override
  AddRoomState build() {
    _getAllRoomsUsecase = ref.read(getAllRoomsUsecaseProvider);
    _getRoomByIdUsecase = ref.read(getRoomByIdUsecaseProvider);
    _getRoomByUserUsecase = ref.read(getRoomByUserUsecaseProvider);
    _createRoomUsecase = ref.read(createRoomUsecaseProvider);
    _updateRoomUsecase = ref.read(updateRoomUsecaseProvider);
    _deleteRoomUsecase = ref.read(deleteRoomUsecaseProvider);
    _uploadRoomImageUsecase = ref.read(uploadRoomImageUsecaseProvider);
    _uploadRoomVideoUsecase = ref.read(uploadRoomVideoUsecaseProvider);

    return const AddRoomState();
  }

  Future<void> getAllRooms() async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _getAllRoomsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (rooms) {
        final availableRooms =
            rooms.where((room) => room.isAvailable).toList();
        final bookedRooms =
            rooms.where((room) => !room.isAvailable).toList();

        state = state.copyWith(
          status: AddRoomStatus.loaded,
          rooms: rooms,
          availableRooms: availableRooms,
          bookedRooms: bookedRooms,
        );
      },
    );
  }

  Future<void> getRoomById(String roomId) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _getRoomByIdUsecase(
      GetRoomByIdParams(roomId: roomId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (room) =>
          state = state.copyWith(status: AddRoomStatus.loaded, selectedRoom: room),
    );
  }

  Future<void> getMyRooms(String ownerId) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _getRoomByUserUsecase(
      GetRoomByUserParams(ownerId: ownerId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (rooms) {
        final availableRooms =
            rooms.where((room) => room.isAvailable).toList();
        final bookedRooms =
            rooms.where((room) => !room.isAvailable).toList();

        state = state.copyWith(
          status: AddRoomStatus.loaded,
          myRooms: rooms,
          availableRooms: availableRooms,
          bookedRooms: bookedRooms,
        );
      },
    );
  }

  Future<void> createRoom({
    required String ownerId,
    required String ownerContactNumber,
    required String roomTitle,
    required double monthlyPrice,
    required String location,
    required RoomTypeEntity roomType,
    String? description,
    List<String>? images,
    List<String>? videos,
  }) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _createRoomUsecase(
      CreateRoomParams(
        ownerId: ownerId,
        ownerContactNumber: ownerContactNumber,
        roomTitle: roomTitle,
        monthlyPrice: monthlyPrice,
        location: location,
        roomType: roomType,
        description: description,
        images: images,
        videos: videos,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(
          status: AddRoomStatus.created,
          resetUploadedImageUrl: true,
          resetUploadedVideoUrl: true,
        );
        getAllRooms();
      },
    );
  }

  Future<void> updateRoom({
    required String roomId,
    required String ownerId,
    required String ownerContactNumber,
    required String roomTitle,
    required double monthlyPrice,
    required String location,
    required RoomTypeEntity roomType,
    String? description,
    List<String>? images,
    List<String>? videos,
    bool? isAvailable,
    String? approvalStatus,
  }) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _updateRoomUsecase(
      UpdateRoomParams(
        roomId: roomId,
        ownerId: ownerId,
        ownerContactNumber: ownerContactNumber,
        roomTitle: roomTitle,
        monthlyPrice: monthlyPrice,
        location: location,
        roomType: roomType,
        description: description,
        images: images,
        videos: videos,
        isAvailable: isAvailable,
        approvalStatus: approvalStatus,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: AddRoomStatus.updated);
        getAllRooms();
      },
    );
  }

  Future<void> deleteRoom(String roomId) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _deleteRoomUsecase(
      DeleteRoomParams(roomId: roomId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AddRoomStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: AddRoomStatus.deleted);
        getAllRooms();
      },
    );
  }

  Future<String?> uploadRoomImage(File image) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _uploadRoomImageUsecase(image);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddRoomStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (url) {
        state = state.copyWith(
          status: AddRoomStatus.loaded,
          uploadedImageUrl: url,
        );
        return url;
      },
    );
  }

  Future<String?> uploadRoomVideo(File video) async {
    state = state.copyWith(status: AddRoomStatus.loading);

    final result = await _uploadRoomVideoUsecase(video);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AddRoomStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (url) {
        state = state.copyWith(
          status: AddRoomStatus.loaded,
          uploadedVideoUrl: url,
        );
        return url;
      },
    );
  }

  void clearError() {
    state = state.copyWith(resetErrorMessage: true);
  }

  void clearSelectedRoom() {
    state = state.copyWith(resetSelectedRoom: true);
  }

  void clearRoomState() {
    state = state.copyWith(
      status: AddRoomStatus.initial,
      resetUploadedImageUrl: true,
      resetUploadedVideoUrl: true,
      resetErrorMessage: true,
    );
  }
}
