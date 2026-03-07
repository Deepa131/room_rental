import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/add_room/data/models/add_room_hive_model.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';
import 'package:room_rental/features/room_type/data/models/room_type_hive_model.dart';
import 'package:room_rental/features/wishlist/data/models/wishlist_hive_model.dart';
import 'package:room_rental/features/appointment/data/models/appointment_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${AuthHiveConstants.dbName}';

    Hive.init(path);
    _registerAdapters();
    await openBoxes();
    await insertRoomTypeDummyData();
  }

  Future<void> insertRoomTypeDummyData() async {
    final typeBox = Hive.box<RoomTypeHiveModel>(AuthHiveConstants.roomTypeTable);

    if (typeBox.isNotEmpty) {
      return;
    }

    final dummyRoomTypes = [
      RoomTypeHiveModel(typeId: '0', typeName: 'Single room'),
      RoomTypeHiveModel(typeId: '1', typeName: '1 BHK'),
      RoomTypeHiveModel(typeId: '2', typeName: '2 BHK'),
      RoomTypeHiveModel(typeId: '3', typeName: 'Studio room'),
    ];

    for (int i = 0; i < dummyRoomTypes.length; i++) {
      await typeBox.put(i, dummyRoomTypes[i]);
    }
  }

  //register adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(AuthHiveConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AuthHiveConstants.roomTypeId)) {
      Hive.registerAdapter(RoomTypeHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AuthHiveConstants.addRoomTypeId)) {
      Hive.registerAdapter(AddRoomHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AuthHiveConstants.wishlistTypeId)) {
      Hive.registerAdapter(WishlistHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AuthHiveConstants.appointmentTypeId)) {
      Hive.registerAdapter(AppointmentHiveModelAdapter());
    }
  }

  // open boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(AuthHiveConstants.authTable);
    await Hive.openBox<RoomTypeHiveModel>(AuthHiveConstants.roomTypeTable);
    await Hive.openBox<AddRoomHiveModel>(AuthHiveConstants.addRoomTable);
    await Hive.openBox<WishlistHiveModel>(AuthHiveConstants.wishlistTable);
    await Hive.openBox<AppointmentHiveModel>(AuthHiveConstants.appointmentTable);
  }

  //close hive
  Future<void> close() async {
    await Hive.close();
  }

  //Auth box
  Box<AuthHiveModel> get _authBox => 
    Hive.box<AuthHiveModel>(AuthHiveConstants.authTable);
  
  //Register user
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.userId, model);
    return model;
  }

  //Login user
  Future<AuthHiveModel?> login(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  } 

  //get current user
  AuthHiveModel? getCurrentUser(String userId) {
    return _authBox.get(userId);
  }

  //logout
  Future<void> logoutUser() async {}

  //check if email exists
  bool isEmailRegistered(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // room type box
  Box<RoomTypeHiveModel> get _typeBox =>
      Hive.box<RoomTypeHiveModel>(AuthHiveConstants.roomTypeTable);

  Future<RoomTypeHiveModel> createType(RoomTypeHiveModel type) async {
    await _typeBox.put(type.typeId, type);
    return type;
  }

  List<RoomTypeHiveModel> getAllTypes() {
    return _typeBox.values.toList();
  }

  RoomTypeHiveModel? getTypeById(String typeId) {
    return _typeBox.get(typeId);
  }

  Future<bool> updateType(RoomTypeHiveModel type) async {
    await _typeBox.put(type.typeId, type);
    return true;
  }

  Future<void> deleteType(String typeId) async {
    await _typeBox.delete(typeId);
  }

  // add room box
  Box<AddRoomHiveModel> get _roomBox =>
  Hive.box<AddRoomHiveModel>(AuthHiveConstants.addRoomTable);

  Future<AddRoomHiveModel> createRoom(AddRoomHiveModel room) async {
    await _roomBox.put(room.roomId, room);
    return room;
  }

  List<AddRoomHiveModel> getAllRooms() {
    return _roomBox.values.toList();
  }

  AddRoomHiveModel? getRoomById(String roomId) {
    return _roomBox.get(roomId);
  }

  Future<List<AddRoomHiveModel>> getRoomsByOwner(String ownerId) async {
    return _roomBox.values.where((room) => room.ownerId == ownerId).toList();
  }

  Future<bool> updateRoom(AddRoomHiveModel room) async {
    if (_roomBox.containsKey(room.roomId)) {
      await _roomBox.put(room.roomId, room);
      return true;
    }
    return false;
  }

  Future<void> deleteRoom(String roomId) async {
    await _roomBox.delete(roomId);
  }
}
