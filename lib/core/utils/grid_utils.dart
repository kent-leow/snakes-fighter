import 'dart:math' as math;

import '../models/position.dart';
import 'grid_validator.dart';

/// Direction enumeration for grid movement.
enum GridDirection {
  up(Position(0, -1), 'Up'),
  right(Position(1, 0), 'Right'),
  down(Position(0, 1), 'Down'),
  left(Position(-1, 0), 'Left');

  const GridDirection(this.delta, this.name);

  /// The position delta for this direction.
  final Position delta;

  /// The human-readable name of the direction.
  final String name;

  /// Gets the opposite direction.
  GridDirection get opposite {
    switch (this) {
      case GridDirection.up:
        return GridDirection.down;
      case GridDirection.down:
        return GridDirection.up;
      case GridDirection.left:
        return GridDirection.right;
      case GridDirection.right:
        return GridDirection.left;
    }
  }

  /// Gets the direction rotated 90 degrees clockwise.
  GridDirection get clockwise {
    switch (this) {
      case GridDirection.up:
        return GridDirection.right;
      case GridDirection.right:
        return GridDirection.down;
      case GridDirection.down:
        return GridDirection.left;
      case GridDirection.left:
        return GridDirection.up;
    }
  }

  /// Gets the direction rotated 90 degrees counter-clockwise.
  GridDirection get counterClockwise {
    switch (this) {
      case GridDirection.up:
        return GridDirection.left;
      case GridDirection.left:
        return GridDirection.down;
      case GridDirection.down:
        return GridDirection.right;
      case GridDirection.right:
        return GridDirection.up;
    }
  }
}

/// Utility class for grid operations and calculations.
///
/// This class provides static methods for common grid operations such as
/// distance calculations, finding positions within radius, and other
/// grid-related utility functions.
class GridUtils {
  // Prevent instantiation
  GridUtils._();

  /// Calculates the Euclidean distance between two positions.
  static double calculateDistance(Position a, Position b) {
    return a.distanceTo(b);
  }

  /// Calculates the Manhattan distance between two positions.
  static int calculateManhattanDistance(Position a, Position b) {
    return a.manhattanDistanceTo(b);
  }

  /// Gets all positions within a given radius from a center position.
  ///
  /// Uses Euclidean distance for the radius calculation.
  static List<Position> getPositionsInRadius(
    Position center,
    double radius,
    int gridWidth,
    int gridHeight,
  ) {
    final positions = <Position>[];
    final radiusSquared = radius * radius;

    // Calculate bounding box to limit search area
    final minX = math.max(0, (center.x - radius.ceil()));
    final maxX = math.min(gridWidth - 1, (center.x + radius.ceil()));
    final minY = math.max(0, (center.y - radius.ceil()));
    final maxY = math.min(gridHeight - 1, (center.y + radius.ceil()));

    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        final position = Position(x, y);
        final distanceSquared = _calculateDistanceSquared(center, position);

        if (distanceSquared <= radiusSquared) {
          positions.add(position);
        }
      }
    }

    return positions;
  }

  /// Gets all positions within a Manhattan distance from a center position.
  static List<Position> getPositionsInManhattanRadius(
    Position center,
    int radius,
    int gridWidth,
    int gridHeight,
  ) {
    final positions = <Position>[];

    for (
      int x = math.max(0, center.x - radius);
      x <= math.min(gridWidth - 1, center.x + radius);
      x++
    ) {
      for (
        int y = math.max(0, center.y - radius);
        y <= math.min(gridHeight - 1, center.y + radius);
        y++
      ) {
        final position = Position(x, y);
        if (calculateManhattanDistance(center, position) <= radius) {
          positions.add(position);
        }
      }
    }

    return positions;
  }

  /// Finds a random empty position that is not in the occupied positions list.
  static Position? getRandomEmptyPosition(
    List<Position> occupied,
    int width,
    int height, [
    math.Random? random,
  ]) {
    final rng = random ?? math.Random();
    final occupiedSet = occupied.toSet();
    final totalCells = width * height;

    // If grid is full, return null
    if (occupiedSet.length >= totalCells) {
      return null;
    }

    // Try random positions first (more efficient for sparse grids)
    const maxRandomAttempts = 100;
    for (int i = 0; i < maxRandomAttempts; i++) {
      final position = Position(rng.nextInt(width), rng.nextInt(height));
      if (!occupiedSet.contains(position)) {
        return position;
      }
    }

    // Fallback: find all empty positions and pick randomly
    final emptyPositions = <Position>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final position = Position(x, y);
        if (!occupiedSet.contains(position)) {
          emptyPositions.add(position);
        }
      }
    }

    if (emptyPositions.isEmpty) return null;
    return emptyPositions[rng.nextInt(emptyPositions.length)];
  }

  /// Determines the direction from one position to another.
  ///
  /// Returns the primary direction if positions are aligned, or null if diagonal.
  static GridDirection? getDirectionBetween(Position from, Position to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    // Check for exact alignment
    if (dx == 0 && dy < 0) return GridDirection.up;
    if (dx == 0 && dy > 0) return GridDirection.down;
    if (dy == 0 && dx > 0) return GridDirection.right;
    if (dy == 0 && dx < 0) return GridDirection.left;

    // For diagonal or non-adjacent positions, return the dominant direction
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? GridDirection.right : GridDirection.left;
    } else {
      return dy > 0 ? GridDirection.down : GridDirection.up;
    }
  }

  /// Gets all positions in a straight line between two positions.
  ///
  /// Only works for horizontal, vertical, or diagonal lines.
  static List<Position> getLineBetween(Position start, Position end) {
    final positions = <Position>[];
    final dx = end.x - start.x;
    final dy = end.y - start.y;

    final steps = math.max(dx.abs(), dy.abs());
    if (steps == 0) return [start];

    final stepX = dx / steps;
    final stepY = dy / steps;

    for (int i = 0; i <= steps; i++) {
      final x = (start.x + stepX * i).round();
      final y = (start.y + stepY * i).round();
      positions.add(Position(x, y));
    }

    return positions;
  }

  /// Finds the shortest path between two positions using Manhattan distance.
  ///
  /// Returns a list of positions forming a path, or empty list if no path exists.
  static List<Position> findShortestPath(
    Position start,
    Position end,
    int gridWidth,
    int gridHeight,
    Set<Position> obstacles,
  ) {
    if (start == end) return [start];
    if (obstacles.contains(start) || obstacles.contains(end)) return [];

    final queue = <_PathNode>[
      _PathNode(start, 0, [start]),
    ];
    final visited = <Position>{start};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current.position == end) {
        return current.path;
      }

      for (final neighbor in current.position.getNeighbors()) {
        if (GridValidator.isInBounds(neighbor, gridWidth, gridHeight) &&
            !obstacles.contains(neighbor) &&
            !visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(
            _PathNode(neighbor, current.distance + 1, [
              ...current.path,
              neighbor,
            ]),
          );
        }
      }
    }

    return []; // No path found
  }

  /// Gets all positions forming the perimeter of a rectangle.
  static List<Position> getRectanglePerimeter(
    Position topLeft,
    Position bottomRight,
  ) {
    final positions = <Position>[];

    // Handle single point case
    if (topLeft == bottomRight) {
      positions.add(topLeft);
      return positions;
    }

    // Top edge
    for (int x = topLeft.x; x <= bottomRight.x; x++) {
      positions.add(Position(x, topLeft.y));
    }

    // Bottom edge (only if different from top edge)
    if (bottomRight.y != topLeft.y) {
      for (int x = topLeft.x; x <= bottomRight.x; x++) {
        positions.add(Position(x, bottomRight.y));
      }
    }

    // Left edge (excluding corners already added)
    for (int y = topLeft.y + 1; y < bottomRight.y; y++) {
      positions.add(Position(topLeft.x, y));
    }

    // Right edge (excluding corners already added, only if different from left edge)
    if (bottomRight.x != topLeft.x) {
      for (int y = topLeft.y + 1; y < bottomRight.y; y++) {
        positions.add(Position(bottomRight.x, y));
      }
    }

    return positions;
  }

  /// Calculates the center point of a list of positions.
  static Position calculateCenter(List<Position> positions) {
    if (positions.isEmpty) return const Position(0, 0);

    int sumX = 0;
    int sumY = 0;

    for (final position in positions) {
      sumX += position.x;
      sumY += position.y;
    }

    return Position(sumX ~/ positions.length, sumY ~/ positions.length);
  }

  /// Helper method to calculate squared distance (avoids sqrt for performance).
  static double _calculateDistanceSquared(Position a, Position b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return (dx * dx + dy * dy).toDouble();
  }
}

/// Internal class for pathfinding algorithm.
class _PathNode {
  final Position position;
  final int distance;
  final List<Position> path;

  _PathNode(this.position, this.distance, this.path);
}
