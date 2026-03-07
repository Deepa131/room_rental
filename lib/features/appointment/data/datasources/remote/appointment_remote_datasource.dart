import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/api/api_client.dart';
import 'package:room_rental/core/api/api_endpoints.dart';
import 'package:room_rental/features/appointment/data/models/appointment_api_model.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AppointmentRemoteDataSource(apiClient);
});

class AppointmentRemoteDataSource {
  final ApiClient _apiClient;

  AppointmentRemoteDataSource(this._apiClient);

  String _toUtcDateOnly(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }

  Future<AppointmentApiModel> bookAppointment(AppointmentEntity appointment) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.bookAppointment,
        data: {
          'roomId': appointment.roomId,
          'ownerId': appointment.ownerId,
          'renterId': appointment.renterId,
          'renterName': appointment.renterName,
          'renterEmail': appointment.renterEmail,
          'renterPhone': appointment.renterPhone,
          'appointmentDate': _toUtcDateOnly(appointment.appointmentDate),
          'appointmentTime': appointment.appointmentTime,
          'message': appointment.message ?? '',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AppointmentApiModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to book appointment');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<AppointmentApiModel>> getOwnerAppointments(String ownerId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getOwnerAppointments(ownerId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => AppointmentApiModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch appointments');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<AppointmentApiModel>> getRenterAppointments(String renterId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getRenterAppointments(renterId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => AppointmentApiModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch appointments');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AppointmentApiModel> getAppointmentById(String appointmentId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getAppointmentById(appointmentId),
      );

      if (response.statusCode == 200) {
        return AppointmentApiModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch appointment');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AppointmentApiModel> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateAppointmentStatus(appointmentId),
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return AppointmentApiModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to update appointment');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.cancelAppointment(appointmentId),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AppointmentApiModel> updateAppointment(
    String appointmentId,
    DateTime appointmentDate,
    String appointmentTime,
    String message,
  ) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateAppointment(appointmentId),
        data: {
          'appointmentDate': _toUtcDateOnly(appointmentDate),
          'appointmentTime': appointmentTime,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        return AppointmentApiModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to update appointment');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
