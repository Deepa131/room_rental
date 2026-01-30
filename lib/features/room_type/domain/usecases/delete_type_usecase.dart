import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/room_type/data/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

class DeleteTypeParams extends Equatable {
  final String typeId;

  const DeleteTypeParams({required this.typeId});

  @override
  List<Object?> get props => [typeId];
}

// Create Provider
final deleteTypeUsecaseProvider = Provider<DeleteTypeUsecase>((ref) {
  final typeRepository = ref.read(roomTypeRepositoryProvider);
  return DeleteTypeUsecase(typeRepository: typeRepository);
});

class DeleteTypeUsecase implements UsecaseWithParams<bool, DeleteTypeParams> {
  final IRoomTypeRepository _typeRepository;

  DeleteTypeUsecase({required IRoomTypeRepository typeRepository})
    : _typeRepository = typeRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteTypeParams params) {
    return _typeRepository.deleteType(params.typeId);
  }
}
