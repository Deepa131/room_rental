import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/core/usecases/app_usecase.dart';
import 'package:room_rental/features/add_room/data/repositories/add_room_repository.dart';
import 'package:room_rental/features/add_room/domain/repositories/add_room_repository.dart';

final uploadRoomVideoUsecaseProvider =
    Provider<UploadRoomVideoUsecase>((ref) {
  final addRoomRepository = ref.read(addRoomRepositoryProvider);
  return UploadRoomVideoUsecase(addRoomRepository: addRoomRepository);
});

class UploadRoomVideoUsecase implements UsecaseWithParams<String, File> {
  final IAddRoomRepository _addRoomRepository;

  UploadRoomVideoUsecase({required IAddRoomRepository addRoomRepository})
      : _addRoomRepository = addRoomRepository;

  @override
  Future<Either<Failure, String>> call(File video) {
    return _addRoomRepository.uploadRoomVideo(video);
  }
}
