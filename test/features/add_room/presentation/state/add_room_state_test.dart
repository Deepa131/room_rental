import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import '../../../../test_utils.dart';

void main() {
  test('copyWith updates status', () {
    const state = AddRoomState();
    final updated = state.copyWith(status: AddRoomStatus.loading);
    expect(updated.status, AddRoomStatus.loading);
  });

  test('copyWith updates rooms list', () {
    final room = makeRoom(roomId: '1');
    const state = AddRoomState();
    final updated = state.copyWith(rooms: [room]);
    expect(updated.rooms.length, 1);
    expect(updated.rooms.first.roomId, '1');
  });

  test('copyWith can reset selectedRoom', () {
    final room = makeRoom(roomId: '1');
    final state = AddRoomState(selectedRoom: room);
    final updated = state.copyWith(resetSelectedRoom: true);
    expect(updated.selectedRoom, isNull);
  });

  test('copyWith can reset errorMessage', () {
    const state = AddRoomState(errorMessage: 'Error');
    final updated = state.copyWith(resetErrorMessage: true);
    expect(updated.errorMessage, isNull);
  });

  test('copyWith can reset uploadedImageUrl', () {
    const state = AddRoomState(uploadedImageUrl: 'url');
    final updated = state.copyWith(resetUploadedImageUrl: true);
    expect(updated.uploadedImageUrl, isNull);
  });

  test('copyWith can reset uploadedVideoUrl', () {
    const state = AddRoomState(uploadedVideoUrl: 'url');
    final updated = state.copyWith(resetUploadedVideoUrl: true);
    expect(updated.uploadedVideoUrl, isNull);
  });
}
