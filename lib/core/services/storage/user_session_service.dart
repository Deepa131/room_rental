import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Shared prefs provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    "Initialize shared pref in main.dart",
  );
});

//provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  //Keys for storing data
  static const String _keysIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserProfileImage = 'user_profile_image';

  //Store user session data
  Future<void> saveUserSession({
    required String userId,
    required String fullName,
    required String email,
    required String role,
    String? profileImage,
  }) async {
    await _prefs.setBool(_keysIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserRole, role);
    if (profileImage != null) {
      await _prefs.setString(_keyUserProfileImage, profileImage);
    }
  }

  //Clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keysIsLoggedIn);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserProfileImage);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keysIsLoggedIn) ?? false;
  }

  String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  String? getUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  String? getUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  String? getUserProfileImage() {
    return _prefs.getString(_keyUserProfileImage);
  }

  getCurrentUserId() {}
}
