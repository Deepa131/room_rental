import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_all_rooms_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/create_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/delete_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_room_by_id_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/get_room_by_user_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/update_room_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/upload_room_image_usecase.dart';
import 'package:room_rental/features/add_room/domain/usecases/upload_room_video_usecase.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/room_type/domain/entities/room_type_entity.dart';

class MockGetAllRoomsUsecase extends Mock implements GetAllRoomsUsecase {}
class MockCreateRoomUsecase extends Mock implements CreateRoomUsecase {}
class MockDeleteRoomUsecase extends Mock implements DeleteRoomUsecase {}
class MockGetRoomByIdUsecase extends Mock implements GetRoomByIdUsecase {}
class MockGetRoomByUserUsecase extends Mock implements GetRoomByUserUsecase {}
class MockUpdateRoomUsecase extends Mock implements UpdateRoomUsecase {}
class MockUploadRoomImageUsecase extends Mock implements UploadRoomImageUsecase {}
class MockUploadRoomVideoUsecase extends Mock implements UploadRoomVideoUsecase {}

void main() {
  late ProviderContainer container;
  late MockGetAllRoomsUsecase mockGetAllRoomsUsecase;
  late MockCreateRoomUsecase mockCreateRoomUsecase;
  late MockDeleteRoomUsecase mockDeleteRoomUsecase;
  late MockGetRoomByIdUsecase mockGetRoomByIdUsecase;
  late MockGetRoomByUserUsecase mockGetRoomByUserUsecase;
  late MockUpdateRoomUsecase mockUpdateRoomUsecase;
  late MockUploadRoomImageUsecase mockUploadRoomImageUsecase;
  late MockUploadRoomVideoUsecase mockUploadRoomVideoUsecase;

  setUpAll(() {
    registerFallbackValue(const DeleteRoomParams(roomId: 'fallback-room-id'));
  });

  setUp(() {
    mockGetAllRoomsUsecase = MockGetAllRoomsUsecase();
    mockCreateRoomUsecase = MockCreateRoomUsecase();
    mockDeleteRoomUsecase = MockDeleteRoomUsecase();
    mockGetRoomByIdUsecase = MockGetRoomByIdUsecase();
    mockGetRoomByUserUsecase = MockGetRoomByUserUsecase();
    mockUpdateRoomUsecase = MockUpdateRoomUsecase();
    mockUploadRoomImageUsecase = MockUploadRoomImageUsecase();
    mockUploadRoomVideoUsecase = MockUploadRoomVideoUsecase();

    container = ProviderContainer(
      overrides: [
        getAllRoomsUsecaseProvider.overrideWithValue(mockGetAllRoomsUsecase),
        createRoomUsecaseProvider.overrideWithValue(mockCreateRoomUsecase),
        deleteRoomUsecaseProvider.overrideWithValue(mockDeleteRoomUsecase),
        getRoomByIdUsecaseProvider.overrideWithValue(mockGetRoomByIdUsecase),
        getRoomByUserUsecaseProvider.overrideWithValue(mockGetRoomByUserUsecase),
        updateRoomUsecaseProvider.overrideWithValue(mockUpdateRoomUsecase),
        uploadRoomImageUsecaseProvider.overrideWithValue(mockUploadRoomImageUsecase),
        uploadRoomVideoUsecaseProvider.overrideWithValue(mockUploadRoomVideoUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tRoomType = RoomTypeEntity(
    typeId: '1',
    typeName: 'Single Room',
    status: 'active',
  );

  final tRooms = [
    AddRoomEntity(
      roomId: '1',
      ownerId: 'owner1',
      ownerName: 'John',
      ownerContactNumber: '9800000000',
      roomTitle: 'Test Room',
      monthlyPrice: 12000,
      location: 'Kathmandu',
      roomType: tRoomType,
      isAvailable: true,
      approvalStatus: 'approved',
    ),
  ];

  group('AddRoomViewModel - GetAllRooms', () {
    test('initial state should be AddRoomState with initial status', () {
      final viewModel = container.read(addRoomViewModelProvider.notifier);

      expect(viewModel.state.status, AddRoomStatus.initial);
      expect(viewModel.state.rooms, isEmpty);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('should emit loading and loaded states when getAllRooms is successful', () async {
      when(() => mockGetAllRoomsUsecase())
          .thenAnswer((_) async => Right(tRooms));

      final viewModel = container.read(addRoomViewModelProvider.notifier);

      await viewModel.getAllRooms();

      expect(viewModel.state.status, AddRoomStatus.loaded);
      expect(viewModel.state.rooms, tRooms);
      expect(viewModel.state.errorMessage, isNull);
      verify(() => mockGetAllRoomsUsecase()).called(1);
    });

    test('should emit error state when getAllRooms fails', () async {
      const failure = ApiFailure(message: 'Failed to load rooms', statusCode: 500);
      when(() => mockGetAllRoomsUsecase())
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(addRoomViewModelProvider.notifier);

      await viewModel.getAllRooms();

      expect(viewModel.state.status, AddRoomStatus.error);
      expect(viewModel.state.errorMessage, 'Failed to load rooms');
      verify(() => mockGetAllRoomsUsecase()).called(1);
    });
  });

  group('AddRoomViewModel - DeleteRoom', () {
    test('should trigger rooms refresh when delete is successful', () async {
      when(() => mockDeleteRoomUsecase(any<DeleteRoomParams>()))
          .thenAnswer((_) async => const Right(true));
      when(() => mockGetAllRoomsUsecase())
          .thenAnswer((_) async => Right(<AddRoomEntity>[]));

      final viewModel = container.read(addRoomViewModelProvider.notifier);

      await viewModel.deleteRoom('room123');

      expect(viewModel.state.status, AddRoomStatus.loading);
      verify(() => mockDeleteRoomUsecase(any<DeleteRoomParams>())).called(1);
      verify(() => mockGetAllRoomsUsecase()).called(greaterThanOrEqualTo(1));
    });

    test('should emit error state when delete fails', () async {
      const failure = ApiFailure(message: 'Failed to delete room', statusCode: 400);
      when(() => mockDeleteRoomUsecase(any<DeleteRoomParams>()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(addRoomViewModelProvider.notifier);

      await viewModel.deleteRoom('room123');

      expect(viewModel.state.status, AddRoomStatus.error);
      expect(viewModel.state.errorMessage, 'Failed to delete room');
      verify(() => mockDeleteRoomUsecase(any<DeleteRoomParams>())).called(1);
    });
  });
}
