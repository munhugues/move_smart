import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_smart/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MoveSmart());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
