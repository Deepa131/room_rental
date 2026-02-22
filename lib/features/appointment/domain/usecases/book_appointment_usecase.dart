import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/data/repositories/appointment_repository.dart';
import 'package:room_rental/features/appointment/domain/repositories/appointment_repository.dart';

final bookAppointmentUsecaseProvider = Provider<BookAppointmentUsecase>((ref) {
  return BookAppointmentUsecase(ref.read(appointmentRepositoryProvider));
});

class BookAppointmentUsecase {
  final IAppointmentRepository repository;

  BookAppointmentUsecase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call(AppointmentEntity appointment) async {
    return await repository.bookAppointment(appointment);
  }
}
