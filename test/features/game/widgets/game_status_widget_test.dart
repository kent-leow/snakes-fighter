import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/widgets/game_status_widget.dart';

void main() {
  group('GameStatusWidget', () {
    testWidgets('should display menu state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusWidget(gameState: GameState.menu)),
        ),
      );

      expect(find.text('TAP TO START'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should display paused state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusWidget(gameState: GameState.paused)),
        ),
      );

      expect(find.text('PAUSED'), findsOneWidget);
      expect(find.text('Tap to resume'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should display game over state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusWidget(gameState: GameState.gameOver)),
        ),
      );

      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text('Tap restart to play again'), findsOneWidget);
      expect(find.byIcon(Icons.sports_esports), findsOneWidget);
    });

    testWidgets('should display restarting state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusWidget(gameState: GameState.restarting),
          ),
        ),
      );

      expect(find.text('RESTARTING...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should hide widget during playing state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusWidget(gameState: GameState.playing)),
        ),
      );

      expect(find.byType(Container), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should animate state transitions', (tester) async {
      const duration = Duration(milliseconds: 100);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusWidget(
              gameState: GameState.menu,
              animationDuration: duration,
            ),
          ),
        ),
      );

      expect(find.text('TAP TO START'), findsOneWidget);

      // Change state and animate
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusWidget(
              gameState: GameState.paused,
              animationDuration: duration,
            ),
          ),
        ),
      );

      // During animation, old widget should still be visible
      await tester.pump(const Duration(milliseconds: 50));

      // Complete animation
      await tester.pump(duration);

      expect(find.text('PAUSED'), findsOneWidget);
    });

    testWidgets('should use custom text style', (tester) async {
      const customStyle = TextStyle(fontSize: 32, color: Colors.green);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusWidget(
              gameState: GameState.menu,
              textStyle: customStyle,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('TAP TO START'));
      expect(textWidget.style?.fontSize, 32);
      expect(textWidget.style?.color, Colors.green);
    });
  });

  group('CompactGameStatusWidget', () {
    testWidgets('should display menu state icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(gameState: GameState.menu),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should display paused state icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(gameState: GameState.paused),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should display game over state icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(gameState: GameState.gameOver),
          ),
        ),
      );

      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('should display loading indicator for restarting state', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(gameState: GameState.restarting),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should hide during playing state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(gameState: GameState.playing),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('should use custom size', (tester) async {
      const customSize = 32.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactGameStatusWidget(
              gameState: GameState.menu,
              size: customSize,
            ),
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.play_arrow));
      expect(iconWidget.size, customSize);
    });
  });

  group('GameStatusBar', () {
    testWidgets('should display status text with icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusBar(gameState: GameState.paused)),
        ),
      );

      expect(find.text('Paused'), findsOneWidget);
      expect(find.byType(CompactGameStatusWidget), findsOneWidget);
    });

    testWidgets('should hide during playing state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameStatusBar(gameState: GameState.playing)),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Playing'), findsNothing);
    });

    testWidgets('should display all states correctly', (tester) async {
      final states = [
        (GameState.menu, 'Ready to start'),
        (GameState.paused, 'Paused'),
        (GameState.gameOver, 'Game Over'),
        (GameState.restarting, 'Restarting'),
      ];

      for (final (state, expectedText) in states) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GameStatusBar(gameState: state)),
          ),
        );

        expect(find.text(expectedText), findsOneWidget);
      }
    });

    testWidgets('should use custom padding', (tester) async {
      const customPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameStatusBar(
              gameState: GameState.paused,
              padding: customPadding,
            ),
          ),
        ),
      );

      final containerWidget = tester.widget<Container>(
        find.ancestor(
          of: find.text('Paused'),
          matching: find.byType(Container),
        ),
      );

      expect(containerWidget.padding, customPadding);
    });
  });
}
