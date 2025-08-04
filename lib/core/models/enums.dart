/// Game-related enumerations used throughout the application.
library;

import 'package:json_annotation/json_annotation.dart';

import 'position.dart';

/// Status of a game room.
enum RoomStatus {
  @JsonValue('waiting')
  waiting,
  @JsonValue('active')
  active,
  @JsonValue('ended')
  ended,
}

/// Available colors for players.
enum PlayerColor {
  @JsonValue('red')
  red,
  @JsonValue('blue')
  blue,
  @JsonValue('green')
  green,
  @JsonValue('yellow')
  yellow,
}

/// Snake movement directions.
enum Direction {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('left')
  left,
  @JsonValue('right')
  right,
}

/// Extension methods for Direction enum.
extension DirectionExtension on Direction {
  /// Returns the opposite direction.
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

  /// Converts direction to a position offset.
  Position toPosition() {
    switch (this) {
      case Direction.up:
        return const Position(0, -1);
      case Direction.down:
        return const Position(0, 1);
      case Direction.left:
        return const Position(-1, 0);
      case Direction.right:
        return const Position(1, 0);
    }
  }
  
  /// Checks if this direction can change to the given direction.
  /// Prevents 180-degree turns (backwards movement).
  bool canChangeTo(Direction newDirection) {
    return this != newDirection.opposite;
  }
  
  /// Gets the change in x,y coordinates for one step in this direction.
  (int, int) get delta {
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
}
