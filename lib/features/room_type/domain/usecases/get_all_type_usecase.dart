import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/room_type/data/repositories/room_type_repository.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/repositories/room_type_repository.dart';

final getAllTypeUsecaseProvider = Provider<GetAllTypeUsecase>((ref) {
  final typeRepository = ref.read(roomTypeRepositoryProvider);
  return GetAllTypeUsecase(typeRepository: typeRepository);
});

class GetAllTypeUsecase implements UsecaseWithoutParams<List<RoomTypeEntity>> {
  final IRoomTypeRepository _typeRepository;

  GetAllTypeUsecase({required IRoomTypeRepository typeRepository})
    : _typeRepository = typeRepository;

  @override
  Future<Either<Failure, List<RoomTypeEntity>>> call() {
    return _typeRepository.getAllTypes();
  }
}
