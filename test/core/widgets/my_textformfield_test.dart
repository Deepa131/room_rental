import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/widgets/my_textformfield.dart';

void main() {
  testWidgets('renders label and hint text', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextformfield(
            controller: controller,
            labelText: 'Email',
            hintText: 'example@gmail.com',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('example@gmail.com'), findsOneWidget);
  });

  testWidgets('honors obscureText property', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextformfield(
            controller: controller,
            labelText: 'Password',
            hintText: 'password',
            obscureText: true,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
  });

  testWidgets('validates empty input with error message', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MyTextformfield(
              controller: controller,
              labelText: 'Username',
              hintText: 'Enter username',
              errorMessage: 'Username is required',
            ),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Username is required'), findsOneWidget);
  });

  testWidgets('accepts text input', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextformfield(
            controller: controller,
            labelText: 'Name',
            hintText: 'Enter name',
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'John Doe');
    expect(controller.text, 'John Doe');
  });

  testWidgets('displays prefix icon when provided', (tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MyTextformfield(
            controller: controller,
            labelText: 'Email',
            hintText: 'Enter email',
            prefixIcon: Icons.email,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.email), findsOneWidget);
  });
}
