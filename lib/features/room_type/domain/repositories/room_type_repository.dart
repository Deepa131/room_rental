import 'package:dartz/dartz.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

abstract interface class IRoomTypeRepository {
  Future<Either<Failure, List<RoomTypeEntity>>> getAllTypes();
  Future<Either<Failure, RoomTypeEntity>> getTypeById(String typeId);
  Future<Either<Failure, bool>> createType(RoomTypeEntity type);
  Future<Either<Failure, bool>> updateType(RoomTypeEntity type);
  Future<Either<Failure, bool>> deleteType(String typeId);
}