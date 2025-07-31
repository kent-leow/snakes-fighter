import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_utils.dart';

void main() {
  group('Direction', () {
    test('should have correct delta values', () {
      expect(Direction.up.delta, equals(const Position(0, -1)));
      expect(Direction.right.delta, equals(const Position(1, 0)));
      expect(Direction.down.delta, equals(const Position(0, 1)));
      expect(Direction.left.delta, equals(const Position(-1, 0)));
    });

    test('should have correct names', () {
      expect(Direction.up.name, equals('Up'));
      expect(Direction.right.name, equals('Right'));
      expect(Direction.down.name, equals('Down'));
      expect(Direction.left.name, equals('Left'));
    });

    test('should return correct opposite directions', () {
      expect(Direction.up.opposite, equals(Direction.down));
      expect(Direction.down.opposite, equals(Direction.up));
      expect(Direction.left.opposite, equals(Direction.right));
      expect(Direction.right.opposite, equals(Direction.left));
    });

    test('should return correct clockwise directions', () {
      expect(Direction.up.clockwise, equals(Direction.right));
      expect(Direction.right.clockwise, equals(Direction.down));
      expect(Direction.down.clockwise, equals(Direction.left));
      expect(Direction.left.clockwise, equals(Direction.up));
    });

    test('should return correct counter-clockwise directions', () {
      expect(Direction.up.counterClockwise, equals(Direction.left));
      expect(Direction.left.counterClockwise, equals(Direction.down));
      expect(Direction.down.counterClockwise, equals(Direction.right));
      expect(Direction.right.counterClockwise, equals(Direction.up));
    });
  });

  group('GridUtils', () {
    group('distance calculations', () {
      test('should calculate Euclidean distance correctly', () {
        const pos1 = Position(0, 0);
        const pos2 = Position(3, 4);
        final distance = GridUtils.calculateDistance(pos1, pos2);

        expect(distance, equals(5.0));
      });

      test('should calculate Manhattan distance correctly', () {
        const pos1 = Position(1, 1);
        const pos2 = Position(4, 5);
        final distance = GridUtils.calculateManhattanDistance(pos1, pos2);

        expect(distance, equals(7));
      });

      test('should calculate zero distance for same position', () {
        const position = Position(5, 5);
        expect(GridUtils.calculateDistance(position, position), equals(0.0));
        expect(
          GridUtils.calculateManhattanDistance(position, position),
          equals(0),
        );
      });
    });

    group('getPositionsInRadius', () {
      test('should return positions within Euclidean radius', () {
        const center = Position(5, 5);
        final positions = GridUtils.getPositionsInRadius(center, 2.0, 10, 10);

        // Should include center and immediate neighbors
        expect(positions, contains(center));
        expect(positions, contains(const Position(4, 5)));
        expect(positions, contains(const Position(6, 5)));
        expect(positions, contains(const Position(5, 4)));
        expect(positions, contains(const Position(5, 6)));

        // Should not include positions too far away
        expect(positions, isNot(contains(const Position(2, 5))));
        expect(positions, isNot(contains(const Position(8, 5))));
      });

      test('should respect grid boundaries', () {
        const center = Position(0, 0);
        final positions = GridUtils.getPositionsInRadius(center, 2.0, 10, 10);

        // Should not include negative positions
        expect(positions.every((pos) => pos.x >= 0 && pos.y >= 0), isTrue);
      });

      test('should return empty list for zero radius', () {
        const center = Position(5, 5);
        final positions = GridUtils.getPositionsInRadius(center, 0.0, 10, 10);

        expect(positions, contains(center)); // Center should be included
        expect(positions, hasLength(1));
      });
    });

    group('getPositionsInManhattanRadius', () {
      test('should return positions within Manhattan radius', () {
        const center = Position(5, 5);
        final positions = GridUtils.getPositionsInManhattanRadius(
          center,
          1,
          10,
          10,
        );

        expect(positions, hasLength(5)); // center + 4 neighbors
        expect(positions, contains(center));
        expect(positions, contains(const Position(4, 5)));
        expect(positions, contains(const Position(6, 5)));
        expect(positions, contains(const Position(5, 4)));
        expect(positions, contains(const Position(5, 6)));
      });

      test('should respect grid boundaries', () {
        const center = Position(0, 0);
        final positions = GridUtils.getPositionsInManhattanRadius(
          center,
          2,
          10,
          10,
        );

        expect(positions.every((pos) => pos.x >= 0 && pos.y >= 0), isTrue);
        expect(positions.every((pos) => pos.x < 10 && pos.y < 10), isTrue);
      });
    });

    group('getRandomEmptyPosition', () {
      test('should return random empty position', () {
        final occupied = [const Position(0, 0), const Position(1, 1)];
        final random = math.Random(42); // Fixed seed for reproducible tests

        final emptyPos = GridUtils.getRandomEmptyPosition(
          occupied,
          5,
          5,
          random,
        );

        expect(emptyPos, isNotNull);
        expect(occupied, isNot(contains(emptyPos)));
      });

      test('should return null when grid is full', () {
        final occupied = <Position>[];
        for (int y = 0; y < 3; y++) {
          for (int x = 0; x < 3; x++) {
            occupied.add(Position(x, y));
          }
        }

        final emptyPos = GridUtils.getRandomEmptyPosition(occupied, 3, 3);
        expect(emptyPos, isNull);
      });

      test('should work with empty occupied list', () {
        final emptyPos = GridUtils.getRandomEmptyPosition([], 5, 5);

        expect(emptyPos, isNotNull);
        expect(emptyPos!.x, greaterThanOrEqualTo(0));
        expect(emptyPos.x, lessThan(5));
        expect(emptyPos.y, greaterThanOrEqualTo(0));
        expect(emptyPos.y, lessThan(5));
      });
    });

    group('getDirectionBetween', () {
      test('should return correct direction for aligned positions', () {
        const from = Position(5, 5);

        expect(
          GridUtils.getDirectionBetween(from, const Position(5, 4)),
          equals(Direction.up),
        );
        expect(
          GridUtils.getDirectionBetween(from, const Position(6, 5)),
          equals(Direction.right),
        );
        expect(
          GridUtils.getDirectionBetween(from, const Position(5, 6)),
          equals(Direction.down),
        );
        expect(
          GridUtils.getDirectionBetween(from, const Position(4, 5)),
          equals(Direction.left),
        );
      });

      test('should return dominant direction for diagonal positions', () {
        const from = Position(5, 5);

        // More horizontal movement
        expect(
          GridUtils.getDirectionBetween(from, const Position(8, 6)),
          equals(Direction.right),
        );
        expect(
          GridUtils.getDirectionBetween(from, const Position(2, 6)),
          equals(Direction.left),
        );

        // More vertical movement
        expect(
          GridUtils.getDirectionBetween(from, const Position(6, 2)),
          equals(Direction.up),
        );
        expect(
          GridUtils.getDirectionBetween(from, const Position(6, 8)),
          equals(Direction.down),
        );
      });

      test('should handle same position', () {
        const position = Position(5, 5);

        // Should return one of the directions (implementation specific)
        final direction = GridUtils.getDirectionBetween(position, position);
        expect(direction, isNotNull);
      });
    });

    group('getLineBetween', () {
      test('should return horizontal line', () {
        const start = Position(2, 5);
        const end = Position(5, 5);
        final line = GridUtils.getLineBetween(start, end);

        expect(line, hasLength(4));
        expect(line, contains(const Position(2, 5)));
        expect(line, contains(const Position(3, 5)));
        expect(line, contains(const Position(4, 5)));
        expect(line, contains(const Position(5, 5)));
      });

      test('should return vertical line', () {
        const start = Position(5, 2);
        const end = Position(5, 5);
        final line = GridUtils.getLineBetween(start, end);

        expect(line, hasLength(4));
        expect(line, contains(const Position(5, 2)));
        expect(line, contains(const Position(5, 3)));
        expect(line, contains(const Position(5, 4)));
        expect(line, contains(const Position(5, 5)));
      });

      test('should return diagonal line', () {
        const start = Position(2, 2);
        const end = Position(4, 4);
        final line = GridUtils.getLineBetween(start, end);

        expect(line, hasLength(3));
        expect(line, contains(const Position(2, 2)));
        expect(line, contains(const Position(3, 3)));
        expect(line, contains(const Position(4, 4)));
      });

      test('should return single position for same start and end', () {
        const position = Position(5, 5);
        final line = GridUtils.getLineBetween(position, position);

        expect(line, hasLength(1));
        expect(line, contains(position));
      });
    });

    group('findShortestPath', () {
      test('should find direct path when no obstacles', () {
        const start = Position(0, 0);
        const end = Position(2, 0);
        final path = GridUtils.findShortestPath(
          start,
          end,
          10,
          10,
          <Position>{},
        );

        expect(path, hasLength(3));
        expect(path.first, equals(start));
        expect(path.last, equals(end));
      });

      test('should find path around obstacles', () {
        const start = Position(0, 0);
        const end = Position(2, 0);
        final obstacles = {const Position(1, 0)}; // Block direct path

        final path = GridUtils.findShortestPath(start, end, 10, 10, obstacles);

        expect(path, isNotEmpty);
        expect(path.first, equals(start));
        expect(path.last, equals(end));
        expect(path.any((pos) => obstacles.contains(pos)), isFalse);
      });

      test('should return empty path when no path exists', () {
        const start = Position(0, 0);
        const end = Position(2, 0);
        final obstacles = {
          const Position(1, 0),
          const Position(0, 1),
          const Position(1, 1),
        }; // Surround start position

        final path = GridUtils.findShortestPath(start, end, 3, 3, obstacles);
        expect(path, isEmpty);
      });

      test('should return start position when start equals end', () {
        const position = Position(5, 5);
        final path = GridUtils.findShortestPath(
          position,
          position,
          10,
          10,
          <Position>{},
        );

        expect(path, hasLength(1));
        expect(path.first, equals(position));
      });

      test('should return empty path when start is blocked', () {
        const start = Position(5, 5);
        const end = Position(7, 5);
        final obstacles = {start};

        final path = GridUtils.findShortestPath(start, end, 10, 10, obstacles);
        expect(path, isEmpty);
      });
    });

    group('getRectanglePerimeter', () {
      test('should return rectangle perimeter positions', () {
        const topLeft = Position(1, 1);
        const bottomRight = Position(3, 3);
        final perimeter = GridUtils.getRectanglePerimeter(topLeft, bottomRight);

        // Should have 8 positions for a 3x3 rectangle perimeter
        expect(perimeter, hasLength(8));

        // Check corners
        expect(perimeter, contains(const Position(1, 1))); // top-left
        expect(perimeter, contains(const Position(3, 1))); // top-right
        expect(perimeter, contains(const Position(1, 3))); // bottom-left
        expect(perimeter, contains(const Position(3, 3))); // bottom-right

        // Check edges
        expect(perimeter, contains(const Position(2, 1))); // top edge
        expect(perimeter, contains(const Position(2, 3))); // bottom edge
        expect(perimeter, contains(const Position(1, 2))); // left edge
        expect(perimeter, contains(const Position(3, 2))); // right edge
      });

      test('should handle single point rectangle', () {
        const position = Position(5, 5);
        final perimeter = GridUtils.getRectanglePerimeter(position, position);

        expect(perimeter, hasLength(1));
        expect(perimeter, contains(position));
      });

      test('should handle horizontal line rectangle', () {
        const topLeft = Position(1, 5);
        const bottomRight = Position(3, 5);
        final perimeter = GridUtils.getRectanglePerimeter(topLeft, bottomRight);

        expect(perimeter, hasLength(3));
        expect(perimeter, contains(const Position(1, 5)));
        expect(perimeter, contains(const Position(2, 5)));
        expect(perimeter, contains(const Position(3, 5)));
      });
    });

    group('calculateCenter', () {
      test('should calculate center of positions', () {
        final positions = [
          const Position(0, 0),
          const Position(4, 0),
          const Position(0, 4),
          const Position(4, 4),
        ];

        final center = GridUtils.calculateCenter(positions);
        expect(center, equals(const Position(2, 2)));
      });

      test('should handle single position', () {
        final positions = [const Position(5, 7)];
        final center = GridUtils.calculateCenter(positions);

        expect(center, equals(const Position(5, 7)));
      });

      test('should return origin for empty list', () {
        final center = GridUtils.calculateCenter([]);
        expect(center, equals(const Position(0, 0)));
      });

      test('should handle odd position counts', () {
        final positions = [
          const Position(0, 0),
          const Position(2, 0),
          const Position(1, 2),
        ];

        final center = GridUtils.calculateCenter(positions);
        expect(center, equals(const Position(1, 0))); // (0+2+1)/3, (0+0+2)/3
      });
    });
  });
}
