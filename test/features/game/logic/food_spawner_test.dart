import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/logic/food_spawner.dart';

void main() {
  group('FoodSpawner', () {
    late GridSystem gridSystem;

    setUp(() {
      gridSystem = GridSystem(
        gridWidth: 10,
        gridHeight: 10,
        cellSize: 20.0,
        screenWidth: 200.0,
        screenHeight: 200.0,
      );
    });

    group('spawnFood', () {
      test(
        'should spawn food at valid position when grid has available space',
        () {
          final occupiedPositions = [
            const Position(0, 0),
            const Position(1, 0),
            const Position(2, 0),
          ];

          final food = FoodSpawner.spawnFood(occupiedPositions, gridSystem);

          expect(food, isNotNull);
          expect(food!.isActive, isTrue);
          expect(occupiedPositions.contains(food.position), isFalse);
          expect(gridSystem.isValidPosition(food.position), isTrue);
        },
      );

      test('should return null when no positions are available', () {
        // Create a list of all possible positions (fill entire grid)
        final occupiedPositions = <Position>[];
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            occupiedPositions.add(Position(x, y));
          }
        }

        final food = FoodSpawner.spawnFood(occupiedPositions, gridSystem);

        expect(food, isNull);
      });

      test('should spawn food in remaining available positions', () {
        // Leave only position (9, 9) available
        final occupiedPositions = <Position>[];
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            if (x != 9 || y != 9) {
              occupiedPositions.add(Position(x, y));
            }
          }
        }

        final food = FoodSpawner.spawnFood(occupiedPositions, gridSystem);

        expect(food, isNotNull);
        expect(food!.position, const Position(9, 9));
      });
    });

    group('getAvailablePositions', () {
      test('should return all positions when none are occupied', () {
        final availablePositions = FoodSpawner.getAvailablePositions(
          [],
          gridSystem,
        );

        expect(availablePositions.length, 100); // 10x10 grid

        // Verify all grid positions are included
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            expect(availablePositions.contains(Position(x, y)), isTrue);
          }
        }
      });

      test('should exclude occupied positions', () {
        final occupiedPositions = [
          const Position(5, 5),
          const Position(3, 7),
          const Position(1, 2),
        ];

        final availablePositions = FoodSpawner.getAvailablePositions(
          occupiedPositions,
          gridSystem,
        );

        expect(availablePositions.length, 97); // 100 - 3 occupied

        for (final occupiedPos in occupiedPositions) {
          expect(availablePositions.contains(occupiedPos), isFalse);
        }
      });

      test('should return empty list when all positions are occupied', () {
        final occupiedPositions = <Position>[];
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            occupiedPositions.add(Position(x, y));
          }
        }

        final availablePositions = FoodSpawner.getAvailablePositions(
          occupiedPositions,
          gridSystem,
        );

        expect(availablePositions, isEmpty);
      });
    });

    group('getRandomPosition', () {
      test('should return position from available list', () {
        final availablePositions = [
          const Position(1, 1),
          const Position(2, 2),
          const Position(3, 3),
        ];

        final randomPosition = FoodSpawner.getRandomPosition(
          availablePositions,
        );

        expect(availablePositions.contains(randomPosition), isTrue);
      });

      test('should throw error when list is empty', () {
        expect(() => FoodSpawner.getRandomPosition([]), throwsArgumentError);
      });

      test('should return single position when only one available', () {
        const singlePosition = Position(7, 8);
        final randomPosition = FoodSpawner.getRandomPosition([singlePosition]);

        expect(randomPosition, singlePosition);
      });
    });

    group('isValidFoodPosition', () {
      test('should return true for valid unoccupied position', () {
        final occupiedPositions = [const Position(1, 1)];

        final isValid = FoodSpawner.isValidFoodPosition(
          const Position(5, 5),
          occupiedPositions,
          gridSystem,
        );

        expect(isValid, isTrue);
      });

      test('should return false for occupied position', () {
        final occupiedPositions = [const Position(5, 5)];

        final isValid = FoodSpawner.isValidFoodPosition(
          const Position(5, 5),
          occupiedPositions,
          gridSystem,
        );

        expect(isValid, isFalse);
      });

      test('should return false for out-of-bounds position', () {
        final isValid = FoodSpawner.isValidFoodPosition(
          const Position(15, 15), // Out of 10x10 grid
          [],
          gridSystem,
        );

        expect(isValid, isFalse);
      });
    });

    group('getAvailablePositionCount', () {
      test('should return total positions when none occupied', () {
        final count = FoodSpawner.getAvailablePositionCount([], gridSystem);

        expect(count, 100); // 10x10 grid
      });

      test('should return correct count with occupied positions', () {
        final occupiedPositions = [
          const Position(0, 0),
          const Position(1, 1),
          const Position(2, 2),
        ];

        final count = FoodSpawner.getAvailablePositionCount(
          occupiedPositions,
          gridSystem,
        );

        expect(count, 97); // 100 - 3
      });

      test('should return zero when all positions occupied', () {
        final occupiedPositions = <Position>[];
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            occupiedPositions.add(Position(x, y));
          }
        }

        final count = FoodSpawner.getAvailablePositionCount(
          occupiedPositions,
          gridSystem,
        );

        expect(count, 0);
      });
    });

    group('canSpawnFood', () {
      test('should return true when positions are available', () {
        final canSpawn = FoodSpawner.canSpawnFood([
          const Position(0, 0),
        ], gridSystem);

        expect(canSpawn, isTrue);
      });

      test('should return false when no positions are available', () {
        final occupiedPositions = <Position>[];
        for (int x = 0; x < gridSystem.gridWidth; x++) {
          for (int y = 0; y < gridSystem.gridHeight; y++) {
            occupiedPositions.add(Position(x, y));
          }
        }

        final canSpawn = FoodSpawner.canSpawnFood(
          occupiedPositions,
          gridSystem,
        );

        expect(canSpawn, isFalse);
      });
    });
  });
}
