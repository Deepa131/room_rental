import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

enum AppointmentStatus { initial, loading, success, error }

class AppointmentState {
  final AppointmentStatus status;
  final List<AppointmentEntity> appointments;
  final AppointmentEntity? currentAppointment;
  final String? error;

  const AppointmentState({
    this.status = AppointmentStatus.initial,
    this.appointments = const [],
    this.currentAppointment,
    this.error,
  });

  AppointmentState copyWith({
    AppointmentStatus? status,
    List<AppointmentEntity>? appointments,
    AppointmentEntity? currentAppointment,
    String? error,
  }) {
    return AppointmentState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      currentAppointment: currentAppointment ?? this.currentAppointment,
      error: error ?? this.error,
    );
  }
}
