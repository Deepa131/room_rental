import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/services/storage/biometric_auth_service.dart';
import 'package:room_rental/features/auth/presentation/pages/login_page.dart';
import 'package:room_rental/features/auth/presentation/pages/register_page.dart';
import 'package:room_rental/features/auth/presentation/state/auth_state.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';

class _FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState();

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {}
}

class _FakeBiometricAuthService extends BiometricAuthService {
  @override
  Future<bool> hasAnyBiometricUser() async => false;
}

void main() {
  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
        biometricAuthServiceProvider.overrideWithValue(_FakeBiometricAuthService()),
      ],
      child: const MaterialApp(
        home: LoginPage(userRole: 'owner'),
      ),
    );
  }

  testWidgets('renders login title and subtitle', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('RentEasy'), findsOneWidget);
    expect(find.text('Welcome back, owner'), findsOneWidget);
  });

  testWidgets('renders login form fields', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('shows Log In action text', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('does not show fingerprint login when no biometric user exists',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.text('Fingerprint Login'), findsNothing);
    expect(find.byIcon(Icons.fingerprint_rounded), findsNothing);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    var passwordField = tester.widget<EditableText>(find.byType(EditableText).at(1));
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_rounded));
    await tester.pump();

    passwordField = tester.widget<EditableText>(find.byType(EditableText).at(1));
    expect(passwordField.obscureText, isFalse);
  });

  testWidgets('navigates to register page from create account', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsOneWidget);
  });
}
