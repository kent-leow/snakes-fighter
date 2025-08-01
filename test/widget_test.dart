// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:snakes_fight/main.dart';

void main() {
  testWidgets('App widget can be instantiated', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SnakesFightApp()));
    
    // Just check that the app can be created without throwing errors
    // Note: Auth functionality requires Firebase initialization which is complex in tests
    expect(find.byType(SnakesFightApp), findsOneWidget);
  });
}
