import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;  // make port 5050

  static const String compIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }
    //yedi android
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';
    } else {
      return 'http://10.0.2.2:5050/api';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String users = '/users';
  static const String userLogin = '/users/login';
  static const String userRegister = '/users/register';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => 'users/$id/photo';

  static const String types = '/roomTypes';
  static String typeById(String id) => '/roomTypes/$id';

  static const String rooms = '/rooms';
  static String roomById(String id) => '/rooms/$id';
  static const String uploadRoomImage = '/rooms/upload-image';
  static const String uploadRoomVideo = '/rooms/upload-video';

}