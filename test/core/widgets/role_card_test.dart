import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:room_rental/core/widgets/role_card.dart';

void main() {
  testWidgets('shows title, subtitle, and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            icon: Icons.person,
            title: 'Renter',
            subtitle: 'Find rooms to rent',
            color: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Renter'), findsOneWidget);
    expect(find.text('Find rooms to rent'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('triggers onTap when pressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            icon: Icons.person,
            title: 'Owner',
            subtitle: 'List your rooms',
            color: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Owner'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
