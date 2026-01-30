import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/features/room_type/domain/usecases/create_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/delete_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/get_all_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/get_type_byid_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/update_type_usecase.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';

final typeViewmodelProvider = NotifierProvider<RoomTypeViewmodel, RoomTypeState>(
  RoomTypeViewmodel.new,
);

class RoomTypeViewmodel extends Notifier<RoomTypeState> {
  late final GetAllTypeUsecase _getAllTypeUsecase;
  late final GetTypeByIdUsecase _getTypeByIdUsecase;
  late final UpdateTypeUsecase _updateTypeUsecase;
  late final CreateTypeUsecase _createTypeUsecase;
  late final DeleteTypeUsecase _deleteTypeUsecase;
  @override
  RoomTypeState build() {
    _getAllTypeUsecase = ref.read(getAllTypeUsecaseProvider);
    _getTypeByIdUsecase = ref.read(getTypeByIdUsecaseProvider);
    _updateTypeUsecase = ref.read(updateTypeUsecaseProvider);
    _createTypeUsecase = ref.read(createTypeUsecaseProvider);
    _deleteTypeUsecase = ref.read(deleteTypeUsecaseProvider);
    return const RoomTypeState();
  }

  Future<void> getAllTypes() async {
    state = state.copyWith(status: RoomTypeStatus.loading);

    final result = await _getAllTypeUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: RoomTypeStatus.error,
        errorMessage: failure.message,
      ),
      (types) => state = state.copyWith(status: RoomTypeStatus.loaded, types: types),
    );
  }

  Future<void> getTypeById(String typeId) async {
    state = state.copyWith(status: RoomTypeStatus.loading);

    final result = await _getTypeByIdUsecase(
      GetTypeByIdParams(typeId: typeId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoomTypeStatus.error,
        errorMessage: failure.message,
      ),
      (type) => state = state.copyWith(
        status: RoomTypeStatus.loaded,
        selectedType: type,
      ),
    );
  }

  Future<void> createType(String typeName) async {
    state = state.copyWith(status: RoomTypeStatus.loading);

    final result = await _createTypeUsecase(
      CreateTypeParams(typeName: typeName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoomTypeStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: RoomTypeStatus.created);
        getAllTypes();
      },
    );
  }

  Future<void> updateType({
    required String typeId,
    required String typeName,
    String? status,
  }) async {
    state = state.copyWith(status: RoomTypeStatus.loading);

    final result = await _updateTypeUsecase(
      UpdateTypeUsecaseParams(typeId: typeId, typeName: typeName, status: status),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoomTypeStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: RoomTypeStatus.updated);
        getAllTypes();
      },
    );
  }

  Future<void> deleteType(String typeId) async {
    state = state.copyWith(status: RoomTypeStatus.loading);

    final result = await _deleteTypeUsecase(
      DeleteTypeParams(typeId: typeId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: RoomTypeStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: RoomTypeStatus.deleted);
        getAllTypes();
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSelectedType() {
    state = state.copyWith(selectedType: null);
  }
}
