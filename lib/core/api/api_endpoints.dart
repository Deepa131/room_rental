import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:3000/api/v1';
    }
    //yedi android
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://10.0.2.2:3000/api/v1';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String users = '/users';
  static const String userLogin = '/users/login';
  static const String userRegister = '/users/register';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => 'users/$id/photo';
}