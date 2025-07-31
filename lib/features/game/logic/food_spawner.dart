import 'dart:math';

import '../../../core/models/position.dart';
import '../../../core/utils/grid_system.dart';
import '../models/food.dart';

/// Handles food spawning logic for the game.
///
/// This system manages the random generation of food at valid positions
/// on the game grid, avoiding occupied positions like snake body segments.
class FoodSpawner {
  /// Random number generator for food positioning.
  static final Random _random = Random();

  /// Spawns a new food item at a random valid position.
  ///
  /// The food will be placed at a position that is not in the list of
  /// occupied positions and is within the game area bounds.
  ///
  /// Returns null if no valid positions are available.
  static Food? spawnFood(
    List<Position> occupiedPositions,
    GridSystem gridSystem,
  ) {
    final availablePositions = getAvailablePositions(
      occupiedPositions,
      gridSystem,
    );

    if (availablePositions.isEmpty) {
      return null; // No available positions
    }

    final randomPosition = getRandomPosition(availablePositions);
    return Food(position: randomPosition);
  }

  /// Gets all available positions on the grid that are not occupied.
  ///
  /// This method generates all possible positions within the grid bounds
  /// and filters out the positions that are currently occupied.
  static List<Position> getAvailablePositions(
    List<Position> occupiedPositions,
    GridSystem gridSystem,
  ) {
    final availablePositions = <Position>[];
    final occupiedSet = Set<Position>.from(occupiedPositions);

    // Generate all possible positions within grid bounds
    for (int x = 0; x < gridSystem.gridWidth; x++) {
      for (int y = 0; y < gridSystem.gridHeight; y++) {
        final position = Position(x, y);
        if (!occupiedSet.contains(position)) {
          availablePositions.add(position);
        }
      }
    }

    return availablePositions;
  }

  /// Selects a random position from the list of available positions.
  ///
  /// Returns a randomly selected position from the provided list.
  /// The list must not be empty.
  static Position getRandomPosition(List<Position> availablePositions) {
    if (availablePositions.isEmpty) {
      throw ArgumentError('Available positions list cannot be empty');
    }

    final randomIndex = _random.nextInt(availablePositions.length);
    return availablePositions[randomIndex];
  }

  /// Checks if a position is valid for food placement.
  ///
  /// A position is valid if it's within grid bounds and not occupied.
  static bool isValidFoodPosition(
    Position position,
    List<Position> occupiedPositions,
    GridSystem gridSystem,
  ) {
    // Check if position is within grid bounds
    if (!gridSystem.isValidPosition(position)) {
      return false;
    }

    // Check if position is not occupied
    return !occupiedPositions.contains(position);
  }

  /// Gets the total number of available positions for food placement.
  ///
  /// This is useful for determining if the game is in a win condition
  /// (when the snake fills the entire grid).
  static int getAvailablePositionCount(
    List<Position> occupiedPositions,
    GridSystem gridSystem,
  ) {
    final totalPositions = gridSystem.gridWidth * gridSystem.gridHeight;
    return totalPositions - occupiedPositions.length;
  }

  /// Validates that food spawning is possible given the current game state.
  ///
  /// Returns true if there are available positions for food placement.
  static bool canSpawnFood(
    List<Position> occupiedPositions,
    GridSystem gridSystem,
  ) {
    return getAvailablePositionCount(occupiedPositions, gridSystem) > 0;
  }
}
