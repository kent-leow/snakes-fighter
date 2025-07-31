/// Represents the four cardinal directions a snake can move.
enum Direction {
  /// Moving upward (decreasing y coordinate).
  up,

  /// Moving downward (increasing y coordinate).
  down,

  /// Moving left (decreasing x coordinate).
  left,

  /// Moving right (increasing x coordinate).
  right;

  /// Gets the opposite direction.
  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  /// Converts direction to a position delta for movement calculation.
  /// Returns the change in x,y coordinates for one step in this direction.
  (int x, int y) get delta {
    switch (this) {
      case Direction.up:
        return (0, -1);
      case Direction.down:
        return (0, 1);
      case Direction.left:
        return (-1, 0);
      case Direction.right:
        return (1, 0);
    }
  }

  /// Checks if this direction is horizontal (left or right).
  bool get isHorizontal => this == Direction.left || this == Direction.right;

  /// Checks if this direction is vertical (up or down).
  bool get isVertical => this == Direction.up || this == Direction.down;

  /// Checks if this direction can change to the given direction.
  /// Prevents 180-degree turns (backwards movement).
  bool canChangeTo(Direction newDirection) {
    return this != newDirection.opposite;
  }
}
