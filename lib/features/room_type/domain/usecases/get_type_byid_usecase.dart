import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/room_type/data/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

class GetTypeByIdParams extends Equatable {
  final String typeId;

  const GetTypeByIdParams({required this.typeId});

  @override
  List<Object?> get props => [typeId];
}

// Create Provider
final getTypeByIdUsecaseProvider = Provider<GetTypeByIdUsecase>((ref) {
  final typeRepository = ref.read(roomTypeRepositoryProvider);
  return GetTypeByIdUsecase(typeRepository: typeRepository);
});

class GetTypeByIdUsecase
    implements UsecaseWithParams<RoomTypeEntity, GetTypeByIdParams> {
  final IRoomTypeRepository _typeRepository;

  GetTypeByIdUsecase({required IRoomTypeRepository typeRepository})
    : _typeRepository = typeRepository;

  @override
  Future<Either<Failure, RoomTypeEntity>> call(GetTypeByIdParams params) {
    return _typeRepository.getTypeById(params.typeId);
  }
}
