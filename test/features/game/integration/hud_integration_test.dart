import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/widgets/game_hud.dart';

void main() {
  group('HUD Integration Tests', () {
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

    tearDown(() async {
      try {
        if (gameController.isPlaying || gameController.isPaused) {
          await gameController.stopGame();
        }
      } catch (e) {
        // Ignore errors during cleanup
      }
      gameController.dispose();
    });

    group('HUD with GameController integration', () {
      testWidgets(
        'should display real-time score updates from game controller',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListenableBuilder(
                  listenable: gameController,
                  builder: (context, _) {
                    return GameHUD(
                      scoreManager: gameController.scoreManager,
                      stateManager: gameController.stateManager,
                      onPause: () => gameController.pauseGame(),
                      onResume: () => gameController.resumeGame(),
                      onRestart: () => gameController.resetGame(),
                    );
                  },
                ),
              ),
            ),
          );

          // Initial state
          expect(find.text('Score: 0'), findsOneWidget);
          expect(find.text('TAP TO START'), findsOneWidget);

          // Start game
          await gameController.startGame();
          await tester.pump();

          expect(find.text('Score: 0'), findsOneWidget);
          expect(find.text('Pause'), findsOneWidget);

          // Simulate food consumption by directly adding points
          gameController.scoreManager.addFoodPoints(snakeLength: 5);
          await tester.pump();

          expect(find.text('Score: 10'), findsOneWidget);
          expect(find.text('Food: 1'), findsOneWidget);
        },
      );

      testWidgets('should handle game state transitions correctly', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        // Start game
        await gameController.startGame();
        await tester.pump();

        expect(find.text('Pause'), findsOneWidget);

        // Pause game
        await gameController.pauseGame();
        await tester.pump();

        expect(find.text('PAUSED'), findsOneWidget);
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('Restart'), findsOneWidget);

        // Resume game
        await gameController.resumeGame();
        await tester.pump();

        expect(find.text('Pause'), findsOneWidget);
        expect(find.text('PAUSED'), findsNothing);
      });

      testWidgets('should handle button callbacks correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        // Start game
        await gameController.startGame();
        await tester.pump();

        // Test pause button
        await tester.tap(find.text('Pause'));
        await tester.pump();

        expect(gameController.isPaused, isTrue);
        expect(find.text('PAUSED'), findsOneWidget);

        // Test resume button
        await tester.tap(find.text('Resume'));
        await tester.pump();

        expect(gameController.isPlaying, isTrue);
        expect(find.text('PAUSED'), findsNothing);

        // Pause again and test restart
        await gameController.pauseGame();
        await tester.pump();

        await tester.tap(find.text('Restart'));
        await tester.pump();

        expect(gameController.isPlaying, isTrue);
        expect(gameController.score, 0);
      });

      testWidgets('should update session count correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        // Start first game
        await gameController.startGame();
        await tester.pump();

        expect(find.text('Session: 1'), findsOneWidget);

        // Stop game cleanly and return to menu
        await gameController.stopGame();
        await tester.pump();

        // Return to menu state (this allows starting a new game)
        gameController.stateManager.transitionTo(GameState.menu);
        await tester.pump();

        // Start a new game (simulating restart)
        await gameController.startGame();
        await tester.pump();

        expect(find.text('Session: 2'), findsOneWidget);

        // Clean up - stop the game before test ends
        await gameController.stopGame();
        await tester.pump();
      });

      testWidgets('should show high score when available', (tester) async {
        // Set up initial high score
        gameController.scoreManager.updateHighScore(150);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Best: 150'), findsOneWidget);

        // Start game and add score
        await gameController.startGame();
        gameController.scoreManager.addPoints(200);
        await tester.pump();

        expect(find.text('Score: 200'), findsOneWidget);
        expect(find.text('Best: 200'), findsOneWidget);
      });
    });

    group('Performance and responsiveness', () {
      testWidgets('should handle rapid score updates efficiently', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        await gameController.startGame();
        await tester.pump();

        // Simulate rapid score increases
        for (int i = 1; i <= 10; i++) {
          gameController.scoreManager.addPoints(10);
          await tester.pump();
        }

        expect(find.text('Score: 100'), findsOneWidget);
        expect(find.text('Food: 10'), findsOneWidget);
      });

      testWidgets('should be responsive to different screen sizes', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: gameController,
                builder: (context, _) {
                  return GameHUD(
                    scoreManager: gameController.scoreManager,
                    stateManager: gameController.stateManager,
                    onPause: () => gameController.pauseGame(),
                    onResume: () => gameController.resumeGame(),
                    onRestart: () => gameController.resetGame(),
                  );
                },
              ),
            ),
          ),
        );

        // Test different screen sizes
        final screenSizes = [
          const Size(320, 568), // Small phone
          const Size(375, 667), // Medium phone
          const Size(414, 896), // Large phone
          const Size(768, 1024), // Tablet
        ];

        for (final size in screenSizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pump();

          // HUD should still be visible and functional
          expect(find.text('Score: 0'), findsOneWidget);
          expect(find.text('TAP TO START'), findsOneWidget);
        }

        // Reset to default
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
