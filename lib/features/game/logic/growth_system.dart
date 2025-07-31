import '../../../core/models/position.dart';
import '../models/direction.dart';
import '../models/snake.dart';

/// Handles snake growth mechanics and calculations.
///
/// This system manages the logic for growing the snake when food is consumed,
/// including calculating new tail positions and managing growth timing.
class GrowthSystem {
  /// Grows the snake by one segment.
  ///
  /// This method triggers the snake's internal growth mechanism, which will
  /// cause the snake to grow by one segment on its next move.
  static void growSnake(Snake snake) {
    snake.grow();
  }

  /// Calculates where the new tail position would be after growth.
  ///
  /// When a snake grows, it extends in the opposite direction of its
  /// current movement. This method calculates where that new tail
  /// segment would be positioned.
  static Position calculateNewTailPosition(Snake snake) {
    if (snake.length == 0) {
      throw StateError('Cannot calculate tail position for empty snake');
    }

    // If snake has only one segment (head), extend opposite to current direction
    if (snake.length == 1) {
      final (dx, dy) = snake.currentDirection.opposite.delta;
      return Position(snake.head.x + dx, snake.head.y + dy);
    }

    // For multi-segment snake, calculate based on tail direction
    final currentTail = snake.tail;
    final secondToLastSegment = snake.body[snake.length - 2];

    // Calculate the direction from second-to-last to tail
    final tailDirection = _calculateDirectionBetweenPositions(
      secondToLastSegment,
      currentTail,
    );

    // Extend the tail in the same direction
    final (dx, dy) = tailDirection.delta;
    return Position(currentTail.x + dx, currentTail.y + dy);
  }

  /// Calculates the direction from one position to another.
  ///
  /// Returns the direction that would move from the first position
  /// to the second position.
  static Direction _calculateDirectionBetweenPositions(
    Position from,
    Position to,
  ) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;

    // Determine direction based on the difference
    if (dx > 0) return Direction.right;
    if (dx < 0) return Direction.left;
    if (dy > 0) return Direction.down;
    if (dy < 0) return Direction.up;

    // If no difference, default to right
    return Direction.right;
  }

  /// Validates that snake growth is possible.
  ///
  /// Returns true if the snake is in a valid state for growth.
  static bool canGrowSnake(Snake snake) {
    return snake.length > 0;
  }

  /// Gets the predicted length after growth.
  ///
  /// If the snake is marked to grow, returns current length + 1.
  /// Otherwise returns the current length.
  static int getPredictedLength(Snake snake) {
    return snake.shouldGrow ? snake.length + 1 : snake.length;
  }

  /// Checks if the snake is currently set to grow on the next move.
  static bool isSnakeGrowing(Snake snake) {
    return snake.shouldGrow;
  }

  /// Simulates snake growth without actually modifying the snake.
  ///
  /// Returns what the snake's body would look like after growth,
  /// useful for collision prediction and game state analysis.
  static List<Position> simulateGrowth(Snake snake) {
    if (!snake.shouldGrow) {
      return List.from(snake.body);
    }

    // Create a copy of the current body
    final simulatedBody = List<Position>.from(snake.body);

    // Add the new tail position
    final newTailPosition = calculateNewTailPosition(snake);
    simulatedBody.add(newTailPosition);

    return simulatedBody;
  }

  /// Calculates the total growth potential for the given grid size.
  ///
  /// Returns the maximum possible length a snake can achieve
  /// on a grid of the given dimensions.
  static int calculateMaxSnakeLength(int gridWidth, int gridHeight) {
    return gridWidth * gridHeight;
  }

  /// Checks if the snake has reached maximum possible growth.
  ///
  /// Returns true if the snake cannot grow any further without
  /// exceeding the grid boundaries.
  static bool hasReachedMaxGrowth(Snake snake, int gridWidth, int gridHeight) {
    final maxLength = calculateMaxSnakeLength(gridWidth, gridHeight);
    return getPredictedLength(snake) >= maxLength;
  }
}
