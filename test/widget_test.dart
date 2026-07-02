// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_gp_schedule/app.dart';

import 'package:moto_gp_schedule/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Wait for async operations to complete (loading schedule)
    await tester.pumpAndSettle();

    // Verify that the app title is displayed.
    expect(find.text('Moto GP Schedule'), findsOneWidget);

    // Verify that the "No events available" message is shown initially.
    expect(find.text('No events available'), findsOneWidget);
  });
}
