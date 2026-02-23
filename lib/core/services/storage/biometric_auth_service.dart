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

  // Check if the device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are available (enrolled)
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      print('🔐 Starting biometric authentication...');
      
      final isSupported = await isDeviceSupported();
      print('📱 Device supported: $isSupported');
      if (!isSupported) {
        print('❌ Device does not support biometrics');
        return false;
      }

      final canCheck = await canCheckBiometrics();
      print('👆 Can check biometrics: $canCheck');
      if (!canCheck) {
        print('❌ No biometrics available on device');
        return false;
      }

      final availableBiometrics = await getAvailableBiometrics();
      print('📋 Available biometrics: $availableBiometrics');

      print('🔄 Asking user to scan fingerprint...');
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      print('✅ Biometric authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      print('❌ Biometric authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ Unexpected error during biometric authentication: $e');
      return false;
    }
  }

  /// Enable biometric authentication for the user
  Future<bool> enableBiometric(String userId, String email, String password) async {
    try {
      // Check if biometrics are available
      final canCheck = await canCheckBiometrics();
      print('Can check biometrics: $canCheck');
      
      if (!canCheck) {
        // Check if device is supported but no biometrics enrolled
        final isSupported = await isDeviceSupported();
        print('Device supported: $isSupported');
        
        if (!isSupported) {
          print('Device does not support biometric authentication');
        } else {
          print('No biometrics enrolled on device. Please set up fingerprint in your device settings.');
        }
        return false;
      }

      // Get available biometric types
      final availableBiometrics = await getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');

      // Store the credentials securely
      final credentials = '$email:$password';
      await _secureStorage.write(
        key: '${_userCredentialsKey}_$userId',
        value: credentials,
      );

      // Set biometric enabled flag
      await _secureStorage.write(
        key: '${_biometricEnabledKey}_$userId',
        value: 'true',
      );

      print('Biometric enabled successfully for user $userId');
      return true;
    } catch (e) {
      print('Error enabling biometric: $e');
      return false;
    }
  }

  /// Check if biometric is enabled for a user
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

  /// Check if any user has biometric enabled
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

  /// Get stored credentials after biometric authentication
  Future<Map<String, String>?> getBiometricCredentials(String userId) async {
    try {
      // Authenticate first
      final authenticated = await authenticate(
        reason: 'Authenticate to login',
      );

      if (!authenticated) return null;

      // Get stored credentials
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
      print('Error getting biometric credentials: $e');
      return null;
    }
  }

  /// Get the last user who had biometric enabled
  Future<String?> getLastBiometricUserId() async {
    try {
      return await _secureStorage.read(key: 'last_biometric_user_id');
    } catch (e) {
      return null;
    }
  }

  /// Set the last user who had biometric enabled
  Future<void> setLastBiometricUserId(String userId) async {
    try {
      await _secureStorage.write(
        key: 'last_biometric_user_id',
        value: userId,
      );
    } catch (e) {
      print('Error setting last biometric user: $e');
    }
  }

  /// Disable biometric authentication for a user
  Future<void> disableBiometric(String userId) async {
    try {
      await _secureStorage.delete(key: '${_biometricEnabledKey}_$userId');
      await _secureStorage.delete(key: '${_userCredentialsKey}_$userId');
    } catch (e) {
      print('Error disabling biometric: $e');
    }
  }

  /// Clear all biometric data
  Future<void> clearAllBiometricData() async {
    try {
      final allKeys = await _secureStorage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith(_biometricEnabledKey) || 
            key.startsWith(_userCredentialsKey) ||
            key == 'last_biometric_user_id') {
          await _secureStorage.delete(key: key);
        }
      }
    } catch (e) {
      print('Error clearing biometric data: $e');
    }
  }
}
