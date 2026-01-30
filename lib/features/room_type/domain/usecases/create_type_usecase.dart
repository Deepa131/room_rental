import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/room_type/data/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

class CreateTypeParams extends Equatable {
  final String typeName;

  const CreateTypeParams({required this.typeName});
  
  @override
  List<Object?> get props => [typeName];
}

final createTypeUsecaseProvider = Provider<CreateTypeUsecase>((ref) {
  final typeRepository = ref.read(roomTypeRepositoryProvider);
  return CreateTypeUsecase(typeRepository: typeRepository);
});

//Usecase
class CreateTypeUsecase implements UsecaseWithParams<bool, CreateTypeParams> {
  final IRoomTypeRepository _typeRepository;

  CreateTypeUsecase({required IRoomTypeRepository typeRepository})
    : _typeRepository = typeRepository;

  @override
  Future<Either<Failure, bool>> call(CreateTypeParams params) {
    RoomTypeEntity typeEntity = RoomTypeEntity(typeName: params.typeName);
    return _typeRepository.createType(typeEntity);
  }
}
