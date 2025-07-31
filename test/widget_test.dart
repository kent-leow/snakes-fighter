// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:snakes_fight/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SnakesFightApp());

    // Verify that the welcome text is displayed.
    expect(find.text('Welcome to Snakes Fight!'), findsOneWidget);
    expect(find.text('A multiplayer Snake game'), findsOneWidget);

    // Verify that the app bar title is correct.
    expect(find.text('Snakes Fight'), findsOneWidget);
  });
}
