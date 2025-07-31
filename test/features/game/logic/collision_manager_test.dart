import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/logic/collision_manager.dart';
import 'package:snakes_fight/features/game/logic/self_collision_detector.dart';
import 'package:snakes_fight/features/game/models/collision_context.dart';
import 'package:snakes_fight/features/game/models/collision.dart';
import 'package:snakes_fight/features/game/models/snake.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/food.dart';
import 'package:snakes_fight/core/models/position.dart';

void main() {
  group('CollisionManager', () {
    late Snake snake;
    late CollisionContext context;

    setUp(() {
      snake = Snake(
        initialPosition: const Position(5, 5),
        initialDirection: Direction.right,
      );

      context = CollisionContext(
        snake: snake,
        gameArea: const GameAreaSize(10, 10),
        foods: [],
        frameNumber: 0,
        timestamp: DateTime.now(),
      );

      // Reset profiler for clean tests
      CollisionManager.resetProfiler();
    });

    tearDown(() {
      CollisionManager.clearCaches();
    });

    group('checkAllCollisions', () {
      test('should return no collision for safe position', () {
        final result = CollisionManager.checkAllCollisions(context);

        expect(result.type, equals(CollisionType.none));
        expect(result.isGameEnding, isFalse);
        expect(result.detectionTime, isA<double>());
      });

      test('should prioritize wall collision over other collisions', () {
        // Create context where snake would hit wall
        final wallContext = context.copyWith(
          snake: Snake(
            initialPosition: const Position(9, 5),
            initialDirection: Direction.right,
            initialLength: 1,
          ),
        );

        final result = CollisionManager.checkAllCollisions(wallContext);

        expect(result.type, equals(CollisionType.wall));
        expect(result.isGameEnding, isTrue);
      });

      test(
        'should detect self collision when wall collision is not present',
        () {
          // Create a snake and make it grow to enable proper collision scenario
          final selfCollisionSnake = Snake(
            initialPosition: const Position(5, 5),
            initialDirection: Direction.right,
            initialLength: 4,
          );

          // Make snake grow to create longer body for collision
          selfCollisionSnake.grow();
          selfCollisionSnake.move(); // (6, 5) - grows to 5 segments

          // Create U-turn collision scenario
          selfCollisionSnake.changeDirection(Direction.down);
          selfCollisionSnake.move(); // (6, 6)
          selfCollisionSnake.changeDirection(Direction.left);
          selfCollisionSnake.move(); // (5, 6)
          selfCollisionSnake.changeDirection(Direction.up);
          // Next position (5, 5) should collide with body segment

          final selfContext = context.copyWith(snake: selfCollisionSnake);
          final result = CollisionManager.checkAllCollisions(selfContext);

          expect(result.type, equals(CollisionType.selfCollision));
          expect(result.isGameEnding, isTrue);
        },
      );

      test(
        'should detect food collision when no game-ending collisions occur',
        () {
          final food = Food(position: const Position(6, 5));
          final foodContext = context.copyWith(foods: [food]);

          final result = CollisionManager.checkAllCollisions(foodContext);

          expect(result.type, equals(CollisionType.food));
          expect(result.isGameEnding, isFalse);
          expect(result.collisionPoint, equals(const Position(6, 5)));
        },
      );

      test('should record collision in profiler', () {
        CollisionManager.checkAllCollisions(context);

        final profiler = CollisionManager.profiler;
        expect(profiler.totalChecks, greaterThan(0));
        expect(profiler.averageDetectionTime, isA<double>());
      });
    });

    group('individual collision methods', () {
      test('checkWallCollision should work correctly', () {
        final result = CollisionManager.checkWallCollision(context);

        expect(result.type, equals(CollisionType.none));
        expect(result.detectionTime, lessThan(0.1));
      });

      test('checkSelfCollision should work correctly', () {
        final result = CollisionManager.checkSelfCollision(context);

        expect(result.type, equals(CollisionType.none));
        expect(result.detectionTime, lessThan(0.1));
      });

      test('checkFoodCollisions should detect food', () {
        final food = Food(position: const Position(6, 5));
        final foodContext = context.copyWith(foods: [food]);

        final result = CollisionManager.checkFoodCollisions(foodContext);

        expect(result.type, equals(CollisionType.food));
        expect(result.collisionPoint, equals(const Position(6, 5)));
      });

      test('checkFoodCollisions should ignore inactive food', () {
        final food = Food(position: const Position(6, 5));
        food.consume(); // Make inactive
        final foodContext = context.copyWith(foods: [food]);

        final result = CollisionManager.checkFoodCollisions(foodContext);

        expect(result.type, equals(CollisionType.none));
      });
    });

    group('checkCollisionAtPosition', () {
      test('should check collision at specific position', () {
        const testPosition = Position(8, 8);
        final result = CollisionManager.checkCollisionAtPosition(
          context,
          testPosition,
        );

        expect(result.type, equals(CollisionType.none));
      });

      test('should detect wall collision at boundary position', () {
        const wallPosition = Position(-1, 5);
        final result = CollisionManager.checkCollisionAtPosition(
          context,
          wallPosition,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(wallPosition));
      });

      test('should detect self collision at body position', () {
        final bodyPosition = snake.body[1];
        final result = CollisionManager.checkCollisionAtPosition(
          context,
          bodyPosition,
        );

        expect(result.type, equals(CollisionType.selfCollision));
        expect(result.collisionPoint, equals(bodyPosition));
      });
    });

    group('utility methods', () {
      test('wouldCollideInNextMove should predict collision', () {
        final safeResult = CollisionManager.wouldCollideInNextMove(context);
        expect(safeResult, isFalse);

        // Test with wall collision scenario
        final wallContext = context.copyWith(
          snake: Snake(
            initialPosition: const Position(9, 5),
            initialDirection: Direction.right,
            initialLength: 1,
          ),
        );

        final dangerousResult = CollisionManager.wouldCollideInNextMove(
          wallContext,
        );
        expect(dangerousResult, isTrue);
      });

      test('getSafePositions should return valid positions', () {
        final safePositions = CollisionManager.getSafePositions(context);

        expect(safePositions, isNotEmpty);

        // All returned positions should be safe
        for (final position in safePositions) {
          final result = CollisionManager.checkCollisionAtPosition(
            context,
            position,
          );
          expect(result.isGameEnding, isFalse);
        }
      });

      test('getCollisionPositions should return dangerous positions', () {
        final collisionPositions = CollisionManager.getCollisionPositions(
          context,
        );

        expect(collisionPositions, isNotEmpty);

        // Should include out-of-bounds positions
        expect(collisionPositions, contains(const Position(-1, 5)));
        expect(collisionPositions, contains(const Position(10, 5)));

        // Should include snake body positions (excluding head and possibly tail)
        final expectedBodyPositions =
            SelfCollisionDetector.getSelfCollisionPositions(snake);
        for (final bodyPos in expectedBodyPositions) {
          expect(collisionPositions, contains(bodyPos));
        }
      });

      test('checkMultiplePositions should handle batch processing', () {
        final positions = [
          const Position(7, 7), // Safe
          const Position(-1, 5), // Wall
          snake.body[1], // Self collision
        ];

        final results = CollisionManager.checkMultiplePositions(
          context,
          positions,
        );

        expect(results, hasLength(3));
        expect(results[const Position(7, 7)]!.type, equals(CollisionType.none));
        expect(
          results[const Position(-1, 5)]!.type,
          equals(CollisionType.wall),
        );
        expect(
          results[snake.body[1]]!.type,
          equals(CollisionType.selfCollision),
        );
      });
    });

    group('performance monitoring', () {
      test('should track performance metrics', () {
        // Perform several collision checks
        for (int i = 0; i < 10; i++) {
          CollisionManager.checkAllCollisions(context);
        }

        final profiler = CollisionManager.profiler;
        expect(
          profiler.totalChecks,
          greaterThanOrEqualTo(10),
        ); // May be more due to internal checks
        expect(profiler.averageDetectionTime, isA<double>());
        expect(
          profiler.maxDetectionTime,
          greaterThanOrEqualTo(profiler.averageDetectionTime),
        );
        expect(
          profiler.minDetectionTime,
          lessThanOrEqualTo(profiler.averageDetectionTime),
        );
      });

      test('should meet performance requirements', () {
        CollisionManager.checkAllCollisions(context);

        final meetsRequirements =
            CollisionManager.meetsPerformanceRequirements();
        expect(meetsRequirements, isTrue);
      });

      test('should provide performance statistics', () {
        CollisionManager.checkAllCollisions(context);

        final stats = CollisionManager.getPerformanceStats();
        expect(stats, containsPair('timing', isA<Map>()));
        expect(stats, containsPair('throughput', isA<Map>()));
        expect(stats, containsPair('collisions', isA<Map>()));
        expect(stats, containsPair('performance', isA<Map>()));
      });

      test('should reset profiler correctly', () {
        CollisionManager.checkAllCollisions(context);
        expect(CollisionManager.profiler.totalChecks, greaterThan(0));

        CollisionManager.resetProfiler();
        expect(CollisionManager.profiler.totalChecks, equals(0));
      });
    });

    group('stress tests', () {
      test('should handle large snake efficiently', () {
        final largeSnake = Snake(
          initialPosition: const Position(50, 50),
          initialDirection: Direction.right,
          initialLength: 100,
        );

        final largeContext = CollisionContext(
          snake: largeSnake,
          gameArea: const GameAreaSize(100, 100),
          foods: [],
          frameNumber: 1,
          timestamp: DateTime.now(),
        );

        final result = CollisionManager.checkAllCollisions(largeContext);
        expect(result.detectionTime, lessThan(0.1)); // Should still be fast
      });

      test('should handle many food items efficiently', () {
        final manyFoods = List.generate(
          50,
          (i) => Food(position: Position(i % 10, i ~/ 10)),
        );
        final foodContext = context.copyWith(foods: manyFoods);

        final result = CollisionManager.checkAllCollisions(foodContext);
        expect(result.detectionTime, lessThan(0.1));
      });

      test('should maintain performance over many checks', () {
        final times = <double>[];

        for (int i = 0; i < 100; i++) {
          final result = CollisionManager.checkAllCollisions(context);
          times.add(result.detectionTime);
        }

        // Performance should not degrade significantly
        final avgTime = times.reduce((a, b) => a + b) / times.length;
        expect(avgTime, lessThan(0.1));

        // No individual check should be extremely slow
        expect(times.every((time) => time < 0.5), isTrue);
      });
    });

    group('edge cases', () {
      test('should handle empty game area', () {
        final emptyContext = context.copyWith(
          gameArea: const GameAreaSize(0, 0),
        );
        final result = CollisionManager.checkAllCollisions(emptyContext);

        expect(result.type, equals(CollisionType.wall));
      });

      test('should handle single-cell game area', () {
        final tinyContext = context.copyWith(
          gameArea: const GameAreaSize(1, 1),
          snake: Snake(
            initialPosition: const Position(0, 0),
            initialDirection: Direction.right,
            initialLength: 1,
          ),
        );

        final result = CollisionManager.checkAllCollisions(tinyContext);
        expect(
          result.type,
          equals(CollisionType.wall),
        ); // Next move would be out of bounds
      });
    });
  });
}
