import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/core.dart';

void main() {
  group('Grid System Integration Tests', () {
    test('should integrate all grid components correctly', () {
      // Create a grid system
      final gridSystem = GridSystem.adaptive(
        gridWidth: GridConstants.defaultGridWidth,
        gridHeight: GridConstants.defaultGridHeight,
        screenWidth: 800.0,
        screenHeight: 600.0,
      );

      // Validate grid system configuration
      expect(
        GridValidator.isValidGridSize(
          gridSystem.gridWidth,
          gridSystem.gridHeight,
        ),
        isTrue,
      );
      expect(GridValidator.isValidCellSize(gridSystem.cellSize), isTrue);

      // Test coordinate conversions work with validation
      const testPosition = Position(10, 10);
      expect(gridSystem.isValidPosition(testPosition), isTrue);
      expect(
        GridValidator.isInBounds(
          testPosition,
          gridSystem.gridWidth,
          gridSystem.gridHeight,
        ),
        isTrue,
      );

      // Test screen coordinate conversion round trip
      final screenPos = gridSystem.gridToScreen(testPosition);
      final convertedBack = gridSystem.screenToGrid(screenPos);
      expect(convertedBack, equals(testPosition));

      // Test utilities work with grid system
      final randomPos = gridSystem.getRandomPosition();
      expect(gridSystem.isValidPosition(randomPos), isTrue);

      final neighbors = randomPos.getNeighbors();
      final validNeighbors = GridValidator.filterValidPositions(
        neighbors,
        gridSystem.gridWidth,
        gridSystem.gridHeight,
      );
      expect(validNeighbors.length, lessThanOrEqualTo(4));

      // Test pathfinding works with grid boundaries
      const start = Position(0, 0);
      const end = Position(5, 5);
      final path = GridUtils.findShortestPath(
        start,
        end,
        gridSystem.gridWidth,
        gridSystem.gridHeight,
        <Position>{},
      );
      expect(path, isNotEmpty);
      expect(path.first, equals(start));
      expect(path.last, equals(end));
      expect(
        GridValidator.areAllPositionsValid(
          path,
          gridSystem.gridWidth,
          gridSystem.gridHeight,
        ),
        isTrue,
      );
    });

    test('should handle edge cases correctly', () {
      // Test minimum grid size
      final minGridSystem = GridSystem(
        gridWidth: GridConstants.minGridWidth,
        gridHeight: GridConstants.minGridHeight,
        cellSize: GridConstants.minCellSize,
        screenWidth: 400.0,
        screenHeight: 400.0,
      );

      expect(minGridSystem.isValidPosition(const Position(0, 0)), isTrue);
      expect(
        minGridSystem.isValidPosition(
          const Position(
            GridConstants.minGridWidth - 1,
            GridConstants.minGridHeight - 1,
          ),
        ),
        isTrue,
      );
      expect(
        minGridSystem.isValidPosition(
          const Position(
            GridConstants.minGridWidth,
            GridConstants.minGridHeight,
          ),
        ),
        isFalse,
      );

      // Test boundary positions
      final borderPositions = minGridSystem.getBorderPositions();
      expect(borderPositions, isNotEmpty);
      for (final pos in borderPositions) {
        expect(
          GridValidator.isOnBorder(
            pos,
            minGridSystem.gridWidth,
            minGridSystem.gridHeight,
          ),
          isTrue,
        );
      }
    });

    test('should maintain consistency across operations', () {
      final gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 20,
        cellSize: 25.0,
        screenWidth: 800.0,
        screenHeight: 600.0,
      );

      // Generate multiple random positions and verify they're all valid
      final randomPositions = List.generate(
        100,
        (_) => gridSystem.getRandomPosition(),
      );

      expect(
        GridValidator.areAllPositionsValid(
          randomPositions,
          gridSystem.gridWidth,
          gridSystem.gridHeight,
        ),
        isTrue,
      );

      // Test distance calculations are consistent
      const pos1 = Position(5, 5);
      const pos2 = Position(10, 10);

      final euclideanDistance = GridUtils.calculateDistance(pos1, pos2);
      final manhattanDistance = GridUtils.calculateManhattanDistance(
        pos1,
        pos2,
      );

      expect(euclideanDistance, equals(pos1.distanceTo(pos2)));
      expect(manhattanDistance, equals(pos1.manhattanDistanceTo(pos2)));
      expect(manhattanDistance, greaterThanOrEqualTo(euclideanDistance));
    });
  });
}
