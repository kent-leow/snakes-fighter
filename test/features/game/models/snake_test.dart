import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/snake.dart';

void main() {
  group('Snake', () {
    late Snake snake;

    setUp(() {
      snake = Snake(
        initialPosition: const Position(10, 10),
        initialDirection: Direction.right,
      );
    });

    group('initialization', () {
      test('should create snake with correct initial properties', () {
        expect(snake.length, 3);
        expect(snake.head, const Position(10, 10));
        expect(snake.currentDirection, Direction.right);
        expect(snake.nextDirection, isNull);
        expect(snake.shouldGrow, isFalse);
      });

      test('should generate correct initial body', () {
        final expectedBody = [
          const Position(10, 10), // Head
          const Position(9, 10), // Body segment 1
          const Position(8, 10), // Body segment 2 (tail)
        ];
        expect(snake.body, expectedBody);
      });

      test('should create single-segment snake when length is 1', () {
        final singleSnake = Snake(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.up,
          initialLength: 1,
        );
        expect(singleSnake.length, 1);
        expect(singleSnake.body, [const Position(5, 5)]);
      });
    });

    group('direction change', () {
      test('should queue valid direction changes', () {
        expect(snake.changeDirection(Direction.up), isTrue);
        expect(snake.nextDirection, Direction.up);
        expect(snake.currentDirection, Direction.right);
      });

      test('should reject backwards direction changes', () {
        expect(snake.changeDirection(Direction.left), isFalse);
        expect(snake.nextDirection, isNull);
        expect(snake.currentDirection, Direction.right);
      });

      test('should allow same direction', () {
        expect(snake.changeDirection(Direction.right), isTrue);
        expect(snake.nextDirection, Direction.right);
      });
    });

    group('movement', () {
      test('should move snake forward without growing', () {
        snake.move();

        expect(snake.head, const Position(11, 10));
        expect(snake.length, 3);
        expect(snake.tail, const Position(9, 10));
      });

      test('should apply queued direction change when moving', () {
        snake.changeDirection(Direction.up);
        snake.move();

        expect(snake.head, const Position(10, 9));
        expect(snake.currentDirection, Direction.up);
        expect(snake.nextDirection, isNull);
      });

      test('should grow snake when marked to grow', () {
        snake.grow();
        expect(snake.shouldGrow, isTrue);

        snake.move();

        expect(snake.length, 4);
        expect(snake.shouldGrow, isFalse);
        expect(snake.head, const Position(11, 10));
        expect(snake.tail, const Position(8, 10)); // Tail didn't move
      });

      test('should handle multiple direction changes correctly', () {
        snake.changeDirection(Direction.up);
        snake.move(); // Head at (10, 9), direction: up

        snake.changeDirection(Direction.left);
        snake.move(); // Head at (9, 9), direction: left

        expect(snake.head, const Position(9, 9));
        expect(snake.currentDirection, Direction.left);
      });
    });

    group('collision detection', () {
      test('should detect self collision', () {
        // Create a scenario where snake will collide with itself
        // Make the snake longer first
        snake.grow();
        snake.move();
        snake.grow();
        snake.move();
        snake.grow();
        snake.move();

        // Now make it turn and collide with itself
        snake.changeDirection(Direction.up);
        snake.move();
        snake.changeDirection(Direction.left);
        snake.move();
        snake.changeDirection(Direction.down);
        snake.move();
        snake.changeDirection(Direction.right);
        snake.move();

        expect(snake.collidesWithSelf(), isTrue);
      });

      test('should not detect collision with own head', () {
        expect(snake.collidesWithSelf(), isFalse);
      });
    });

    group('position queries', () {
      test('should correctly identify head position', () {
        expect(snake.isHeadAt(const Position(10, 10)), isTrue);
        expect(snake.isHeadAt(const Position(9, 10)), isFalse);
      });

      test('should correctly identify body positions', () {
        expect(snake.isBodyAt(const Position(10, 10)), isTrue); // Head
        expect(snake.isBodyAt(const Position(9, 10)), isTrue); // Body
        expect(snake.isBodyAt(const Position(8, 10)), isTrue); // Tail
        expect(snake.isBodyAt(const Position(7, 10)), isFalse); // Not body
      });

      test('should correctly identify body excluding head', () {
        expect(
          snake.isBodyExcludingHeadAt(const Position(10, 10)),
          isFalse,
        ); // Head
        expect(
          snake.isBodyExcludingHeadAt(const Position(9, 10)),
          isTrue,
        ); // Body
        expect(
          snake.isBodyExcludingHeadAt(const Position(8, 10)),
          isTrue,
        ); // Tail
      });

      test('should return correct occupied positions', () {
        final expectedPositions = {
          const Position(10, 10),
          const Position(9, 10),
          const Position(8, 10),
        };
        expect(snake.occupiedPositions, expectedPositions);
      });
    });

    group('copy and reset', () {
      test('should create correct copy of snake', () {
        snake.changeDirection(Direction.up);
        snake.grow();

        final copy = snake.copy();

        expect(copy.body, snake.body);
        expect(copy.currentDirection, snake.currentDirection);
        expect(copy.nextDirection, snake.nextDirection);
        expect(copy.shouldGrow, snake.shouldGrow);

        // Verify they're independent
        copy.move();
        expect(copy.body, isNot(equals(snake.body)));
      });

      test('should reset snake to new initial state', () {
        snake.changeDirection(Direction.up);
        snake.grow();
        snake.move();

        snake.reset(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.left,
          initialLength: 2,
        );

        expect(snake.length, 2);
        expect(snake.head, const Position(5, 5));
        expect(snake.currentDirection, Direction.left);
        expect(snake.nextDirection, isNull);
        expect(snake.shouldGrow, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final snake2 = Snake(
          initialPosition: const Position(10, 10),
          initialDirection: Direction.right,
        );

        expect(snake, equals(snake2));
        expect(snake.hashCode, equals(snake2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final snake2 = Snake(
          initialPosition: const Position(10, 10),
          initialDirection: Direction.left,
        );

        expect(snake, isNot(equals(snake2)));
      });
    });
  });
}
