import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  Future<void> pumpRegisterPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() async => tester.binding.setSurfaceSize(null));

    final app = ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
      ],
      child: const MaterialApp(
        home: RegisterPage(userRole: 'renter'),
      ),
    );

    await tester.pumpWidget(app);
    await tester.pump();
  }

  testWidgets('renders register title and subtitle', (tester) async {
    await pumpRegisterPage(tester);

    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.text('Sign up as renter'), findsOneWidget);
  });

  testWidgets('renders all register form fields', (tester) async {
    await pumpRegisterPage(tester);

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('shows password mismatch validation', (tester) async {
    await pumpRegisterPage(tester);

    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(find.byType(TextFormField).at(3), 'password2');

    await tester.tap(find.text('Create Account').last);
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('toggles password visibility icon on tap', (tester) async {
    await pumpRegisterPage(tester);

    expect(find.byIcon(Icons.visibility_off_rounded), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.visibility_off_rounded).first);
    await tester.pump();

    expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
  });

  testWidgets('navigates back to login page', (tester) async {
    await pumpRegisterPage(tester);

    await tester.ensureVisible(find.text('Back to Login'));
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
