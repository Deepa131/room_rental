import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/domain/usecases/book_appointment_usecase.dart';
import 'package:room_rental/features/appointment/presentation/state/appointment_state.dart';
import 'package:room_rental/features/appointment/presentation/view_model/appointment_viewmodel.dart';

class MockBookAppointmentUsecase extends Mock implements BookAppointmentUsecase {}

void main() {
  late ProviderContainer container;
  late MockBookAppointmentUsecase mockBookAppointmentUsecase;

  setUp(() {
    mockBookAppointmentUsecase = MockBookAppointmentUsecase();

    container = ProviderContainer(
      overrides: [
        bookAppointmentUsecaseProvider.overrideWithValue(mockBookAppointmentUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
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

  group('AppointmentViewModel - BookAppointment', () {
    test('should book appointment successfully', () async {
      when(() => mockBookAppointmentUsecase(any()))
          .thenAnswer((_) async => Right(tAppointment));

      final viewModel = container.read(appointmentViewModelProvider.notifier);

      final result = await viewModel.bookAppointment(tAppointment);

      expect(result, true);
      expect(viewModel.state.status, AppointmentStatus.success);
      verify(() => mockBookAppointmentUsecase(any())).called(1);
    });

    test('should handle booking failure', () async {
      const failure = ApiFailure(message: 'Failed to book appointment', statusCode: 400);
      when(() => mockBookAppointmentUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(appointmentViewModelProvider.notifier);

      final result = await viewModel.bookAppointment(tAppointment);

      expect(result, false);
      expect(viewModel.state.status, AppointmentStatus.error);
      verify(() => mockBookAppointmentUsecase(any())).called(1);
    });
  });
}
