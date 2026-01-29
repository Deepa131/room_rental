import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

class GetRoomByUserParams extends Equatable {
  final String ownerId;

  const GetRoomByUserParams({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

final getRoomByUserUsecaseProvider =
    Provider<GetRoomByUserUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return GetRoomByUserUsecase(addRoomRepository: addRoomRepository);
});

class GetRoomByUserUsecase
    implements UsecaseWithParams<List<AddRoomEntity>, GetRoomByUserParams> {
  final IAddRoomRepository _addRoomRepository;

  GetRoomByUserUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, List<AddRoomEntity>>> call(
      GetRoomByUserParams params) {
    return _addRoomRepository.getRoomsByOwner(params.ownerId);
  }
}
