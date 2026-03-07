import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'package:room_rental/features/appointment/data/repositories/appointment_repository.dart';
import 'package:room_rental/features/appointment/presentation/state/appointment_state.dart';

final appointmentViewModelProvider =
    NotifierProvider<AppointmentViewModel, AppointmentState>(AppointmentViewModel.new);

class AppointmentViewModel extends Notifier<AppointmentState> {
  late final BookAppointmentUsecase _bookAppointmentUsecase;

  @override
  AppointmentState build() {
    _bookAppointmentUsecase = ref.read(bookAppointmentUsecaseProvider);
    return const AppointmentState();
  }

  Future<bool> bookAppointment(AppointmentEntity appointment) async {
    state = state.copyWith(status: AppointmentStatus.loading);

    final result = await _bookAppointmentUsecase(appointment);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AppointmentStatus.error,
          error: failure.message,
        );
        return false;
      },
      (appointmentEntity) {
        final updatedAppointments = [...state.appointments, appointmentEntity];
        state = state.copyWith(
          status: AppointmentStatus.success,
          appointments: updatedAppointments,
          currentAppointment: appointmentEntity,
          error: null,
        );
        return true;
      },
    );
  }

  Future<void> getMyAppointments(String renterId) async {
    state = state.copyWith(status: AppointmentStatus.loading);

    final repo = ref.read(appointmentRepositoryProvider);
    final result = await repo.getRenterAppointments(renterId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AppointmentStatus.error,
          error: failure.message,
        );
      },
      (appointments) {
        state = state.copyWith(
          status: AppointmentStatus.success,
          appointments: appointments,
          error: null,
        );
      },
    );
  }

  Future<void> getOwnerAppointments(String ownerId) async {
    state = state.copyWith(status: AppointmentStatus.loading);

    final repo = ref.read(appointmentRepositoryProvider);
    final result = await repo.getOwnerAppointments(ownerId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AppointmentStatus.error,
          error: failure.message,
        );
      },
      (appointments) {
        state = state.copyWith(
          status: AppointmentStatus.success,
          appointments: appointments,
          error: null,
        );
      },
    );
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    final repo = ref.read(appointmentRepositoryProvider);
    final result = await repo.cancelAppointment(appointmentId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) {
        final updatedAppointments = state.appointments
            .where((apt) => apt.appointmentId != appointmentId)
            .toList();
        state = state.copyWith(
          appointments: updatedAppointments,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateAppointment(
    String appointmentId,
    DateTime appointmentDate,
    String appointmentTime,
    String message,
  ) async {
    state = state.copyWith(status: AppointmentStatus.loading);

    final repo = ref.read(appointmentRepositoryProvider);
    final result = await repo.updateAppointment(
      appointmentId,
      appointmentDate,
      appointmentTime,
      message,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AppointmentStatus.error,
          error: failure.message,
        );
        return false;
      },
      (updatedAppointment) {
        final updatedAppointments = state.appointments.map((apt) {
          if (apt.appointmentId == appointmentId) {
            return apt.copyWith(
              appointmentDate: updatedAppointment.appointmentDate,
              appointmentTime: updatedAppointment.appointmentTime,
              message: updatedAppointment.message,
              status: updatedAppointment.status,
              updatedAt: updatedAppointment.updatedAt ?? apt.updatedAt,
              room: updatedAppointment.room ?? apt.room,
            );
          }
          return apt;
        }).toList();

        state = state.copyWith(
          status: AppointmentStatus.success,
          appointments: updatedAppointments,
          currentAppointment: updatedAppointment,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    state = state.copyWith(status: AppointmentStatus.loading);

    final repo = ref.read(appointmentRepositoryProvider);
    final result = await repo.updateAppointmentStatus(appointmentId, status);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AppointmentStatus.error,
          error: failure.message,
        );
        return false;
      },
      (updatedAppointment) {
        final updatedAppointments = state.appointments.map((apt) {
          if (apt.appointmentId == appointmentId) {
            return apt.copyWith(
              status: updatedAppointment.status,
              updatedAt: updatedAppointment.updatedAt ?? apt.updatedAt,
            );
          }
          return apt;
        }).toList();

        state = state.copyWith(
          status: AppointmentStatus.success,
          appointments: updatedAppointments,
          currentAppointment: updatedAppointment,
          error: null,
        );
        return true;
      },
    );
  }
}
