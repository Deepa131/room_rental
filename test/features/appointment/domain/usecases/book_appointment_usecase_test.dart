import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:room_rental/features/appointment/domain/usecases/book_appointment_usecase.dart';

class MockAppointmentRepository extends Mock implements IAppointmentRepository {}

void main() {
  late BookAppointmentUsecase usecase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    usecase = BookAppointmentUsecase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(AppointmentEntity(
      roomId: 'room1',
      ownerId: 'owner1',
      renterId: 'renter1',
      renterName: 'Test Renter',
      renterEmail: 'test@test.com',
      renterPhone: '9800000000',
      appointmentDate: DateTime(2024, 6, 15),
      appointmentTime: '10:00 AM',
      status: 'pending',
    ));
  });

  final tAppointmentDate = DateTime(2024, 6, 15);
  const tAppointmentTime = '10:00 AM';

  final tAppointment = AppointmentEntity(
    roomId: 'room123',
    ownerId: 'owner123',
    renterId: 'renter123',
    renterName: 'John Doe',
    renterEmail: 'john@example.com',
    renterPhone: '9800000000',
    appointmentDate: tAppointmentDate,
    appointmentTime: tAppointmentTime,
    status: 'pending',
  );

  final tBookedAppointment = AppointmentEntity(
    appointmentId: 'appointment123',
    roomId: 'room123',
    ownerId: 'owner123',
    renterId: 'renter123',
    renterName: 'John Doe',
    renterEmail: 'john@example.com',
    renterPhone: '9800000000',
    appointmentDate: tAppointmentDate,
    appointmentTime: tAppointmentTime,
    status: 'pending',
  );

  group('BookAppointmentUsecase', () {
    test('should book appointment successfully and return appointment entity', () async {
      when(() => mockRepository.bookAppointment(any()))
          .thenAnswer((_) async => Right(tBookedAppointment));

      final result = await usecase(tAppointment);

      expect(result, Right(tBookedAppointment));
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (appointment) {
          expect(appointment.appointmentId, 'appointment123');
          expect(appointment.status, 'pending');
        },
      );
      verify(() => mockRepository.bookAppointment(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when appointment booking fails', () async {
      const failure = ApiFailure(message: 'Failed to book appointment', statusCode: 400);
      when(() => mockRepository.bookAppointment(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tAppointment);

      expect(result, const Left(failure));
      verify(() => mockRepository.bookAppointment(any())).called(1);
    });

    test('should return ApiFailure for invalid appointment data', () async {
      const failure = ApiFailure(message: 'Invalid appointment date', statusCode: 400);
      when(() => mockRepository.bookAppointment(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tAppointment);

      expect(result, const Left(failure));
      verify(() => mockRepository.bookAppointment(any())).called(1);
    });

    test('should return ApiFailure when time slot already booked', () async {
      const failure = ApiFailure(message: 'Time slot already booked', statusCode: 409);
      when(() => mockRepository.bookAppointment(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await usecase(tAppointment);

      expect(result, const Left(failure));
      verify(() => mockRepository.bookAppointment(any())).called(1);
    });
  });
}
