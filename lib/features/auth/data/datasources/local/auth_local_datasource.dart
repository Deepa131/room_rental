import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/hive/hive_service.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/auth/data/datasources/auth_datasource.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService, 
    required userSessionService,
  })
    : _hiveService = hiveService,
      _userSessionService = userSessionService;

  @override
  Future<bool> register(AuthHiveModel model) async{
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async{
    try {
      final user = await _hiveService.login(email, password);
      // save user details in shared prefs
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userId, 
          fullName: user.fullName, 
          email: email,
          role: user.role,
          profileImage: user.profilePicture ?? '',
        );
      }
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() async{
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> isEmailExists(String email) async{
    try {
      final exists = _hiveService.isEmailRegistered(email);
      return Future.value(exists);
    } catch (_) {
      return Future.value(false);
    }
  }
  
  @override
  Future<AuthHiveModel?> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }
  
  @override
  Future<AuthHiveModel> getUserById(String userId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }
}