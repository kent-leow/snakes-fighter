import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/widgets/game_input_widget.dart';
import 'package:snakes_fight/features/game/widgets/input_feedback_widget.dart';

void main() {
  group('GameInputWidget', () {
    late GridSystem gridSystem;
    late GameController gameController;

    setUp(() {
      gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 20,
        cellSize: 20.0,
        screenWidth: 400.0,
        screenHeight: 400.0,
      );
      gameController = GameController(gridSystem: gridSystem);
    });

    tearDown(() {
      gameController.dispose();
    });

    group('widget creation', () {
      testWidgets('should create GameInputWidget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('should wrap child with input handlers', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Should have gesture detector for touch input
        expect(find.byType(GestureDetector), findsOneWidget);

        // Should have keyboard listener for keyboard input
        expect(find.byType(KeyboardListener), findsOneWidget);
      });

      testWidgets('should include visual feedback when enabled', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        expect(find.byType(InputFeedbackWidget), findsOneWidget);
      });

      testWidgets('should exclude visual feedback when disabled', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                enableVisualFeedback: false,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        expect(find.byType(InputFeedbackWidget), findsNothing);
      });
    });

    group('input handling', () {
      testWidgets('should handle tap gestures', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Tap on the widget
        await tester.tap(find.byType(SizedBox), warnIfMissed: false);
        await tester.pump();

        // Should not throw any errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle pan gestures', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Perform a swipe gesture
        await tester.drag(find.byType(SizedBox), const Offset(100, 0), warnIfMissed: false);
        await tester.pump();

        // Should not throw any errors
        expect(tester.takeException(), isNull);
      });
    });

    group('game controller integration', () {
      testWidgets('should integrate with game controller', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Start the game so direction changes are accepted
        await gameController.startGame();
        await tester.pump();

        // The widget should be created without errors
        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Stop the game to clean up properly
        await gameController.stopGame();
        await tester.pump();
      });
    });

    group('focus management', () {
      testWidgets('should request focus for keyboard input', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Find the keyboard listener
        final keyboardListener = find.byType(KeyboardListener);
        expect(keyboardListener, findsOneWidget);

        final widget = tester.widget<KeyboardListener>(keyboardListener);
        expect(widget.autofocus, isTrue);
      });
    });

    group('configuration options', () {
      testWidgets('should support enabling all input methods', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                enableAllInputMethods: true,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('lifecycle management', () {
      testWidgets('should dispose properly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: const SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        );

        // Remove the widget
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );

        // Should not throw any errors during disposal
        expect(tester.takeException(), isNull);
      });
    });
  });
}
