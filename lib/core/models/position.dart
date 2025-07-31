import 'dart:math' as math;

/// Represents a position in the grid coordinate system.
///
/// This immutable class handles all grid coordinate operations and provides
/// utility methods for position calculations used throughout the game.
class Position {
  /// The x-coordinate in the grid (column).
  final int x;

  /// The y-coordinate in the grid (row).
  final int y;

  /// Creates a new position with the given coordinates.
  const Position(this.x, this.y);

  /// Creates a position at the origin (0, 0).
  const Position.origin() : x = 0, y = 0;

  /// Adds two positions together.
  Position operator +(Position other) => Position(x + other.x, y + other.y);

  /// Subtracts one position from another.
  Position operator -(Position other) => Position(x - other.x, y - other.y);

  /// Multiplies the position by a scalar.
  Position operator *(int scalar) => Position(x * scalar, y * scalar);

  /// Calculates the Euclidean distance to another position.
  double distanceTo(Position other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculates the Manhattan distance to another position.
  int manhattanDistanceTo(Position other) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  /// Returns the four adjacent neighbors (up, down, left, right).
  List<Position> getNeighbors() {
    return [
      Position(x, y - 1), // Up
      Position(x + 1, y), // Right
      Position(x, y + 1), // Down
      Position(x - 1, y), // Left
    ];
  }

  /// Returns all eight surrounding neighbors (including diagonals).
  List<Position> getAllNeighbors() {
    return [
      Position(x - 1, y - 1), // Top-left
      Position(x, y - 1), // Top
      Position(x + 1, y - 1), // Top-right
      Position(x + 1, y), // Right
      Position(x + 1, y + 1), // Bottom-right
      Position(x, y + 1), // Bottom
      Position(x - 1, y + 1), // Bottom-left
      Position(x - 1, y), // Left
    ];
  }

  /// Checks if this position is adjacent to another position.
  bool isAdjacentTo(Position other) {
    final dx = (x - other.x).abs();
    final dy = (y - other.y).abs();
    return (dx <= 1 && dy <= 1) && (dx + dy > 0);
  }

  /// Checks if this position is directly adjacent (not diagonal).
  bool isDirectlyAdjacentTo(Position other) {
    final dx = (x - other.x).abs();
    final dy = (y - other.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// Creates a copy of this position with optional coordinate changes.
  Position copyWith({int? x, int? y}) {
    return Position(x ?? this.x, y ?? this.y);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Position($x, $y)';
}
