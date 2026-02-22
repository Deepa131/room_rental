import 'package:dartz/dartz.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

abstract class IAppointmentRepository {
  Future<Either<Failure, AppointmentEntity>> bookAppointment(AppointmentEntity appointment);
  Future<Either<Failure, List<AppointmentEntity>>> getOwnerAppointments(String ownerId);
  Future<Either<Failure, List<AppointmentEntity>>> getRenterAppointments(String renterId);
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String appointmentId);
  Future<Either<Failure, AppointmentEntity>> updateAppointment(String appointmentId, DateTime appointmentDate, String appointmentTime, String message);
  Future<Either<Failure, AppointmentEntity>> updateAppointmentStatus(String appointmentId, String status);
  Future<Either<Failure, bool>> cancelAppointment(String appointmentId);
}
