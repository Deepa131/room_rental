import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:room_rental/core/error/failures.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/domain/usecases/login_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/logout_usecase.dart';
import 'package:room_rental/features/auth/domain/usecases/register_usecase.dart';
import 'package:room_rental/features/auth/presentation/pages/login_page.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock
    implements GetCurrentUserUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUpAll(() {
    registerFallbackValue(
      const LoginUsecaseParams(
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
      ],
      child: const MaterialApp(
        home: LoginPage(userRole: "renter"),
      ),
    );
  }

  group('LoginPage UI', () {
    testWidgets('displays title and role text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('RentEasy'), findsOneWidget);
      expect(find.text('Login as RENTER'), findsOneWidget);
    });

    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email / Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Log In'), findsOneWidget);
    });
  });

  group('LoginPage Validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });
  });

  group('LoginPage Submission', () {
    testWidgets('calls login usecase with correct params', (tester) async {
      final completer =
          Completer<Either<Failure, AuthEntity>>();

      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      await tester.tap(find.text('Log In'));
      await tester.pump();

      verify(() => mockLoginUsecase(
            const LoginUsecaseParams(
              email: 'user@test.com',
              password: 'password123',
            ),
          )).called(1);
    });

    testWidgets('does NOT call login when form is invalid', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Log In'));
      await tester.pump();

      verifyNever(() => mockLoginUsecase(any()));
    });

    testWidgets('shows loading indicator while logging in', (tester) async {
      final completer =
          Completer<Either<Failure, AuthEntity>>();

      when(() => mockLoginUsecase(any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'user@test.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}