import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/logic/wall_collision_detector.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/models/collision.dart';
import 'package:snakes_fight/features/game/models/collision_context.dart';

void main() {
  group('WallCollisionDetector', () {
    const gameArea = GameAreaSize(10, 10);

    group('checkWallCollision', () {
      test('should detect no collision for position within bounds', () {
        const position = Position(5, 5);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.none));
        expect(result.collisionPoint, isNull);
        expect(result.isGameEnding, isFalse);
        expect(result.detectionTime, isA<double>());
        expect(result.detectionTime, lessThan(1.0)); // Relaxed for debug builds
      });

      test('should detect collision when x is negative', () {
        const position = Position(-1, 5);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.detectionTime, lessThan(0.1));
      });

      test('should detect collision when x exceeds width', () {
        const position = Position(10, 5);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['boundary_violated'], contains('right'));
      });

      test('should detect collision when y is negative', () {
        const position = Position(5, -1);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['boundary_violated'], contains('top'));
      });

      test('should detect collision when y exceeds height', () {
        const position = Position(5, 10);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.collisionPoint, equals(position));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['boundary_violated'], contains('bottom'));
      });

      test('should detect corner collision', () {
        const position = Position(-1, -1);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.isGameEnding, isTrue);
        expect(result.metadata['boundary_violated'], contains('left'));
        expect(result.metadata['boundary_violated'], contains('top'));
      });
    });

    group('performance tests', () {
      test(
        'should meet performance requirements for single collision check',
        () {
          const position = Position(5, 5);
          final result = WallCollisionDetector.checkWallCollision(
            position,
            gameArea,
          );

          expect(
            result.detectionTime,
            lessThan(1.0),
          ); // Relaxed for debug builds
        },
      );

      test(
        'should meet performance requirements for batch collision check',
        () {
          final positions = [
            const Position(0, 0),
            const Position(5, 5),
            const Position(9, 9),
            const Position(-1, 5),
            const Position(10, 5),
          ];

          final results = WallCollisionDetector.checkMultiplePositions(
            positions,
            gameArea,
          );

          expect(results, hasLength(positions.length));

          // All individual detection times should be fast
          for (final result in results.values) {
            expect(
              result.detectionTime,
              lessThan(1.0),
            ); // Relaxed for debug builds
          }
        },
      );
    });

    group('utility methods', () {
      test('isPositionOutOfBounds should work correctly', () {
        expect(
          WallCollisionDetector.isPositionOutOfBounds(
            const Position(5, 5),
            gameArea,
          ),
          isFalse,
        );
        expect(
          WallCollisionDetector.isPositionOutOfBounds(
            const Position(-1, 5),
            gameArea,
          ),
          isTrue,
        );
        expect(
          WallCollisionDetector.isPositionOutOfBounds(
            const Position(10, 5),
            gameArea,
          ),
          isTrue,
        );
        expect(
          WallCollisionDetector.isPositionOutOfBounds(
            const Position(5, -1),
            gameArea,
          ),
          isTrue,
        );
        expect(
          WallCollisionDetector.isPositionOutOfBounds(
            const Position(5, 10),
            gameArea,
          ),
          isTrue,
        );
      });

      test('isPositionInBounds should work correctly', () {
        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(5, 5),
            gameArea,
          ),
          isTrue,
        );
        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(-1, 5),
            gameArea,
          ),
          isFalse,
        );
        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(10, 5),
            gameArea,
          ),
          isFalse,
        );
      });

      test('getDistanceToNearestBoundary should calculate correctly', () {
        expect(
          WallCollisionDetector.getDistanceToNearestBoundary(
            const Position(0, 0),
            gameArea,
          ),
          equals(0.0),
        );
        expect(
          WallCollisionDetector.getDistanceToNearestBoundary(
            const Position(1, 1),
            gameArea,
          ),
          equals(1.0),
        );
        expect(
          WallCollisionDetector.getDistanceToNearestBoundary(
            const Position(5, 5),
            gameArea,
          ),
          equals(4.0),
        );
        expect(
          WallCollisionDetector.getDistanceToNearestBoundary(
            const Position(9, 9),
            gameArea,
          ),
          equals(0.0),
        );
      });

      test('getBoundaryPositions should return all boundary positions', () {
        const smallArea = GameAreaSize(3, 3);
        final boundaries = WallCollisionDetector.getBoundaryPositions(
          smallArea,
        );

        // Should include all perimeter positions
        expect(boundaries, contains(const Position(0, 0))); // Top-left corner
        expect(boundaries, contains(const Position(1, 0))); // Top edge
        expect(boundaries, contains(const Position(2, 0))); // Top-right corner
        expect(boundaries, contains(const Position(0, 1))); // Left edge
        expect(boundaries, contains(const Position(2, 1))); // Right edge
        expect(
          boundaries,
          contains(const Position(0, 2)),
        ); // Bottom-left corner
        expect(boundaries, contains(const Position(1, 2))); // Bottom edge
        expect(
          boundaries,
          contains(const Position(2, 2)),
        ); // Bottom-right corner

        // Should not include center position
        expect(boundaries, isNot(contains(const Position(1, 1))));

        // Total boundary positions = 2*width + 2*(height-2) for rectangular area
        expect(boundaries.length, equals(8));
      });
    });

    group('edge cases', () {
      test('should handle 1x1 game area', () {
        const tinyArea = GameAreaSize(1, 1);

        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(0, 0),
            tinyArea,
          ),
          isTrue,
        );
        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(1, 0),
            tinyArea,
          ),
          isFalse,
        );
        expect(
          WallCollisionDetector.isPositionInBounds(
            const Position(0, 1),
            tinyArea,
          ),
          isFalse,
        );
      });

      test('should handle large coordinates', () {
        const position = Position(1000000, 1000000);
        final result = WallCollisionDetector.checkWallCollision(
          position,
          gameArea,
        );

        expect(result.type, equals(CollisionType.wall));
        expect(result.isGameEnding, isTrue);
      });

      test('should handle zero-sized game area', () {
        const emptyArea = GameAreaSize(0, 0);
        const position = Position(0, 0);

        final result = WallCollisionDetector.checkWallCollision(
          position,
          emptyArea,
        );
        expect(result.type, equals(CollisionType.wall));
      });
    });
  });
}
