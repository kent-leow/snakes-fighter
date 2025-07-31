import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  group('Food System Integration', () {
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

    group('food spawning', () {
      test('should spawn food when game is initialized', () {
        expect(gameController.currentFood, isNotNull);
        expect(gameController.currentFood!.isActive, isTrue);
      });

      test('should spawn food at position not occupied by snake', () {
        final food = gameController.currentFood!;
        final snakePositions = gameController.snake.occupiedPositions;

        expect(snakePositions.contains(food.position), isFalse);
      });

      test('should spawn new food after consumption', () {
        gameController.startGame();
        final originalFood = gameController.currentFood!;
        final originalFoodPosition = originalFood.position;

        // Move snake to food position (may require multiple moves)
        _moveSnakeToPosition(gameController, originalFoodPosition);

        // New food should be spawned
        expect(gameController.currentFood, isNotNull);
        expect(gameController.currentFood!.isActive, isTrue);
        // Should be different food (different position or new instance)
        expect(
          gameController.currentFood!.position != originalFoodPosition ||
              gameController.currentFood != originalFood,
          isTrue,
        );
      });
    });

    group('food consumption', () {
      test('should consume food when snake head reaches it', () {
        gameController.startGame();
        final originalScore = gameController.score;
        final food = gameController.currentFood!;

        // Move snake to food position
        _moveSnakeToPosition(gameController, food.position);

        // Score should increase
        expect(gameController.score, greaterThan(originalScore));
        // Snake should be set to grow (will grow on next move)
        expect(gameController.snake.shouldGrow, isTrue);
      });

      test('should grow snake after food consumption', () {
        gameController.startGame();
        final originalLength = gameController.snake.length;
        final food = gameController.currentFood!;

        // Move snake to food position
        _moveSnakeToPosition(gameController, food.position);

        // Force another move to trigger growth
        gameController.stepGame();

        expect(gameController.snake.length, originalLength + 1);
      });

      test('should award points for food consumption', () {
        gameController.startGame();
        final originalScore = gameController.score;
        final food = gameController.currentFood!;

        // Move snake to food position
        _moveSnakeToPosition(gameController, food.position);

        expect(gameController.score, originalScore + 10);
      });
    });

    group('game statistics', () {
      test('should include food information in game stats', () {
        final stats = gameController.getGameStats();

        expect(stats['hasFood'], isTrue);
        expect(stats['foodPosition'], isNotNull);
        expect(stats['foodActive'], isTrue);
      });

      test('should update food stats after consumption', () {
        gameController.startGame();
        final food = gameController.currentFood!;
        final originalScore = gameController.score;

        // Move snake to food
        _moveSnakeToPosition(gameController, food.position);

        final newStats = gameController.getGameStats();

        // Score should have increased (indicating consumption occurred)
        expect(gameController.score, greaterThan(originalScore));
        // Should still have food available
        expect(newStats['hasFood'], isTrue);
        expect(newStats['foodActive'], isTrue);
      });
    });

    group('edge cases', () {
      test('should handle rapid food consumption', () {
        gameController.startGame();
        int consumedFood = 0;

        // Consume multiple foods quickly
        for (int i = 0; i < 3; i++) {
          if (gameController.currentFood != null) {
            final food = gameController.currentFood!;
            _moveSnakeToPosition(gameController, food.position);
            consumedFood++;
          }
        }

        expect(consumedFood, 3);
        expect(gameController.score, 30); // 10 points per food
      });

      test('should handle food spawning near grid boundaries', () {
        // Create small grid to force boundary conditions
        final smallGrid = GridSystem(
          gridWidth: 3,
          gridHeight: 3,
          cellSize: 20.0,
          screenWidth: 60.0,
          screenHeight: 60.0,
        );
        final smallController = GameController(gridSystem: smallGrid);

        try {
          expect(smallController.currentFood, isNotNull);
          final food = smallController.currentFood!;
          expect(smallGrid.isValidPosition(food.position), isTrue);
        } finally {
          smallController.dispose();
        }
      });

      test('should handle game over when no food positions available', () {
        // Create very small grid that can be filled
        final tinyGrid = GridSystem(
          gridWidth: 2,
          gridHeight: 2,
          cellSize: 20.0,
          screenWidth: 40.0,
          screenHeight: 40.0,
        );
        final tinyController = GameController(gridSystem: tinyGrid);

        try {
          tinyController.startGame();

          // The snake starts with length 3, but grid only has 4 positions total
          // So after initialization, there might already be limited space
          // Let's check if we can even spawn food initially
          expect(tinyController.currentFood, isNotNull);

          // With a 2x2 grid and snake length 3, we should quickly run out of space
          // when the snake grows
          final initialScore = tinyController.score;

          // Try to consume one food item if possible
          if (tinyController.currentFood != null) {
            final food = tinyController.currentFood!;
            _moveSnakeToPosition(tinyController, food.position);
          }

          // Either the game should be over or we should have consumed food
          expect(
            tinyController.isGameOver || tinyController.score > initialScore,
            isTrue,
          );
        } finally {
          tinyController.dispose();
        }
      });
    });

    group('game loop integration', () {
      test('should process food consumption in game loop', () {
        gameController.startGame();
        final food = gameController.currentFood!;
        final originalScore = gameController.score;

        // Position snake next to food
        _positionSnakeNextToFood(gameController, food.position);

        // Single game step should consume food
        gameController.stepGame();

        expect(gameController.score, greaterThan(originalScore));
      });

      test('should maintain consistent food state during gameplay', () {
        gameController.startGame();

        // Run several game steps
        for (int i = 0; i < 5; i++) {
          gameController.stepGame();
          expect(gameController.currentFood, isNotNull);
          expect(gameController.currentFood!.isActive, isTrue);
        }
      });
    });
  });
}

/// Helper function to move snake to a specific position
void _moveSnakeToPosition(GameController controller, Position targetPosition) {
  // Simple approach: position the snake directly adjacent to target and move
  controller.snake.reset(
    initialPosition: Position(targetPosition.x - 1, targetPosition.y),
    initialDirection: Direction.right,
  );

  // One step should move the snake to the target position
  controller.stepGame();
}

/// Helper function to position snake next to food for consumption test
void _positionSnakeNextToFood(
  GameController controller,
  Position foodPosition,
) {
  // Find a position adjacent to food
  final adjacentPositions = [
    Position(foodPosition.x - 1, foodPosition.y),
    Position(foodPosition.x + 1, foodPosition.y),
    Position(foodPosition.x, foodPosition.y - 1),
    Position(foodPosition.x, foodPosition.y + 1),
  ];

  for (final adjPos in adjacentPositions) {
    if (controller.gridSystem.isValidPosition(adjPos)) {
      // Reset snake to adjacent position
      controller.snake.reset(
        initialPosition: adjPos,
        initialDirection: _getDirectionToward(adjPos, foodPosition),
        initialLength: 1,
      );
      break;
    }
  }
}

/// Helper function to get direction from one position toward another
Direction _getDirectionToward(Position from, Position to) {
  final dx = to.x - from.x;
  final dy = to.y - from.y;

  if (dx > 0) return Direction.right;
  if (dx < 0) return Direction.left;
  if (dy > 0) return Direction.down;
  if (dy < 0) return Direction.up;

  return Direction.right; // Default
}
