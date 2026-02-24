import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import '../../../../test_utils.dart';

void main() {
  test('copyWith updates selectedType', () {
    const state = RoomTypeState();
    final type = makeRoomType(typeId: 't1');
    final updated = state.copyWith(selectedType: type);
    expect(updated.selectedType?.typeId, 't1');
  });

  test('copyWith updates status and types', () {
    const state = RoomTypeState();
    final updated = state.copyWith(
      status: RoomTypeStatus.loaded,
      types: [makeRoomType(typeId: 't1')],
    );
    expect(updated.status, RoomTypeStatus.loaded);
    expect(updated.types.length, 1);
  });

  test('props equality works', () {
    final a = RoomTypeState(types: [makeRoomType(typeId: 't1')]);
    final b = RoomTypeState(types: [makeRoomType(typeId: 't1')]);
    expect(a, equals(b));
  });
}
