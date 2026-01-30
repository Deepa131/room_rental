import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/usecases/register_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/login_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/logout_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:room_rental/features/auth/presentation/pages/register_page.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback123',
        role: 'renter',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
      ],
      child: const MaterialApp(
        home: RegisterPage(userRole: "renter"),
      ),
    );
  }

  group('RegisterPage UI', () {
    testWidgets('displays app title and heading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('RentEasy'), findsOneWidget);
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text('Signup as RENTER'), findsOneWidget);
    });

    testWidgets('displays all input fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('displays Sign Up button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('displays login link', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('RegisterPage Validation', () {
    testWidgets('shows error when full name is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Full name is required'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'Deepa Paudel',
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Deepa Paudel',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'dee@gmail.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'password456',
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('RegisterPage Submission', () {
    testWidgets('calls register usecase with correct params', (tester) async {
      final completer = Completer<Either<Failure, bool>>();

      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Deepa Paudel',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'dee@gmail.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'password123',
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      verify(
        () => mockRegisterUsecase(
          const RegisterUsecaseParams(
            fullName: 'Deepa Paudel',
            email: 'dee@gmail.com',
            password: 'password123',
            role: 'renter',
          ),
        ),
      ).called(1);
    });

    testWidgets('does NOT call register usecase when form is invalid', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      verifyNever(() => mockRegisterUsecase(any()));
    });

    testWidgets('shows loading indicator while registering', (tester) async {
      final completer = Completer<Either<Failure, bool>>();

      when(() => mockRegisterUsecase(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Deepa Paudel',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'dee@gmail.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'password123',
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
