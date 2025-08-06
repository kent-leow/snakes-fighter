import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/logic/growth_system.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/snake.dart';

void main() {
  group('GrowthSystem', () {
    late Snake snake;

    setUp(() {
      snake = Snake(
        initialPosition: const Position(5, 5),
        initialDirection: Direction.right,
      );
    });

    group('growSnake', () {
      test('should trigger snake growth', () {
        expect(snake.shouldGrow, isFalse);

        GrowthSystem.growSnake(snake);

        expect(snake.shouldGrow, isTrue);
      });

      test('should work multiple times', () {
        GrowthSystem.growSnake(snake);
        expect(snake.shouldGrow, isTrue);

        // Simulate movement to consume the growth flag
        snake.move();
        expect(snake.shouldGrow, isFalse);

        // Should be able to grow again
        GrowthSystem.growSnake(snake);
        expect(snake.shouldGrow, isTrue);
      });
    });

    group('calculateNewTailPosition', () {
      test('should calculate tail position for single-segment snake', () {
        final singleSnake = Snake(
          initialPosition: const Position(3, 3),
          initialDirection: Direction.up,
          initialLength: 1,
        );

        final newTailPosition = GrowthSystem.calculateNewTailPosition(
          singleSnake,
        );

        // Should extend opposite to current direction (down from up)
        expect(newTailPosition, const Position(3, 4));
      });

      test(
        'should calculate tail position for multi-segment snake moving right',
        () {
          // Snake body: [(5,5), (4,5), (3,5)] - moving right
          final newTailPosition = GrowthSystem.calculateNewTailPosition(snake);

          // Should extend from current tail (3,5) in the same direction (left)
          expect(newTailPosition, const Position(2, 5));
        },
      );

      test('should calculate tail position for snake moving up', () {
        final upSnake = Snake(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.up,
        );
        // Move snake up to establish direction
        upSnake.move(); // Head moves to (5, 4)

        final newTailPosition = GrowthSystem.calculateNewTailPosition(upSnake);

        // Should extend downward from current tail
        expect(newTailPosition, const Position(5, 7));
      });

      test('should calculate tail position for snake moving down', () {
        final downSnake = Snake(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.down,
        );
        downSnake.move(); // Head moves to (5, 6)

        final newTailPosition = GrowthSystem.calculateNewTailPosition(
          downSnake,
        );

        // Should extend upward from current tail
        expect(newTailPosition, const Position(5, 3));
      });

      test('should calculate tail position for snake moving left', () {
        final leftSnake = Snake(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.left,
        );
        leftSnake.move(); // Head moves to (4, 5)

        final newTailPosition = GrowthSystem.calculateNewTailPosition(
          leftSnake,
        );

        // Should extend rightward from current tail
        expect(newTailPosition, const Position(7, 5));
      });

      test('should handle edge case for minimal snake', () {
        final minimalSnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 0, // This still creates a snake with length 1
        );

        // Should not throw error since snake still has head
        final newTailPosition = GrowthSystem.calculateNewTailPosition(
          minimalSnake,
        );
        expect(
          newTailPosition,
          const Position(-1, 0),
        ); // Extends left from head
      });
    });

    group('canGrowSnake', () {
      test('should return true for valid snake', () {
        final canGrow = GrowthSystem.canGrowSnake(snake);

        expect(canGrow, isTrue);
      });

      test('should return true for minimal snake', () {
        final minimalSnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 0, // Still creates length 1 snake
        );

        final canGrow = GrowthSystem.canGrowSnake(minimalSnake);

        expect(canGrow, isTrue); // Length is 1, so can grow
      });
    });

    group('getPredictedLength', () {
      test('should return current length when not growing', () {
        final predictedLength = GrowthSystem.getPredictedLength(snake);

        expect(predictedLength, snake.length);
      });

      test('should return length + 1 when growing', () {
        GrowthSystem.growSnake(snake);
        final predictedLength = GrowthSystem.getPredictedLength(snake);

        expect(predictedLength, snake.length + 1);
      });
    });

    group('isSnakeGrowing', () {
      test('should return false initially', () {
        final isGrowing = GrowthSystem.isSnakeGrowing(snake);

        expect(isGrowing, isFalse);
      });

      test('should return true after growth is triggered', () {
        GrowthSystem.growSnake(snake);
        final isGrowing = GrowthSystem.isSnakeGrowing(snake);

        expect(isGrowing, isTrue);
      });
    });

    group('simulateGrowth', () {
      test('should return current body when not growing', () {
        final simulatedBody = GrowthSystem.simulateGrowth(snake);

        expect(simulatedBody, equals(snake.body));
        expect(simulatedBody, isNot(same(snake.body))); // Should be a copy
      });

      test('should return extended body when growing', () {
        GrowthSystem.growSnake(snake);
        final originalLength = snake.body.length;

        final simulatedBody = GrowthSystem.simulateGrowth(snake);

        expect(simulatedBody.length, originalLength + 1);
        // First segments should match original body
        for (int i = 0; i < originalLength; i++) {
          expect(simulatedBody[i], snake.body[i]);
        }
      });

      test('should not modify original snake', () {
        GrowthSystem.growSnake(snake);
        final originalBody = List.from(snake.body);

        GrowthSystem.simulateGrowth(snake);

        expect(snake.body, equals(originalBody));
      });
    });

    group('calculateMaxSnakeLength', () {
      test('should calculate correct maximum for given grid dimensions', () {
        final maxLength = GrowthSystem.calculateMaxSnakeLength(10, 8);

        expect(maxLength, 80);
      });

      test('should handle square grids', () {
        final maxLength = GrowthSystem.calculateMaxSnakeLength(5, 5);

        expect(maxLength, 25);
      });

      test('should handle single-dimension grids', () {
        final maxLength = GrowthSystem.calculateMaxSnakeLength(1, 10);

        expect(maxLength, 10);
      });
    });

    group('hasReachedMaxGrowth', () {
      test('should return false for small snake on large grid', () {
        final hasReachedMax = GrowthSystem.hasReachedMaxGrowth(snake, 20, 20);

        expect(hasReachedMax, isFalse);
      });

      test('should return true when predicted length equals grid size', () {
        // Create a snake that would fill a 3x1 grid when grown
        final nearMaxSnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 2,
        );
        GrowthSystem.growSnake(nearMaxSnake); // Predicted length = 3

        final hasReachedMax = GrowthSystem.hasReachedMaxGrowth(
          nearMaxSnake,
          3,
          1,
        );

        expect(hasReachedMax, isTrue);
      });

      test('should return true when current length equals grid size', () {
        final maxSnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 4, // Fills 2x2 grid
        );

        final hasReachedMax = GrowthSystem.hasReachedMaxGrowth(maxSnake, 2, 2);

        expect(hasReachedMax, isTrue);
      });
    });

    group('edge cases', () {
      test('should handle snake direction changes in tail calculation', () {
        // Create snake and change direction
        snake.changeDirection(Direction.up);
        snake.move(); // Apply direction change

        final newTailPosition = GrowthSystem.calculateNewTailPosition(snake);

        // Should still calculate based on actual body positions
        expect(newTailPosition, isA<Position>());
      });

      test('should handle repeated growth and movement cycles', () {
        final initialLength = snake.length;

        // Grow and move multiple times
        for (int i = 0; i < 3; i++) {
          GrowthSystem.growSnake(snake);
          snake.move(); // This should grow the snake
        }

        expect(snake.length, initialLength + 3);
      });
    });
  });
}
