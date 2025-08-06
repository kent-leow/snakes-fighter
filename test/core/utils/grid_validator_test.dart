import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_validator.dart';

void main() {
  group('GridValidator', () {
    group('isInBounds', () {
      test('should validate positions within bounds', () {
        expect(GridValidator.isInBounds(const Position(0, 0), 10, 10), isTrue);
        expect(GridValidator.isInBounds(const Position(5, 5), 10, 10), isTrue);
        expect(GridValidator.isInBounds(const Position(9, 9), 10, 10), isTrue);
      });

      test('should invalidate positions outside bounds', () {
        expect(
          GridValidator.isInBounds(const Position(-1, 0), 10, 10),
          isFalse,
        );
        expect(
          GridValidator.isInBounds(const Position(0, -1), 10, 10),
          isFalse,
        );
        expect(
          GridValidator.isInBounds(const Position(10, 0), 10, 10),
          isFalse,
        );
        expect(
          GridValidator.isInBounds(const Position(0, 10), 10, 10),
          isFalse,
        );
        expect(
          GridValidator.isInBounds(const Position(15, 15), 10, 10),
          isFalse,
        );
      });

      test('should handle edge cases', () {
        expect(GridValidator.isInBounds(const Position(0, 0), 1, 1), isTrue);
        expect(GridValidator.isInBounds(const Position(1, 1), 1, 1), isFalse);
      });
    });

    group('isValidGridSize', () {
      test('should validate grid sizes within limits', () {
        expect(GridValidator.isValidGridSize(10, 10), isTrue);
        expect(GridValidator.isValidGridSize(25, 25), isTrue);
        expect(GridValidator.isValidGridSize(50, 50), isTrue);
      });

      test('should invalidate grid sizes outside limits', () {
        expect(
          GridValidator.isValidGridSize(5, 10),
          isFalse,
        ); // too small width
        expect(
          GridValidator.isValidGridSize(10, 5),
          isFalse,
        ); // too small height
        expect(
          GridValidator.isValidGridSize(60, 25),
          isFalse,
        ); // too large width
        expect(
          GridValidator.isValidGridSize(25, 60),
          isFalse,
        ); // too large height
      });

      test('should validate boundary values', () {
        expect(GridValidator.isValidGridSize(10, 10), isTrue); // minimum
        expect(GridValidator.isValidGridSize(50, 50), isTrue); // maximum
        expect(
          GridValidator.isValidGridSize(9, 10),
          isFalse,
        ); // just below minimum
        expect(
          GridValidator.isValidGridSize(51, 50),
          isFalse,
        ); // just above maximum
      });
    });

    group('isValidCellSize', () {
      test('should validate cell sizes within limits', () {
        expect(GridValidator.isValidCellSize(15.0), isTrue); // minimum
        expect(GridValidator.isValidCellSize(20.0), isTrue); // middle
        expect(GridValidator.isValidCellSize(30.0), isTrue); // maximum
      });

      test('should invalidate cell sizes outside limits', () {
        expect(GridValidator.isValidCellSize(14.9), isFalse); // below minimum
        expect(GridValidator.isValidCellSize(30.1), isFalse); // above maximum
        expect(GridValidator.isValidCellSize(0.0), isFalse); // zero
        expect(GridValidator.isValidCellSize(-5.0), isFalse); // negative
      });
    });

    group('filterValidPositions', () {
      test('should filter out invalid positions', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(-1, 0), // invalid
          const Position(0, -1), // invalid
          const Position(10, 0), // invalid
          const Position(9, 9),
        ];

        final filtered = GridValidator.filterValidPositions(positions, 10, 10);

        expect(filtered, hasLength(3));
        expect(filtered, contains(const Position(0, 0)));
        expect(filtered, contains(const Position(5, 5)));
        expect(filtered, contains(const Position(9, 9)));
        expect(filtered, isNot(contains(const Position(-1, 0))));
        expect(filtered, isNot(contains(const Position(0, -1))));
        expect(filtered, isNot(contains(const Position(10, 0))));
      });

      test('should return empty list for all invalid positions', () {
        final positions = [
          const Position(-1, 0),
          const Position(0, -1),
          const Position(10, 0),
          const Position(0, 10),
        ];

        final filtered = GridValidator.filterValidPositions(positions, 10, 10);
        expect(filtered, isEmpty);
      });

      test('should return all positions when all are valid', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(9, 9),
        ];

        final filtered = GridValidator.filterValidPositions(positions, 10, 10);
        expect(filtered, hasLength(3));
        expect(filtered, equals(positions));
      });
    });

    group('isOnBorder', () {
      test('should detect border positions', () {
        expect(
          GridValidator.isOnBorder(const Position(0, 0), 10, 10),
          isTrue,
        ); // corner
        expect(
          GridValidator.isOnBorder(const Position(0, 5), 10, 10),
          isTrue,
        ); // left edge
        expect(
          GridValidator.isOnBorder(const Position(9, 5), 10, 10),
          isTrue,
        ); // right edge
        expect(
          GridValidator.isOnBorder(const Position(5, 0), 10, 10),
          isTrue,
        ); // top edge
        expect(
          GridValidator.isOnBorder(const Position(5, 9), 10, 10),
          isTrue,
        ); // bottom edge
      });

      test('should not detect internal positions as border', () {
        expect(GridValidator.isOnBorder(const Position(5, 5), 10, 10), isFalse);
        expect(GridValidator.isOnBorder(const Position(1, 1), 10, 10), isFalse);
        expect(GridValidator.isOnBorder(const Position(8, 8), 10, 10), isFalse);
      });

      test('should return false for out-of-bounds positions', () {
        expect(
          GridValidator.isOnBorder(const Position(-1, 0), 10, 10),
          isFalse,
        );
        expect(
          GridValidator.isOnBorder(const Position(10, 5), 10, 10),
          isFalse,
        );
      });
    });

    group('isInCorner', () {
      test('should detect corner positions', () {
        expect(
          GridValidator.isInCorner(const Position(0, 0), 10, 10),
          isTrue,
        ); // top-left
        expect(
          GridValidator.isInCorner(const Position(9, 0), 10, 10),
          isTrue,
        ); // top-right
        expect(
          GridValidator.isInCorner(const Position(0, 9), 10, 10),
          isTrue,
        ); // bottom-left
        expect(
          GridValidator.isInCorner(const Position(9, 9), 10, 10),
          isTrue,
        ); // bottom-right
      });

      test('should not detect edge positions as corners', () {
        expect(
          GridValidator.isInCorner(const Position(5, 0), 10, 10),
          isFalse,
        ); // top edge
        expect(
          GridValidator.isInCorner(const Position(0, 5), 10, 10),
          isFalse,
        ); // left edge
        expect(
          GridValidator.isInCorner(const Position(9, 5), 10, 10),
          isFalse,
        ); // right edge
        expect(
          GridValidator.isInCorner(const Position(5, 9), 10, 10),
          isFalse,
        ); // bottom edge
      });

      test('should not detect internal positions as corners', () {
        expect(GridValidator.isInCorner(const Position(5, 5), 10, 10), isFalse);
        expect(GridValidator.isInCorner(const Position(1, 1), 10, 10), isFalse);
      });
    });

    group('areAllPositionsValid', () {
      test('should return true when all positions are valid', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(9, 9),
        ];

        expect(GridValidator.areAllPositionsValid(positions, 10, 10), isTrue);
      });

      test('should return false when any position is invalid', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(10, 0), // invalid
        ];

        expect(GridValidator.areAllPositionsValid(positions, 10, 10), isFalse);
      });

      test('should return true for empty list', () {
        expect(GridValidator.areAllPositionsValid([], 10, 10), isTrue);
      });
    });

    group('hasDuplicatePositions', () {
      test('should detect duplicate positions', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(0, 0), // duplicate
        ];

        expect(GridValidator.hasDuplicatePositions(positions), isTrue);
      });

      test('should return false for unique positions', () {
        final positions = [
          const Position(0, 0),
          const Position(5, 5),
          const Position(9, 9),
        ];

        expect(GridValidator.hasDuplicatePositions(positions), isFalse);
      });

      test('should return false for empty list', () {
        expect(GridValidator.hasDuplicatePositions([]), isFalse);
      });

      test('should return false for single position', () {
        expect(
          GridValidator.hasDuplicatePositions([const Position(5, 5)]),
          isFalse,
        );
      });
    });

    group('isValidPath', () {
      test('should validate continuous path', () {
        final path = [
          const Position(0, 0),
          const Position(1, 0),
          const Position(2, 0),
          const Position(2, 1),
        ];

        expect(GridValidator.isValidPath(path), isTrue);
      });

      test('should invalidate discontinuous path', () {
        final path = [
          const Position(0, 0),
          const Position(1, 0),
          const Position(3, 0), // gap
        ];

        expect(GridValidator.isValidPath(path), isFalse);
      });

      test('should invalidate diagonal path', () {
        final path = [
          const Position(0, 0),
          const Position(1, 1), // diagonal
        ];

        expect(GridValidator.isValidPath(path), isFalse);
      });

      test('should return true for single position', () {
        expect(GridValidator.isValidPath([const Position(0, 0)]), isTrue);
      });

      test('should return true for empty path', () {
        expect(GridValidator.isValidPath([]), isTrue);
      });
    });

    group('isValidScreenSize', () {
      test('should validate sufficient screen sizes', () {
        expect(GridValidator.isValidScreenSize(800.0, 600.0), isTrue);
        expect(GridValidator.isValidScreenSize(1024.0, 768.0), isTrue);
      });

      test('should invalidate insufficient screen sizes', () {
        expect(GridValidator.isValidScreenSize(300.0, 200.0), isFalse);
        expect(GridValidator.isValidScreenSize(400.0, 250.0), isFalse);
      });
    });

    group('isValidRegion', () {
      test('should validate proper rectangles', () {
        expect(
          GridValidator.isValidRegion(
            const Position(2, 2),
            const Position(5, 5),
            10,
            10,
          ),
          isTrue,
        );

        expect(
          GridValidator.isValidRegion(
            const Position(0, 0),
            const Position(9, 9),
            10,
            10,
          ),
          isTrue,
        );
      });

      test('should invalidate improper rectangles', () {
        // topLeft after bottomRight
        expect(
          GridValidator.isValidRegion(
            const Position(5, 5),
            const Position(2, 2),
            10,
            10,
          ),
          isFalse,
        );

        // out of bounds
        expect(
          GridValidator.isValidRegion(
            const Position(5, 5),
            const Position(15, 15),
            10,
            10,
          ),
          isFalse,
        );
      });

      test('should validate single point region', () {
        expect(
          GridValidator.isValidRegion(
            const Position(5, 5),
            const Position(5, 5),
            10,
            10,
          ),
          isTrue,
        );
      });
    });
  });
}
