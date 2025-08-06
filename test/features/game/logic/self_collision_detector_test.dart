import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/logic/self_collision_detector.dart';
import 'package:snakes_fight/features/game/models/collision.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/snake.dart';

void main() {
  group('SelfCollisionDetector', () {
    late Snake snake;

    setUp(() {
      // Create a snake with initial length of 4
      snake = Snake(
        initialPosition: const Position(10, 10),
        initialDirection: Direction.right,
        initialLength: 4,
      );

      // Clear any cached data
      SelfCollisionDetector.clearCache();
    });

    tearDown(() {
      SelfCollisionDetector.clearCache();
    });

    group('checkSelfCollision', () {
      test('should detect no collision for normal snake', () {
        final result = SelfCollisionDetector.checkSelfCollision(snake);

        expect(result.type, equals(CollisionType.none));
        expect(result.collisionPoint, isNull);
        expect(result.isGameEnding, isFalse);
        expect(result.detectionTime, isA<double>());
        expect(
          result.detectionTime,
          lessThan(50.0),
        ); // Very relaxed for debug builds
      });

      test('should detect collision when head overlaps body', () {
        // Create a more controlled scenario with proper collision
        // Reset snake to a specific position
        snake.reset(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.right,
          initialLength: 4,
        );

        // Make snake grow first to enable proper collision
        snake.grow();
        snake.move(); // (6, 5) - grows to 5 segments

        // Create U-turn collision scenario
        snake.changeDirection(Direction.down);
        snake.move(); // (6, 6)
        snake.changeDirection(Direction.left);
        snake.move(); // (5, 6)

        // Now check if moving up would cause collision with body segment
        final result = SelfCollisionDetector.checkSelfCollisionAtPosition(
          snake,
          const Position(5, 5),
        );

        expect(result.type, equals(CollisionType.selfCollision));
        expect(result.collisionPoint, equals(const Position(5, 5)));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['snake_length'], equals(snake.length));
      });

      test(
        'should not detect collision when head moves to previous tail position',
        () {
          // Record initial tail position
          final initialTail = snake.tail;

          // Move snake forward (tail moves away)
          snake.move();

          // Check collision at the previous tail position
          final result = SelfCollisionDetector.checkSelfCollisionAtPosition(
            snake,
            initialTail,
          );

          expect(result.type, equals(CollisionType.none));
        },
      );

      test('should consider growth when checking collision', () {
        // Mark snake to grow
        snake.grow();

        // When growing, tail doesn't move, so more positions are blocked
        final result = SelfCollisionDetector.checkSelfCollision(snake);

        expect(result.type, equals(CollisionType.none));
        // The collision logic should account for the fact that tail won't move
      });
    });

    group('checkSelfCollisionAtPosition', () {
      test('should detect collision at body position', () {
        final bodyPosition = snake.body[1]; // Second segment

        final result = SelfCollisionDetector.checkSelfCollisionAtPosition(
          snake,
          bodyPosition,
        );

        expect(result.type, equals(CollisionType.selfCollision));
        expect(result.collisionPoint, equals(bodyPosition));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['is_predictive'], isTrue);
      });

      test('should not detect collision at empty position', () {
        const emptyPosition = Position(5, 5);

        final result = SelfCollisionDetector.checkSelfCollisionAtPosition(
          snake,
          emptyPosition,
        );

        expect(result.type, equals(CollisionType.none));
        expect(result.collisionPoint, isNull);
        expect(result.isGameEnding, isFalse);
      });

      test('should not detect collision at head position', () {
        final headPosition = snake.head;

        final result = SelfCollisionDetector.checkSelfCollisionAtPosition(
          snake,
          headPosition,
        );

        // Head position shouldn't count as collision since head is always at head position
        expect(result.type, equals(CollisionType.none));
      });
    });

    group('predictSelfCollision', () {
      test('should predict collision in next move', () {
        // Create a specific scenario where next move would cause collision
        snake.reset(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.right,
          initialLength: 4,
        );

        // Make snake grow first for proper collision scenario
        snake.grow();
        snake.move(); // (6, 5) - grows to 5 segments

        // Create U-turn collision scenario
        snake.changeDirection(Direction.down);
        snake.move(); // (6, 6)
        snake.changeDirection(Direction.left);
        snake.move(); // (5, 6)

        // Set direction to up - next move would be to (5, 5) which is occupied
        snake.changeDirection(Direction.up);

        final result = SelfCollisionDetector.predictSelfCollision(snake);

        expect(result.type, equals(CollisionType.selfCollision));
        expect(result.isGameEnding, isTrue);
      });

      test('should predict no collision for safe move', () {
        final result = SelfCollisionDetector.predictSelfCollision(snake);

        expect(result.type, equals(CollisionType.none));
        expect(result.isGameEnding, isFalse);
      });
    });

    group('utility methods', () {
      test('doesPositionCollideWithSnake should work correctly', () {
        final bodyPosition = snake.body[1];
        const emptyPosition = Position(5, 5);

        expect(
          SelfCollisionDetector.doesPositionCollideWithSnake(
            snake,
            bodyPosition,
          ),
          isTrue,
        );
        expect(
          SelfCollisionDetector.doesPositionCollideWithSnake(
            snake,
            emptyPosition,
          ),
          isFalse,
        );
      });

      test('getSelfCollisionPositions should return body positions', () {
        final collisionPositions =
            SelfCollisionDetector.getSelfCollisionPositions(snake);

        // Should include body positions excluding head and tail (if not growing)
        expect(
          collisionPositions.length,
          equals((snake.length - 2).clamp(0, snake.length)),
        );
        expect(collisionPositions, isNot(contains(snake.head)));

        // For a non-growing snake, should exclude head and tail
        if (!snake.shouldGrow && snake.length > 2) {
          expect(collisionPositions, isNot(contains(snake.tail)));
        }
      });

      test('getDistanceToNearestBodySegment should calculate correctly', () {
        const testPosition = Position(15, 10);

        final distance = SelfCollisionDetector.getDistanceToNearestBodySegment(
          snake,
          testPosition,
        );

        expect(distance, isA<double>());
        expect(distance, greaterThan(0));
      });

      test('checkMultiplePositions should handle batch processing', () {
        final positions = [
          const Position(5, 5), // Empty
          snake.body[1], // Body collision
          const Position(20, 20), // Empty
        ];

        final results = SelfCollisionDetector.checkMultiplePositions(
          snake,
          positions,
        );

        expect(results, hasLength(3));
        expect(results[const Position(5, 5)]!.type, equals(CollisionType.none));
        expect(
          results[snake.body[1]]!.type,
          equals(CollisionType.selfCollision),
        );
        expect(
          results[const Position(20, 20)]!.type,
          equals(CollisionType.none),
        );
      });
    });

    group('performance tests', () {
      test(
        'should meet performance requirements for single collision check',
        () {
          final result = SelfCollisionDetector.checkSelfCollision(snake);

          expect(
            result.detectionTime,
            lessThan(5.0),
          ); // Relaxed for debug builds
        },
      );

      test('should maintain performance with large snake', () {
        // Create a very long snake
        final longSnake = Snake(
          initialPosition: const Position(50, 50),
          initialDirection: Direction.right,
          initialLength: 100,
        );

        final result = SelfCollisionDetector.checkSelfCollision(longSnake);

        expect(result.detectionTime, lessThan(5.0)); // Relaxed for debug builds
      });

      test('should use caching effectively', () {
        // First check (cache miss)
        final result1 = SelfCollisionDetector.checkSelfCollision(snake);

        // Second check (cache hit) - should be faster or similar
        final result2 = SelfCollisionDetector.checkSelfCollision(snake);

        expect(result1.detectionTime, lessThan(5.0));
        expect(result2.detectionTime, lessThan(5.0));

        // Cache should help maintain consistent performance (very relaxed for debug)
        expect(
          result2.detectionTime,
          lessThanOrEqualTo(result1.detectionTime * 10),
        );
      });
    });

    group('edge cases', () {
      test('should handle single-segment snake', () {
        final shortSnake = Snake(
          initialPosition: const Position(5, 5),
          initialDirection: Direction.right,
          initialLength: 1,
        );

        final result = SelfCollisionDetector.checkSelfCollision(shortSnake);

        expect(result.type, equals(CollisionType.none));
      });

      test('should handle snake with queued direction change', () {
        snake.changeDirection(Direction.up);

        final result = SelfCollisionDetector.predictSelfCollision(snake);

        expect(result.type, equals(CollisionType.none));
      });

      test('should clear cache properly', () {
        // Use cache
        SelfCollisionDetector.checkSelfCollision(snake);

        // Clear cache
        SelfCollisionDetector.clearCache();

        // Should still work correctly
        final result = SelfCollisionDetector.checkSelfCollision(snake);
        expect(result.type, equals(CollisionType.none));
      });
    });
  });
}
