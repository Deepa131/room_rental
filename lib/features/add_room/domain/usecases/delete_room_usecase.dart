import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

class DeleteRoomParams extends Equatable {
  final String roomId;

  const DeleteRoomParams({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

final deleteRoomUsecaseProvider = Provider<DeleteRoomUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return DeleteRoomUsecase(addRoomRepository: addRoomRepository);
});

class DeleteRoomUsecase implements UsecaseWithParams<bool, DeleteRoomParams> {
  final IAddRoomRepository _addRoomRepository;

  DeleteRoomUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteRoomParams params) {
    return _addRoomRepository.deleteRoom(params.roomId);
  }
}
