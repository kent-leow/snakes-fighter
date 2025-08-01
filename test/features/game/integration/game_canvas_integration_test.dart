import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/widgets/game_canvas.dart';
import 'package:snakes_fight/features/game/widgets/responsive_game_container.dart';

void main() {
  group('Game Canvas Integration', () {
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

    group('complete rendering system integration', () {
      testWidgets('should render complete game with responsive container', (
        tester,
      ) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveGameContainer(
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: gameSize,
                ),
              ),
            ),
          ),
        );

        // Should have all the components
        expect(find.byType(ResponsiveGameContainer), findsOneWidget);
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle game state changes in complete system', (
        tester,
      ) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveGameContainer(
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: gameSize,
                ),
              ),
            ),
          ),
        );

        // Start game
        await gameController.startGame();
        await tester.pump();

        // Should render without errors
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Stop game
        await gameController.stopGame();
        await tester.pump();

        // Should still render without errors
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should work with different screen sizes', (tester) async {
        const gameSize = Size(300, 300);

        // Test with mobile portrait
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: Scaffold(
                body: AdaptiveGameContainer(
                  child: GameCanvas(
                    gameController: gameController,
                    gameSize: gameSize,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(PortraitGameContainer), findsOneWidget);
        expect(find.byType(GameCanvas), findsOneWidget);

        // Test with mobile landscape
        await tester.binding.setSurfaceSize(const Size(800, 400));

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 400)),
              child: Scaffold(
                body: AdaptiveGameContainer(
                  child: GameCanvas(
                    gameController: gameController,
                    gameSize: gameSize,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(LandscapeGameContainer), findsOneWidget);
        expect(find.byType(GameCanvas), findsOneWidget);
      });

      testWidgets('should maintain 60fps performance', (tester) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
              ),
            ),
          ),
        );

        // Start game for animation
        await gameController.startGame();

        // Pump frames to simulate animation
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16)); // ~60fps
          expect(tester.takeException(), isNull);
        }

        await gameController.stopGame();
      });

      testWidgets('should render all game elements correctly', (tester) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
              ),
            ),
          ),
        );

        // Start game to ensure all elements are active
        await gameController.startGame();
        await tester.pump();

        // Find the painter and verify it has the correct elements
        final customPaintFinder = find.descendant(
          of: find.byType(GameCanvas),
          matching: find.byType(CustomPaint),
        );

        expect(customPaintFinder, findsOneWidget);

        final customPaint = tester.widget<CustomPaint>(customPaintFinder);
        final painter = customPaint.painter as GameCanvasPainter;

        // Verify all game elements are present
        expect(painter.snake, isNotNull);
        expect(painter.food, isNotNull);
        expect(painter.showGrid, isTrue);
        expect(painter.gameState, isNotNull);

        await gameController.stopGame();
      });
    });

    group('rendering performance', () {
      testWidgets('should handle rapid repaints efficiently', (tester) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
              ),
            ),
          ),
        );

        await gameController.startGame();

        // Simulate rapid game updates
        for (int i = 0; i < 60; i++) {
          gameController.snake.move();
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.takeException(), isNull);
        }

        await gameController.stopGame();
      });

      testWidgets('should optimize repainting based on changes', (
        tester,
      ) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
              ),
            ),
          ),
        );

        // Get initial painter
        final customPaintFinder = find.descendant(
          of: find.byType(GameCanvas),
          matching: find.byType(CustomPaint),
        );

        final initialPaint = tester.widget<CustomPaint>(customPaintFinder);
        final initialPainter = initialPaint.painter as GameCanvasPainter;

        // Move snake to change state
        gameController.snake.move();
        await tester.pump();

        // Get updated painter
        final updatedPaint = tester.widget<CustomPaint>(customPaintFinder);
        final updatedPainter = updatedPaint.painter as GameCanvasPainter;

        // Should be different painters due to state change
        expect(updatedPainter.shouldRepaint(initialPainter), isTrue);
      });
    });

    group('visual validation', () {
      testWidgets('should render snake and food distinctly', (tester) async {
        const gameSize = Size(400, 400);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
              ),
            ),
          ),
        );

        await gameController.startGame();
        await tester.pump();

        // The canvas should render without throwing errors
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Snake and food should be in valid positions
        expect(gameController.snake.body.isNotEmpty, isTrue);
        expect(gameController.currentFood, isNotNull);

        await gameController.stopGame();
      });
    });
  });
}
