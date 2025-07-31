import '../../../core/models/position.dart';
import '../models/collision.dart';
import '../models/collision_context.dart';
import '../models/snake.dart';

/// High-performance self-collision detector with O(1) complexity.
///
/// This class uses optimized algorithms including position caching
/// and spatial optimization techniques for detecting snake self-collisions.
class SelfCollisionDetector {
  /// Cache for body positions to enable O(1) lookup.
  static final Set<Position> _bodyPositionCache = <Position>{};

  /// Last cached snake to avoid unnecessary cache updates.
  static Snake? _lastCachedSnake;

  /// Checks for self-collision for the given snake.
  ///
  /// Uses optimized caching strategy for O(1) collision detection.
  static CollisionResult checkSelfCollision(Snake snake) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    // Update cache only if snake has changed
    if (_lastCachedSnake != snake) {
      _updateBodyCache(snake);
      _lastCachedSnake = snake;
    }

    final head = snake.head;
    final hasCollision = _bodyPositionCache.contains(head);

    final endTime = DateTime.now().microsecondsSinceEpoch;
    final detectionTime =
        (endTime - startTime) / 1000.0; // Convert to milliseconds

    if (hasCollision) {
      return CollisionResult.selfCollision(
        collisionPoint: head,
        detectionTime: detectionTime,
        metadata: {
          'collision_segment_index': _findCollisionSegmentIndex(snake, head),
          'snake_length': snake.length,
          'distance_from_tail': _getDistanceFromTail(snake, head),
        },
      );
    }

    return CollisionResult.none(detectionTime: detectionTime);
  }

  /// Checks for self-collision at a specific position.
  ///
  /// This method checks if the given position would collide with the snake's body.
  static CollisionResult checkSelfCollisionAtPosition(
    Snake snake,
    Position position,
  ) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    // Skip if snake has only one segment
    if (snake.length <= 1) {
      final detectionTime =
          (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;
      return CollisionResult.none(detectionTime: detectionTime);
    }

    // Get body positions to check against
    // We need to exclude the tail ONLY if the snake is not growing (tail will move away)
    final bodyToCheck = snake.shouldGrow
        ? snake.body.skip(
            1,
          ) // Skip head, include all body including tail (tail won't move)
        : snake.body
              .skip(1)
              .take(
                snake.length - 2,
              ); // Skip head and tail (tail will move away)

    final hasCollision = bodyToCheck.any((pos) => pos == position);

    final endTime = DateTime.now().microsecondsSinceEpoch;
    final detectionTime = (endTime - startTime) / 1000.0;

    if (hasCollision) {
      return CollisionResult.selfCollision(
        collisionPoint: position,
        detectionTime: detectionTime,
        metadata: {
          'collision_segment_index': _findCollisionSegmentIndex(
            snake,
            position,
          ),
          'snake_length': snake.length,
          'is_predictive': true,
        },
      );
    }

    return CollisionResult.none(detectionTime: detectionTime);
  }

  /// Checks for self-collision using collision context.
  ///
  /// This method uses the context's next head position for collision checking.
  static CollisionResult checkSelfCollisionFromContext(
    CollisionContext context,
  ) {
    return checkSelfCollisionAtPosition(
      context.snake,
      context.nextHeadPosition,
    );
  }

  /// Predicts if the snake will collide with itself in the next move.
  ///
  /// This is useful for AI and game logic that needs to look ahead.
  static CollisionResult predictSelfCollision(Snake snake) {
    final direction = snake.nextDirection ?? snake.currentDirection;
    final (dx, dy) = direction.delta;
    final nextPosition = Position(snake.head.x + dx, snake.head.y + dy);

    return checkSelfCollisionAtPosition(snake, nextPosition);
  }

  /// Checks if a position collides with snake body (lightweight version).
  ///
  /// This method doesn't include timing and is optimized for frequent checks.
  static bool doesPositionCollideWithSnake(Snake snake, Position position) {
    // Skip if snake has only one segment
    if (snake.length <= 1) {
      return false;
    }

    // Check against body segments (excluding tail if not growing)
    final bodyToCheck = snake.shouldGrow
        ? snake.body.skip(1) // Skip head, include tail
        : snake.body
              .skip(1)
              .take(
                (snake.length - 2).clamp(0, snake.length - 1),
              ); // Skip head and tail

    return bodyToCheck.any((pos) => pos == position);
  }

  /// Gets all positions that would cause self-collision.
  ///
  /// Returns a set of positions that the snake's head cannot move to
  /// without colliding with its own body.
  static Set<Position> getSelfCollisionPositions(Snake snake) {
    // Skip if snake has only one segment
    if (snake.length <= 1) {
      return <Position>{};
    }

    final bodyToCheck = snake.shouldGrow
        ? snake.body.skip(1) // Skip head, include tail
        : snake.body
              .skip(1)
              .take(
                (snake.length - 2).clamp(0, snake.length - 1),
              ); // Skip head and tail

    return Set.from(bodyToCheck);
  }

  /// Calculates the minimum distance to any body segment.
  ///
  /// This can be useful for AI to avoid getting too close to the body.
  static double getDistanceToNearestBodySegment(
    Snake snake,
    Position position,
  ) {
    final bodyPositions = getSelfCollisionPositions(snake);

    if (bodyPositions.isEmpty) return double.infinity;

    double minDistance = double.infinity;
    for (final bodyPos in bodyPositions) {
      final distance = _calculateManhattanDistance(position, bodyPos);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  /// Performs batch self-collision checking for multiple positions.
  static Map<Position, CollisionResult> checkMultiplePositions(
    Snake snake,
    List<Position> positions,
  ) {
    final results = <Position, CollisionResult>{};

    for (final position in positions) {
      results[position] = checkSelfCollisionAtPosition(snake, position);
    }

    return results;
  }

  /// Updates the body position cache for optimized collision detection.
  static void _updateBodyCache(Snake snake) {
    _bodyPositionCache.clear();

    // Skip if snake has only one segment (head only)
    if (snake.length <= 1) {
      return;
    }

    // Add body positions excluding the head (since head can't collide with itself)
    // and excluding tail if not growing (since tail will move away)
    final bodyToCheck = snake.shouldGrow
        ? snake.body.skip(1) // Skip head
        : snake.body
              .skip(1)
              .take(
                (snake.length - 2).clamp(0, snake.length - 1),
              ); // Skip head and tail

    _bodyPositionCache.addAll(bodyToCheck);
  }

  /// Finds the index of the body segment that would be hit by collision.
  static int _findCollisionSegmentIndex(Snake snake, Position position) {
    for (int i = 1; i < snake.body.length; i++) {
      // Start from 1 to skip head
      if (snake.body[i] == position) {
        return i;
      }
    }
    return -1; // Not found
  }

  /// Calculates distance from the given position to the snake's tail.
  static int _getDistanceFromTail(Snake snake, Position position) {
    final tailIndex = snake.body.indexOf(position);
    return tailIndex >= 0 ? snake.body.length - 1 - tailIndex : -1;
  }

  /// Calculates Manhattan distance between two positions.
  static double _calculateManhattanDistance(Position a, Position b) {
    return (a.x - b.x).abs().toDouble() + (a.y - b.y).abs().toDouble();
  }

  /// Clears the internal cache (useful for testing or when switching snakes).
  static void clearCache() {
    _bodyPositionCache.clear();
    _lastCachedSnake = null;
  }
}
