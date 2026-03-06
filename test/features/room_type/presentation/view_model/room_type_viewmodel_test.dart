import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';
import 'package:room_rental/features/room_type/domain/usecases/get_all_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/create_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/delete_type_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/get_type_byid_usecase.dart';
import 'package:room_rental/features/room_type/domain/usecases/update_type_usecase.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';

class MockGetAllTypeUsecase extends Mock implements GetAllTypeUsecase {}
class MockCreateTypeUsecase extends Mock implements CreateTypeUsecase {}
class MockDeleteTypeUsecase extends Mock implements DeleteTypeUsecase {}
class MockGetTypeByIdUsecase extends Mock implements GetTypeByIdUsecase {}
class MockUpdateTypeUsecase extends Mock implements UpdateTypeUsecase {}

void main() {
  late ProviderContainer container;
  late MockGetAllTypeUsecase mockGetAllTypeUsecase;
  late MockCreateTypeUsecase mockCreateTypeUsecase;
  late MockDeleteTypeUsecase mockDeleteTypeUsecase;
  late MockGetTypeByIdUsecase mockGetTypeByIdUsecase;
  late MockUpdateTypeUsecase mockUpdateTypeUsecase;

  setUpAll(() {
    registerFallbackValue(const DeleteTypeParams(typeId: 'fallback-type-id'));
  });

  setUp(() {
    mockGetAllTypeUsecase = MockGetAllTypeUsecase();
    mockCreateTypeUsecase = MockCreateTypeUsecase();
    mockDeleteTypeUsecase = MockDeleteTypeUsecase();
    mockGetTypeByIdUsecase = MockGetTypeByIdUsecase();
    mockUpdateTypeUsecase = MockUpdateTypeUsecase();

    container = ProviderContainer(
      overrides: [
        getAllTypeUsecaseProvider.overrideWithValue(mockGetAllTypeUsecase),
        createTypeUsecaseProvider.overrideWithValue(mockCreateTypeUsecase),
        deleteTypeUsecaseProvider.overrideWithValue(mockDeleteTypeUsecase),
        getTypeByIdUsecaseProvider.overrideWithValue(mockGetTypeByIdUsecase),
        updateTypeUsecaseProvider.overrideWithValue(mockUpdateTypeUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tRoomTypes = [
    RoomTypeEntity(
      typeId: '1',
      typeName: 'Single Room',
      status: 'active',
    ),
    RoomTypeEntity(
      typeId: '2',
      typeName: 'Double Room',
      status: 'active',
    ),
  ];

  group('RoomTypeViewModel - GetAllTypes', () {
    test('initial state should be RoomTypeState with initial status', () {
      final viewModel = container.read(typeViewmodelProvider.notifier);

      expect(viewModel.state.status, RoomTypeStatus.initial);
      expect(viewModel.state.types, isEmpty);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('should emit loading and loaded states when getAllTypes is successful', () async {
      when(() => mockGetAllTypeUsecase())
          .thenAnswer((_) async => Right(tRoomTypes));

      final viewModel = container.read(typeViewmodelProvider.notifier);

      await viewModel.getAllTypes();

      expect(viewModel.state.status, RoomTypeStatus.loaded);
      expect(viewModel.state.types, tRoomTypes);
      expect(viewModel.state.types.length, 2);
      expect(viewModel.state.errorMessage, isNull);
      verify(() => mockGetAllTypeUsecase()).called(1);
    });

    test('should emit error state when getAllTypes fails', () async {
      const failure = ApiFailure(message: 'Failed to load types', statusCode: 500);
      when(() => mockGetAllTypeUsecase())
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(typeViewmodelProvider.notifier);

      await viewModel.getAllTypes();

      expect(viewModel.state.status, RoomTypeStatus.error);
      expect(viewModel.state.errorMessage, 'Failed to load types');
      verify(() => mockGetAllTypeUsecase()).called(1);
    });
  });

  group('RoomTypeViewModel - DeleteType', () {
    test('should trigger type refresh when delete is successful', () async {
      when(() => mockDeleteTypeUsecase(any<DeleteTypeParams>()))
          .thenAnswer((_) async => const Right(true));
      when(() => mockGetAllTypeUsecase())
          .thenAnswer((_) async => const Right([]));

      final viewModel = container.read(typeViewmodelProvider.notifier);

      await viewModel.deleteType('type123');

      expect(viewModel.state.status, RoomTypeStatus.loading);
      verify(() => mockDeleteTypeUsecase(any<DeleteTypeParams>())).called(1);
      verify(() => mockGetAllTypeUsecase()).called(1);
    });

    test('should emit error state when delete fails', () async {
      const failure = ApiFailure(message: 'Cannot delete type', statusCode: 400);
      when(() => mockDeleteTypeUsecase(any<DeleteTypeParams>()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(typeViewmodelProvider.notifier);

      await viewModel.deleteType('type123');

      expect(viewModel.state.status, RoomTypeStatus.error);
      expect(viewModel.state.errorMessage, 'Cannot delete type');
      verify(() => mockDeleteTypeUsecase(any<DeleteTypeParams>())).called(1);
    });
  });
}
