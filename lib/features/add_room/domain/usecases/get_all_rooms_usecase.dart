import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

final getAllRoomsUsecaseProvider = Provider<GetAllRoomsUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return GetAllRoomsUsecase(addRoomRepository: addRoomRepository);
});

class GetAllRoomsUsecase implements UsecaseWithoutParams<List<AddRoomEntity>> {
  final IAddRoomRepository _addRoomRepository;

  GetAllRoomsUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, List<AddRoomEntity>>> call() {
    return _addRoomRepository.getAllRooms();
  }
}
