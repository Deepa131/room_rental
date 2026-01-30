import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/room_type/data/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

class UpdateTypeUsecaseParams extends Equatable {
  final String typeId;
  final String typeName;
  final String? status;

  const UpdateTypeUsecaseParams({
    required this.typeId,
    required this.typeName,
    this.status,
  });

  @override
  List<Object?> get props => [typeId, typeName, status];
}

final updateTypeUsecaseProvider = Provider<UpdateTypeUsecase>((ref) {
  final typeRepository = ref.read(roomTypeRepositoryProvider);
  return UpdateTypeUsecase(typeRepository: typeRepository);
});

//usecase
class UpdateTypeUsecase implements UsecaseWithParams<bool, UpdateTypeUsecaseParams> {
  final IRoomTypeRepository _typeRepository;

  UpdateTypeUsecase({required IRoomTypeRepository typeRepository})
    : _typeRepository = typeRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateTypeUsecaseParams params) {
    final typeEntity = RoomTypeEntity(
      typeId: params.typeId,
      typeName: params.typeName,
      status: params.status,
    );
    return _typeRepository.updateType(typeEntity);
  }
}
