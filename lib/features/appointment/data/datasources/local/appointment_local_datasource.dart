import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:room_rental/core/constants/auth_hive_constants.dart';
import 'package:room_rental/features/appointment/data/models/appointment_hive_model.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

final appointmentLocalDataSourceProvider = Provider<AppointmentLocalDataSource>((ref) {
  return AppointmentLocalDataSource();
});

class AppointmentLocalDataSource {
  Future<Box<AppointmentHiveModel>> get _appointmentBox async {
    if (Hive.isBoxOpen(AuthHiveConstants.appointmentTable)) {
      return Hive.box<AppointmentHiveModel>(AuthHiveConstants.appointmentTable);
    }
    return await Hive.openBox<AppointmentHiveModel>(AuthHiveConstants.appointmentTable);
  }

  Future<AppointmentHiveModel?> saveAppointment(AppointmentEntity appointment) async {
    try {
      final box = await _appointmentBox;
      final hiveModel = AppointmentHiveModel.fromEntity(appointment);
      await box.put(appointment.appointmentId ?? DateTime.now().toString(), hiveModel);
      return hiveModel;
    } catch (e) {
      throw Exception('Failed to save appointment locally: $e');
    }
  }

  Future<List<AppointmentHiveModel>> getMyAppointments(String renterId) async {
    try {
      final box = await _appointmentBox;
      final appointments = box.values
          .where((apt) => apt.renterId == renterId)
          .toList();
      return appointments;
    } catch (e) {
      throw Exception('Failed to fetch appointments locally: $e');
    }
  }

  Future<List<AppointmentHiveModel>> getOwnerAppointments(String ownerId) async {
    try {
      final box = await _appointmentBox;
      final appointments = box.values
          .where((apt) => apt.ownerId == ownerId)
          .toList();
      return appointments;
    } catch (e) {
      throw Exception('Failed to fetch appointments locally: $e');
    }
  }

  Future<AppointmentHiveModel?> getAppointmentById(String appointmentId) async {
    try {
      final box = await _appointmentBox;
      return box.get(appointmentId);
    } catch (e) {
      throw Exception('Failed to fetch appointment locally: $e');
    }
  }

  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final box = await _appointmentBox;
      await box.delete(appointmentId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete appointment locally: $e');
    }
  }

  Future<void> clearAppointments() async {
    try {
      final box = await _appointmentBox;
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear appointments: $e');
    }
  }
}
