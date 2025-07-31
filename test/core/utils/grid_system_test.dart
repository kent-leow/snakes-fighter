import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';

void main() {
  group('GridSystem', () {
    test('should create grid system with correct parameters', () {
      final gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 20,
        cellSize: 25.0,
        screenWidth: 800.0,
        screenHeight: 600.0,
      );

      expect(gridSystem.gridWidth, equals(20));
      expect(gridSystem.gridHeight, equals(20));
      expect(gridSystem.cellSize, equals(25.0));
      expect(gridSystem.screenWidth, equals(800.0));
      expect(gridSystem.screenHeight, equals(600.0));
    });

    test('should throw assertion error for invalid parameters', () {
      expect(
        () => GridSystem(
          gridWidth: 0,
          gridHeight: 20,
          cellSize: 25.0,
          screenWidth: 800.0,
          screenHeight: 600.0,
        ),
        throwsAssertionError,
      );

      expect(
        () => GridSystem(
          gridWidth: 20,
          gridHeight: -5,
          cellSize: 25.0,
          screenWidth: 800.0,
          screenHeight: 600.0,
        ),
        throwsAssertionError,
      );

      expect(
        () => GridSystem(
          gridWidth: 20,
          gridHeight: 20,
          cellSize: 0.0,
          screenWidth: 800.0,
          screenHeight: 600.0,
        ),
        throwsAssertionError,
      );
    });

    group('adaptive constructor', () {
      test('should create adaptive grid system with optimal cell size', () {
        final gridSystem = GridSystem.adaptive(
          gridWidth: 20,
          gridHeight: 20,
          screenWidth: 800.0,
          screenHeight: 600.0,
        );

        expect(gridSystem.gridWidth, equals(20));
        expect(gridSystem.gridHeight, equals(20));
        expect(gridSystem.cellSize, greaterThan(0));
        expect(gridSystem.cellSize, lessThanOrEqualTo(30.0)); // max cell size
        expect(
          gridSystem.cellSize,
          greaterThanOrEqualTo(15.0),
        ); // min cell size
      });

      test('should constrain cell size to minimum', () {
        final gridSystem = GridSystem.adaptive(
          gridWidth: 50,
          gridHeight: 50,
          screenWidth: 400.0,
          screenHeight: 400.0,
        );

        expect(gridSystem.cellSize, equals(15.0)); // Should be minimum
      });

      test('should constrain cell size to maximum', () {
        final gridSystem = GridSystem.adaptive(
          gridWidth: 5,
          gridHeight: 5,
          screenWidth: 1000.0,
          screenHeight: 1000.0,
        );

        expect(gridSystem.cellSize, equals(30.0)); // Should be maximum
      });
    });

    group('coordinate conversion', () {
      late GridSystem gridSystem;

      setUp(() {
        gridSystem = GridSystem(
          gridWidth: 10,
          gridHeight: 10,
          cellSize: 20.0,
          screenWidth: 400.0,
          screenHeight: 400.0,
        );
      });

      test('should convert grid to screen coordinates correctly', () {
        const gridPos = Position(5, 5);
        final screenPos = gridSystem.gridToScreen(gridPos);

        // Grid should be centered, so offset should be calculated correctly
        const expectedX = (400.0 - 200.0) / 2 + (5 * 20.0); // 100 + 100 = 200
        const expectedY = (400.0 - 200.0) / 2 + (5 * 20.0); // 100 + 100 = 200

        expect(screenPos.dx, equals(expectedX));
        expect(screenPos.dy, equals(expectedY));
      });

      test('should convert grid to screen center correctly', () {
        const gridPos = Position(0, 0);
        final screenCenter = gridSystem.gridToScreenCenter(gridPos);
        final screenTopLeft = gridSystem.gridToScreen(gridPos);

        expect(
          screenCenter.dx,
          equals(screenTopLeft.dx + 10.0),
        ); // cellSize / 2
        expect(
          screenCenter.dy,
          equals(screenTopLeft.dy + 10.0),
        ); // cellSize / 2
      });

      test('should convert screen to grid coordinates correctly', () {
        final screenPos = gridSystem.gridToScreen(const Position(3, 4));
        final convertedBack = gridSystem.screenToGrid(screenPos);

        expect(convertedBack, equals(const Position(3, 4)));
      });

      test('should handle origin conversion', () {
        const origin = Position(0, 0);
        final screenPos = gridSystem.gridToScreen(origin);
        final convertedBack = gridSystem.screenToGrid(screenPos);

        expect(convertedBack, equals(origin));
      });
    });

    group('grid properties', () {
      late GridSystem gridSystem;

      setUp(() {
        gridSystem = GridSystem(
          gridWidth: 20,
          gridHeight: 15,
          cellSize: 25.0,
          screenWidth: 800.0,
          screenHeight: 600.0,
        );
      });

      test('should calculate grid screen size correctly', () {
        final screenSize = gridSystem.gridScreenSize;
        expect(screenSize.width, equals(500.0)); // 20 * 25
        expect(screenSize.height, equals(375.0)); // 15 * 25
      });

      test('should calculate grid logical size correctly', () {
        final logicalSize = gridSystem.gridLogicalSize;
        expect(logicalSize.width, equals(20.0));
        expect(logicalSize.height, equals(15.0));
      });

      test('should calculate grid screen bounds correctly', () {
        final bounds = gridSystem.gridScreenBounds;
        expect(bounds.width, equals(500.0)); // 20 * 25
        expect(bounds.height, equals(375.0)); // 15 * 25
      });

      test('should calculate grid logical bounds correctly', () {
        final bounds = gridSystem.gridLogicalBounds;
        expect(bounds, equals(const Rect.fromLTWH(0, 0, 20, 15)));
      });

      test('should calculate total cells correctly', () {
        expect(gridSystem.totalCells, equals(300)); // 20 * 15
      });

      test('should find center position correctly', () {
        expect(
          gridSystem.centerPosition,
          equals(const Position(10, 7)),
        ); // 20/2, 15/2
      });
    });

    group('position validation', () {
      late GridSystem gridSystem;

      setUp(() {
        gridSystem = GridSystem(
          gridWidth: 10,
          gridHeight: 10,
          cellSize: 20.0,
          screenWidth: 400.0,
          screenHeight: 400.0,
        );
      });

      test('should validate positions within bounds', () {
        expect(gridSystem.isValidPosition(const Position(0, 0)), isTrue);
        expect(gridSystem.isValidPosition(const Position(5, 5)), isTrue);
        expect(gridSystem.isValidPosition(const Position(9, 9)), isTrue);
      });

      test('should invalidate positions outside bounds', () {
        expect(gridSystem.isValidPosition(const Position(-1, 0)), isFalse);
        expect(gridSystem.isValidPosition(const Position(0, -1)), isFalse);
        expect(gridSystem.isValidPosition(const Position(10, 0)), isFalse);
        expect(gridSystem.isValidPosition(const Position(0, 10)), isFalse);
        expect(gridSystem.isValidPosition(const Position(15, 15)), isFalse);
      });
    });

    group('position generation', () {
      late GridSystem gridSystem;

      setUp(() {
        gridSystem = GridSystem(
          gridWidth: 5,
          gridHeight: 5,
          cellSize: 20.0,
          screenWidth: 400.0,
          screenHeight: 400.0,
        );
      });

      test('should generate random positions within bounds', () {
        for (int i = 0; i < 100; i++) {
          final position = gridSystem.getRandomPosition();
          expect(gridSystem.isValidPosition(position), isTrue);
        }
      });

      test('should generate all positions correctly', () {
        final allPositions = gridSystem.getAllPositions();
        expect(allPositions, hasLength(25)); // 5 * 5

        // Check that all positions are unique and valid
        final positionSet = allPositions.toSet();
        expect(positionSet, hasLength(25));

        for (final position in allPositions) {
          expect(gridSystem.isValidPosition(position), isTrue);
        }
      });

      test('should generate border positions correctly', () {
        final borderPositions = gridSystem.getBorderPositions();

        // For a 5x5 grid, border should have 16 positions
        // Top: 5, Bottom: 5, Left: 3 (excluding corners), Right: 3 (excluding corners)
        expect(borderPositions, hasLength(16));

        for (final position in borderPositions) {
          expect(gridSystem.isValidPosition(position), isTrue);

          // Check that position is actually on border
          final isOnBorder =
              position.x == 0 ||
              position.x == 4 ||
              position.y == 0 ||
              position.y == 4;
          expect(isOnBorder, isTrue);
        }
      });
    });

    test('should create copy with modified parameters', () {
      final original = GridSystem(
        gridWidth: 10,
        gridHeight: 10,
        cellSize: 20.0,
        screenWidth: 400.0,
        screenHeight: 400.0,
      );

      final copied = original.copyWith(gridWidth: 15, cellSize: 25.0);

      expect(copied.gridWidth, equals(15));
      expect(copied.gridHeight, equals(10)); // unchanged
      expect(copied.cellSize, equals(25.0));
      expect(copied.screenWidth, equals(400.0)); // unchanged
      expect(copied.screenHeight, equals(400.0)); // unchanged
    });

    test('should have proper string representation', () {
      final gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 15,
        cellSize: 25.0,
        screenWidth: 800.0,
        screenHeight: 600.0,
      );

      expect(
        gridSystem.toString(),
        equals('GridSystem(20x15, cellSize: 25.0)'),
      );
    });
  });
}
