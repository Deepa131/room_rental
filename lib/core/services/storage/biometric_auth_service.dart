import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userCredentialsKey = 'user_credentials';

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return result;
    } on PlatformException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> enableBiometric(String userId, String email, String password) async {
    try {
      final canCheck = await canCheckBiometrics();
      
      if (!canCheck) {
        final isSupported = await isDeviceSupported();

        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();

      final credentials = '$email:$password';
      await _secureStorage.write(
        key: '${_userCredentialsKey}_$userId',
        value: credentials,
      );

      await _secureStorage.write(
        key: '${_biometricEnabledKey}_$userId',
        value: 'true',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final value = await _secureStorage.read(
        key: '${_biometricEnabledKey}_$userId',
      );
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasAnyBiometricUser() async {
    try {
      final allKeys = await _secureStorage.readAll();
      return allKeys.keys.any((key) => 
        key.startsWith(_biometricEnabledKey) && allKeys[key] == 'true'
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>?> getBiometricCredentials(String userId) async {
    try {
      final authenticated = await authenticate(
        reason: 'Authenticate to login',
      );

      if (!authenticated) return null;

      final credentials = await _secureStorage.read(
        key: '${_userCredentialsKey}_$userId',
      );

      if (credentials == null) return null;

      final parts = credentials.split(':');
      if (parts.length != 2) return null;

      return {
        'email': parts[0],
        'password': parts[1],
      };
    } catch (e) {
      return null;
    }
  }

  Future<String?> getLastBiometricUserId() async {
    try {
      return await _secureStorage.read(key: 'last_biometric_user_id');
    } catch (e) {
      return null;
    }
  }

  Future<void> setLastBiometricUserId(String userId) async {
    await _secureStorage.write(
      key: 'last_biometric_user_id',
      value: userId,
    );
  }

  Future<void> disableBiometric(String userId) async {
    await _secureStorage.delete(key: '${_biometricEnabledKey}_$userId');
    await _secureStorage.delete(key: '${_userCredentialsKey}_$userId'); 
  }

  Future<void> clearAllBiometricData() async {
    final allKeys = await _secureStorage.readAll();
    for (final key in allKeys.keys) {
      if (key.startsWith(_biometricEnabledKey) || 
      key.startsWith(_userCredentialsKey) ||
      key == 'last_biometric_user_id') {
        await _secureStorage.delete(key: key);
      }
    }
  }
}
