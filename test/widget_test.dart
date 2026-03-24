import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:move_smart/core/services/prefs_service.dart';
import 'package:move_smart/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.instance.init();

    await tester.pumpWidget(const MoveSmart(firebaseReady: false));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
