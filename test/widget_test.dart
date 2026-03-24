import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:move_smart/providers/app_providers.dart';

void main() {
  // Helper to get a fresh provider container each test
  ProviderContainer make() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  group('Nav index', () {
    test('starts at 0', () {
      expect(make().read(navIndexProvider), 0);
    });

    test('setIndex changes tab', () {
      final c = make();
      c.read(navIndexProvider.notifier).setIndex(2);
      expect(c.read(navIndexProvider), 2);
    });
  });

  group('Search query', () {
    test('starts empty', () {
      expect(make().read(searchQueryProvider), '');
    });

    test('setQuery saves text', () {
      final c = make();
      c.read(searchQueryProvider.notifier).setQuery('Remera');
      expect(c.read(searchQueryProvider), 'Remera');
    });

    test('clear resets to empty', () {
      final c = make();
      c.read(searchQueryProvider.notifier).setQuery('Kimironko');
      c.read(searchQueryProvider.notifier).clear();
      expect(c.read(searchQueryProvider), '');
    });
  });

  group('Bottom nav bar', () {
    // Build a simple nav bar widget for testing
    Widget navBar({void Function(int)? onTap}) => MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTap,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'My Trips'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
          ),
        );

    testWidgets('shows all 4 tabs', (t) async {
      await t.pumpWidget(navBar());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('My Trips'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping Search fires index 1', (t) async {
      int tapped = -1;
      await t.pumpWidget(navBar(onTap: (i) => tapped = i));
      await t.tap(find.text('Search'));
      expect(tapped, 1);
    });
  });
}
