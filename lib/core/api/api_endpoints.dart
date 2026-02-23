import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = true;  // make port 5050

  static const String compIpAddress = "192.168.18.95";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }
    //yedi android
    if (kIsWeb) {
      return 'http://localhost:5050/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/';
    } else {
      return 'http://10.0.2.2:5050/api/';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String auth = '/auth';
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) => '/auth/reset-password/$token';
  static String userById(String id) => '/auth/$id';
  static String updateProfile(String id) => '/auth/$id';
  static const String updateProfilePicture = '/auth/profile-picture';

  // Room Type endpoints
  static const String types = '/room-types';
  static String typeById(String id) => '/room-types/$id';

  // Room endpoints
  static const String rooms = '/rooms';
  static String roomById(String id) => '/rooms/$id';
  static String roomsByOwner(String ownerId) => '/rooms/owner/$ownerId';
  static String updateRoom(String id) => '/rooms/$id';
  static String deleteRoom(String id) => '/rooms/$id';
  static const String uploadRoomImage = '/rooms/upload-image';
  static const String uploadRoomVideo = '/rooms/upload-video';

  // Appointment endpoints
  static const String bookAppointment = '/appointments/book';
  static String getOwnerAppointments(String ownerId) => '/appointments/owner/$ownerId';
  static String getRenterAppointments(String renterId) => '/appointments/renter/$renterId';
  static String getAppointmentById(String appointmentId) => '/appointments/$appointmentId';
  static String updateAppointment(String appointmentId) => '/appointments/$appointmentId';
  static String updateAppointmentStatus(String appointmentId) => '/appointments/$appointmentId/status';
  static String cancelAppointment(String appointmentId) => '/appointments/$appointmentId';
}