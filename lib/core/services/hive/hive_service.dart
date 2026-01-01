import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';

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
  }

  //register adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(AuthHiveConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // open boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(AuthHiveConstants.authTable);
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
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    try {
      final users = _authBox.values.where(
      (user) => 
        user.email.trim() == email.trim() && user.password == password,
      );
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    } catch (_) {
      return null;
    }
  } 

  //get current user
  AuthHiveModel? getCurrentUser(String userId) {
    return _authBox.get(userId);
  }

  //logout
  Future<void> logoutUser(String userId) async {}

  //check if email exists
  bool isEmailRegistered(String email) {
    return _authBox.values.any(
      (user) => user.email.trim() == email.trim(),
    );
  }
}
