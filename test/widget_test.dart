import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(showOnboarding: false),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
