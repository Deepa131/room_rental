import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

class GetRoomByIdParams extends Equatable {
  final String roomId;

  const GetRoomByIdParams({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

final getRoomByIdUsecaseProvider = Provider<GetRoomByIdUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return GetRoomByIdUsecase(addRoomRepository: addRoomRepository);
});

class GetRoomByIdUsecase
    implements UsecaseWithParams<AddRoomEntity, GetRoomByIdParams> {
  final IAddRoomRepository _addRoomRepository;

  GetRoomByIdUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, AddRoomEntity>> call(GetRoomByIdParams params) {
    return _addRoomRepository.getRoomById(params.roomId);
  }
}
