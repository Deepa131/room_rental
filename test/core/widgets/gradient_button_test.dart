import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/widgets/gradient_button.dart';

void main() {
  testWidgets('shows text and triggers tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('shows loading indicator when isLoading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Continue',
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows icon when provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Pay',
            icon: const Icon(Icons.payment, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.payment), findsOneWidget);
  });

  testWidgets('does not trigger tap when loading', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientButton(
            text: 'Continue',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
