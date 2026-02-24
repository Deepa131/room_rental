import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/widgets/my_textformfield.dart';

void main() {
  testWidgets('shows label and hint text', (tester) async {
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

  testWidgets('shows error message when empty', (tester) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                MyTextformfield(
                  controller: controller,
                  labelText: 'Email',
                  hintText: 'example@gmail.com',
                  errorMessage: 'Email is required',
                ),
                TextButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('uses custom validator when provided', (tester) async {
    final controller = TextEditingController(text: 'bad');
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                MyTextformfield(
                  controller: controller,
                  labelText: 'Username',
                  hintText: 'user',
                  validator: (value) => value == 'bad' ? 'Custom error' : null,
                ),
                TextButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Custom error'), findsOneWidget);
  });

  testWidgets('honors obscureText', (tester) async {
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
}
