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

  testWidgets('displays different icons correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            icon: Icons.home,
            title: 'Owner',
            subtitle: 'Manage properties',
            color: Colors.green,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('renders with long subtitle text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            icon: Icons.business,
            title: 'Agent',
            subtitle: 'Connect renters with property owners and manage bookings',
            color: Colors.orange,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Connect renters with property owners and manage bookings'), findsOneWidget);
  });

  testWidgets('triggers onTap when tapping anywhere on card', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoleCard(
            icon: Icons.apartment,
            title: 'Manager',
            subtitle: 'Manage multiple properties',
            color: Colors.purple,
            onTap: () => tapCount++,
          ),
        ),
      ),
    );

    // Tap on the icon
    await tester.tap(find.byIcon(Icons.apartment));
    await tester.pump();
    expect(tapCount, 1);

    // Tap on the subtitle
    await tester.tap(find.text('Manage multiple properties'));
    await tester.pump();
    expect(tapCount, 2);
  });
}
