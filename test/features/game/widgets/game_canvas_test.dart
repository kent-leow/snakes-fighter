import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/widgets/game_canvas.dart';

void main() {
  group('GameCanvas', () {
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
      testWidgets('should create GameCanvas widget', (tester) async {
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

        expect(find.byType(GameCanvas), findsOneWidget);
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      });

      testWidgets('should apply correct size', (tester) async {
        const gameSize = Size(300, 300);
        
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

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GameCanvas),
            matching: find.byType(Container),
          ),
        );

        expect(container.constraints?.maxWidth, gameSize.width);
        expect(container.constraints?.maxHeight, gameSize.height);
      });

      testWidgets('should apply background color', (tester) async {
        const gameSize = Size(400, 400);
        const backgroundColor = Colors.blue;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
                backgroundColor: backgroundColor,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GameCanvas),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, backgroundColor);
      });
    });

    group('animation controller', () {
      testWidgets('should start animation controller', (tester) async {
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

        // The AnimatedBuilder should be present within GameCanvas
        expect(
          find.descendant(
            of: find.byType(GameCanvas),
            matching: find.byType(AnimatedBuilder),
          ),
          findsOneWidget,
        );
      });

      testWidgets('should dispose animation controller', (tester) async {
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

        // Remove the widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(),
            ),
          ),
        );

        // Should not throw any errors during disposal
        expect(tester.takeException(), isNull);
      });
    });

    group('game state updates', () {
      testWidgets('should rebuild when game state changes', (tester) async {
        const gameSize = Size(400, 400);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return GameCanvas(
                    gameController: gameController,
                    gameSize: gameSize,
                  );
                },
              ),
            ),
          ),
        );

        // Start the game to trigger state change
        await gameController.startGame();
        await tester.pump();

        // Stop the game to clean up resources
        await gameController.stopGame();
        await tester.pump();

        // The widget tree should update without errors
        expect(find.byType(GameCanvas), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('painter creation', () {
      testWidgets('should create GameCanvasPainter with correct properties', (tester) async {
        const gameSize = Size(400, 400);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameCanvas(
                gameController: gameController,
                gameSize: gameSize,
                showGrid: false,
              ),
            ),
          ),
        );

        // Find the specific CustomPaint within the GameCanvas
        final customPaintFinder = find.descendant(
          of: find.byType(GameCanvas),
          matching: find.byType(CustomPaint),
        );
        
        expect(customPaintFinder, findsOneWidget);
        
        final customPaint = tester.widget<CustomPaint>(customPaintFinder);
        final painter = customPaint.painter as GameCanvasPainter;

        expect(painter.snake, gameController.snake);
        expect(painter.food, gameController.currentFood);
        expect(painter.gameState, gameController.currentState);
        expect(painter.showGrid, false);
      });
    });

    group('responsive behavior', () {
      testWidgets('should handle different screen sizes', (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 600));
        
        const gameSize = Size(600, 450);
        
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

        expect(find.byType(GameCanvas), findsOneWidget);
        expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      });
    });
  });

  group('GameCanvasPainter', () {
    late GridSystem gridSystem;
    late GameController gameController;

    setUp(() {
      gridSystem = GridSystem(
        gridWidth: 10,
        gridHeight: 10,
        cellSize: 20.0,
        screenWidth: 200.0,
        screenHeight: 200.0,
      );
      gameController = GameController(gridSystem: gridSystem);
    });

    tearDown(() {
      gameController.dispose();
    });

    group('shouldRepaint', () {
      test('should repaint when snake changes', () {
        final initialSnake = gameController.snake.copy();
        
        final painter1 = GameCanvasPainter(
          snake: initialSnake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        // Move snake to create a different state
        gameController.snake.move();

        final painter2 = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('should repaint when game state changes', () async {
        final painter1 = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        // Start the game to change state
        await gameController.startGame();

        final painter2 = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        expect(painter2.shouldRepaint(painter1), isTrue);
      });

      test('should not repaint when nothing changes', () {
        final painter1 = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        final painter2 = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        expect(painter2.shouldRepaint(painter1), isFalse);
      });
    });

    group('hit test', () {
      test('should return true for hit test', () {
        final painter = GameCanvasPainter(
          snake: gameController.snake,
          food: gameController.currentFood,
          gameState: gameController.currentState,
          showGrid: true,
          gridSize: const Size(10, 10),
          cellSize: 20.0,
        );

        expect(painter.hitTest(const Offset(50, 50)), isTrue);
        expect(painter.hitTest(const Offset(0, 0)), isTrue);
        expect(painter.hitTest(const Offset(200, 200)), isTrue);
      });
    });
  });
}
