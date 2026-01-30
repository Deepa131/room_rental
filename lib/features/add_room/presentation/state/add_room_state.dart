import 'package:equatable/equatable.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';

enum AddRoomStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
  imageUploading,
  videoUploading,
}

class AddRoomState extends Equatable {
  final AddRoomStatus status;
  final List<AddRoomEntity> rooms;
  final List<AddRoomEntity> availableRooms;
  final List<AddRoomEntity> bookedRooms;
  final List<AddRoomEntity> myRooms;
  final AddRoomEntity? selectedRoom;

  final String? errorMessage;
  final String? uploadedImageUrl;
  final String? uploadedVideoUrl;

  const AddRoomState({
    this.status = AddRoomStatus.initial,
    this.rooms = const [],
    this.availableRooms = const [],
    this.bookedRooms = const [],
    this.myRooms = const [],
    this.selectedRoom,
    this.errorMessage,
    this.uploadedImageUrl,
    this.uploadedVideoUrl,
  });

  AddRoomState copyWith({
    AddRoomStatus? status,
    List<AddRoomEntity>? rooms,
    List<AddRoomEntity>? availableRooms,
    List<AddRoomEntity>? bookedRooms,
    List<AddRoomEntity>? myRooms,
    AddRoomEntity? selectedRoom,
    bool resetSelectedRoom = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    String? uploadedImageUrl,
    bool resetUploadedImageUrl = false,
    String? uploadedVideoUrl,
    bool resetUploadedVideoUrl = false,
  }) {
    return AddRoomState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      availableRooms: availableRooms ?? this.availableRooms,
      bookedRooms: bookedRooms ?? this.bookedRooms,
      myRooms: myRooms ?? this.myRooms,
      selectedRoom: resetSelectedRoom
          ? null
          : (selectedRoom ?? this.selectedRoom),
      errorMessage: resetErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      uploadedImageUrl: resetUploadedImageUrl
          ? null
          : (uploadedImageUrl ?? this.uploadedImageUrl),
      uploadedVideoUrl: resetUploadedVideoUrl
          ? null
          : (uploadedVideoUrl ?? this.uploadedVideoUrl),
    );
  }

  @override
  List<Object?> get props => [
        status,
        rooms,
        availableRooms,
        bookedRooms,
        myRooms,
        selectedRoom,
        errorMessage,
        uploadedImageUrl,
        uploadedVideoUrl,
      ];
}
