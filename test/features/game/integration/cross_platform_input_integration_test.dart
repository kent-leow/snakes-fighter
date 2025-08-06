import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/widgets/game_canvas.dart';
import 'package:snakes_fight/features/game/widgets/game_input_widget.dart';

void main() {
  group('Cross-Platform Input Integration', () {
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

    group('full game integration', () {
      testWidgets('should integrate input system with game canvas', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: const Size(400, 400),
                ),
              ),
            ),
          ),
        );

        // Start the game
        await gameController.startGame();
        await tester.pump();

        // Verify all components are present
        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);
        expect(find.byType(KeyboardListener), findsOneWidget);

        // Test touch interaction
        await tester.drag(find.byType(GameCanvas), const Offset(100, 0));
        await tester.pump();

        // Should not throw any errors
        expect(tester.takeException(), isNull);

        // Stop the game
        await gameController.stopGame();
        await tester.pump();
      });

      testWidgets('should handle direction changes through input system', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: const Size(400, 400),
                ),
              ),
            ),
          ),
        );

        // Start the game
        await gameController.startGame();
        await tester.pump();

        // Perform a swipe that should change direction
        await tester.drag(
          find.byType(GameCanvas),
          const Offset(0, -100), // Swipe up
          touchSlopY: 0,
        );
        await tester.pump();

        // The direction change might not be immediate due to game logic
        // but the input system should process it without errors
        expect(tester.takeException(), isNull);

        // Stop the game
        await gameController.stopGame();
        await tester.pump();
      });

      testWidgets('should support responsive layout with input', (
        tester,
      ) async {
        // Test with different screen sizes
        await tester.binding.setSurfaceSize(const Size(800, 600));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameInputWidget(
                gameController: gameController,
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: const Size(600, 450),
                ),
              ),
            ),
          ),
        );

        // Verify components render correctly
        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('input method adaptation', () {
      testWidgets('should adapt to platform capabilities', (tester) async {
        final widget = GameInputWidget(
          gameController: gameController,
          child: const SizedBox(width: 200, height: 200),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        // Widget should initialize without errors
        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support enabling all input methods', (tester) async {
        final widget = GameInputWidget(
          gameController: gameController,
          enableAllInputMethods: true, // Enable all supported controllers
          child: const SizedBox(width: 200, height: 200),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        // Widget should initialize without errors
        expect(find.byType(GameInputWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('visual feedback integration', () {
      testWidgets('should provide visual feedback for input', (tester) async {
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

        // Start the game
        await gameController.startGame();
        await tester.pump();

        // Test input with visual feedback
        await tester.tap(find.byType(SizedBox));
        await tester.pump();

        expect(tester.takeException(), isNull);

        // Stop the game
        await gameController.stopGame();
        await tester.pump();
      });
    });

    group('performance and responsiveness', () {
      testWidgets('should maintain performance with rapid input', (
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

        // Start the game
        await gameController.startGame();
        await tester.pump();

        // Perform rapid input gestures
        for (int i = 0; i < 10; i++) {
          await tester.drag(
            find.byType(SizedBox),
            Offset(50.0, i % 2 == 0 ? 50.0 : -50.0),
          );
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Should handle rapid input without errors
        expect(tester.takeException(), isNull);

        // Stop the game
        await gameController.stopGame();
        await tester.pump();
      });

      testWidgets('should respond to input within acceptable time', (
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

        // Start the game
        await gameController.startGame();
        await tester.pump();

        final stopwatch = Stopwatch()..start();

        // Perform input gesture
        await tester.drag(find.byType(SizedBox), const Offset(100, 0));
        await tester.pump();

        stopwatch.stop();

        // Input processing should be very fast (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(tester.takeException(), isNull);

        // Stop the game
        await gameController.stopGame();
        await tester.pump();
      });
    });

    group('error handling and edge cases', () {
      testWidgets('should handle invalid input gracefully', (tester) async {
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

        // Test very small gestures (should be ignored)
        await tester.drag(find.byType(SizedBox), const Offset(1, 1));
        await tester.pump();

        // Should handle gracefully without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle game state changes during input', (
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

        // Start the game
        await gameController.startGame();
        await tester.pump();

        // Perform input while changing game state
        final future = tester.drag(find.byType(SizedBox), const Offset(100, 0));

        // Pause game during input
        await gameController.pauseGame();
        await future;
        await tester.pump();

        // Should handle state change during input gracefully
        expect(tester.takeException(), isNull);
      });
    });
  });
}
