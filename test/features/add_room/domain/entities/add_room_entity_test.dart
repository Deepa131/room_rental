import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import '../../../../test_utils.dart';

void main() {
  test('LocationCoordsEntity supports equality', () {
    const a = LocationCoordsEntity(latitude: 27.7, longitude: 85.3);
    const b = LocationCoordsEntity(latitude: 27.7, longitude: 85.3);
    expect(a, equals(b));
  });

  test('AddRoomEntity supports equality', () {
    final a = makeRoom(roomId: '1');
    final b = makeRoom(roomId: '1');
    expect(a, equals(b));
  });

  test('AddRoomEntity distinguishes different rooms', () {
    final a = makeRoom(roomId: '1');
    final b = makeRoom(roomId: '2');
    expect(a == b, isFalse);
  });
}
