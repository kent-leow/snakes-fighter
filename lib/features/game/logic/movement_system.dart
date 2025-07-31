import '../../../core/models/position.dart';
import '../../../core/utils/grid_system.dart';
import '../models/direction.dart';
import '../models/snake.dart';

/// Handles snake movement logic including validation and position updates.
///
/// This system manages the core movement mechanics for snakes, including
/// direction validation, movement updates, and boundary checking.
class MovementSystem {
  /// The grid system used for boundary validation.
  final GridSystem _gridSystem;

  /// Creates a new movement system with the given grid system.
  MovementSystem(this._gridSystem);

  /// Updates the snake's position by moving it one step.
  ///
  /// This method handles the core movement logic:
  /// 1. Applies any queued direction changes
  /// 2. Moves the snake in its current direction
  /// 3. Validates the new position is within bounds
  ///
  /// Returns true if the movement was successful, false if it would
  /// result in a boundary collision.
  bool updateSnakePosition(Snake snake) {
    // Get the current head position before moving
    final currentHead = snake.head;

    // Calculate what the new head position would be
    final direction = snake.nextDirection ?? snake.currentDirection;
    final (dx, dy) = direction.delta;
    final newHeadPosition = Position(currentHead.x + dx, currentHead.y + dy);

    // Check if the new position is within grid boundaries
    if (!_gridSystem.isValidPosition(newHeadPosition)) {
      return false; // Movement would go out of bounds
    }

    // Movement is valid, proceed with the move
    snake.move();
    return true;
  }

  /// Validates if a direction change is allowed for the given snake.
  ///
  /// A direction change is valid if:
  /// 1. It's not the opposite of the current direction (no 180-degree turns)
  /// 2. It's a different direction from the current one
  ///
  /// Returns true if the direction change is valid.
  static bool isValidDirectionChange(Snake snake, Direction newDirection) {
    final currentDirection = snake.currentDirection;
    return currentDirection.canChangeTo(newDirection) &&
        currentDirection != newDirection;
  }

  /// Gets the opposite direction of the given direction.
  ///
  /// This is a convenience method that delegates to the Direction enum.
  static Direction getOppositeDirection(Direction direction) {
    return direction.opposite;
  }

  /// Calculates the next position the snake would move to.
  ///
  /// This method calculates where the snake's head would be after
  /// the next move, considering any queued direction changes.
  Position calculateNextPosition(Snake snake) {
    final direction = snake.nextDirection ?? snake.currentDirection;
    final (dx, dy) = direction.delta;
    return Position(snake.head.x + dx, snake.head.y + dy);
  }

  /// Checks if the snake would collide with the grid boundary on the next move.
  ///
  /// Returns true if the next move would take the snake out of bounds.
  bool wouldCollideWithBoundary(Snake snake) {
    final nextPosition = calculateNextPosition(snake);
    return !_gridSystem.isValidPosition(nextPosition);
  }

  /// Checks if the snake would collide with itself on the next move.
  ///
  /// This method calculates the next head position and checks if it
  /// would overlap with any existing body segments.
  bool wouldCollideWithSelf(Snake snake) {
    final nextPosition = calculateNextPosition(snake);

    // Check against body segments (excluding the tail if not growing,
    // since the tail will move away)
    final bodyToCheck = snake.shouldGrow
        ? snake.body
        : snake.body.take(snake.length - 1);

    return bodyToCheck.any((pos) => pos == nextPosition);
  }

  /// Checks if any movement is possible for the snake.
  ///
  /// This method checks all four directions to see if the snake
  /// can move in any direction without immediate collision.
  bool hasValidMoves(Snake snake) {
    for (final direction in Direction.values) {
      if (isValidDirectionChange(snake, direction)) {
        final (dx, dy) = direction.delta;
        final testPosition = Position(snake.head.x + dx, snake.head.y + dy);

        if (_gridSystem.isValidPosition(testPosition) &&
            !snake.isBodyExcludingHeadAt(testPosition)) {
          return true;
        }
      }
    }

    // Also check if current direction is still valid
    final nextPosition = calculateNextPosition(snake);
    return _gridSystem.isValidPosition(nextPosition) &&
        !snake.isBodyExcludingHeadAt(nextPosition);
  }

  /// Gets all valid directions the snake can move in.
  ///
  /// Returns a list of directions that would not result in immediate
  /// collision with boundaries or the snake's own body.
  List<Direction> getValidDirections(Snake snake) {
    final validDirections = <Direction>[];

    for (final direction in Direction.values) {
      if (isValidDirectionChange(snake, direction)) {
        final (dx, dy) = direction.delta;
        final testPosition = Position(snake.head.x + dx, snake.head.y + dy);

        if (_gridSystem.isValidPosition(testPosition) &&
            !snake.isBodyExcludingHeadAt(testPosition)) {
          validDirections.add(direction);
        }
      }
    }

    return validDirections;
  }

  /// Performs a dry run of snake movement without actually moving the snake.
  ///
  /// This method simulates the movement and returns information about
  /// what would happen, useful for AI and collision prediction.
  MovementResult simulateMovement(Snake snake, {Direction? overrideDirection}) {
    final direction =
        overrideDirection ?? snake.nextDirection ?? snake.currentDirection;
    final (dx, dy) = direction.delta;
    final newHeadPosition = Position(snake.head.x + dx, snake.head.y + dy);

    // Check boundary collision
    if (!_gridSystem.isValidPosition(newHeadPosition)) {
      return MovementResult(
        success: false,
        collisionType: CollisionType.boundary,
        newHeadPosition: newHeadPosition,
      );
    }

    // Check self collision
    final bodyToCheck = snake.shouldGrow
        ? snake.body
        : snake.body.take(snake.length - 1);

    if (bodyToCheck.any((pos) => pos == newHeadPosition)) {
      return MovementResult(
        success: false,
        collisionType: CollisionType.self,
        newHeadPosition: newHeadPosition,
      );
    }

    return MovementResult(
      success: true,
      collisionType: null,
      newHeadPosition: newHeadPosition,
    );
  }

  /// Gets the grid system used by this movement system.
  GridSystem get gridSystem => _gridSystem;
}

/// Represents the result of a movement simulation.
class MovementResult {
  /// Whether the movement would be successful.
  final bool success;

  /// The type of collision that would occur (if any).
  final CollisionType? collisionType;

  /// The position the head would move to.
  final Position newHeadPosition;

  /// Creates a new movement result.
  const MovementResult({
    required this.success,
    required this.collisionType,
    required this.newHeadPosition,
  });

  @override
  String toString() {
    return 'MovementResult(success: $success, collision: $collisionType, position: $newHeadPosition)';
  }
}

/// Types of collisions that can occur during movement.
enum CollisionType {
  /// Collision with grid boundary.
  boundary,

  /// Collision with the snake's own body.
  self,

  /// Collision with another snake (for multiplayer).
  other,

  /// Collision with an obstacle.
  obstacle,
}
