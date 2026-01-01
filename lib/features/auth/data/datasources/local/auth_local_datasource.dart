import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/services/hive/hive_service.dart';
import 'package:room_rental/features/auth/data/datasources/auth_datasource.dart';
import 'package:room_rental/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel model) async{
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async{
    try {
      final user = await _hiveService.loginUser(email, password);
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async{}

  @override
  Future<bool> logout() async{
    try {
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async{
    try {
      return _hiveService.isEmailRegistered(email);
    } catch (_) {
      return false;
    }
  }
}