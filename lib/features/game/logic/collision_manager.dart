import '../../../core/models/position.dart';
import '../../../core/utils/collision_profiler.dart';
import '../models/collision.dart';
import '../models/collision_context.dart';
import 'self_collision_detector.dart';
import 'wall_collision_detector.dart';

/// Centralized collision detection manager with performance monitoring.
///
/// This class coordinates all collision detection operations and provides
/// a unified interface for checking various types of collisions with
/// integrated performance profiling.
class CollisionManager {
  /// Performance profiler for tracking collision detection metrics.
  static final CollisionProfiler _profiler = CollisionProfiler();

  /// Checks all possible collisions for the given context.
  ///
  /// Performs collision detection in order of likelihood and performance:
  /// 1. Wall collisions (fastest, most common)
  /// 2. Self collisions (optimized with caching)
  /// 3. Food collisions (least critical)
  static CollisionResult checkAllCollisions(CollisionContext context) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    // Check wall collision first (fastest and most critical)
    final wallResult = checkWallCollision(context);
    if (wallResult.hasCollision && wallResult.isGameEnding) {
      _profiler.recordCollision(wallResult);
      return wallResult;
    }

    // Check self collision second (critical for gameplay)
    final selfResult = checkSelfCollision(context);
    if (selfResult.hasCollision && selfResult.isGameEnding) {
      _profiler.recordCollision(selfResult);
      return selfResult;
    }

    // Check food collisions last (not game-ending)
    final foodResult = checkFoodCollisions(context);
    _profiler.recordCollision(foodResult);

    // Record total detection time
    final totalTime =
        (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;
    _profiler.recordTotalDetectionTime(totalTime);

    // Return the most significant collision (food or none)
    return foodResult;
  }

  /// Checks for wall collisions using the collision context.
  static CollisionResult checkWallCollision(CollisionContext context) {
    return WallCollisionDetector.checkWallCollisionFromContext(context);
  }

  /// Checks for self collisions using the collision context.
  static CollisionResult checkSelfCollision(CollisionContext context) {
    return SelfCollisionDetector.checkSelfCollisionFromContext(context);
  }

  /// Checks for food collisions using the collision context.
  static CollisionResult checkFoodCollisions(CollisionContext context) {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    final nextPosition = context.nextHeadPosition;

    // Check collision with each active food item
    for (final food in context.foods) {
      if (food.isActive && food.position == nextPosition) {
        final detectionTime =
            (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;

        return CollisionResult.foodCollision(
          collisionPoint: nextPosition,
          detectionTime: detectionTime,
          metadata: {
            'food_id': food.hashCode,
            'food_type': food.runtimeType.toString(),
            'score_value': 10, // Default score value
          },
        );
      }
    }

    final detectionTime =
        (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;
    return CollisionResult.none(detectionTime: detectionTime);
  }

  /// Checks for collisions at a specific position.
  ///
  /// This method is useful for predictive collision checking or AI pathfinding.
  static CollisionResult checkCollisionAtPosition(
    CollisionContext context,
    Position position,
  ) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    // Check wall collision at position
    final wallResult = WallCollisionDetector.checkWallCollision(
      position,
      context.gameArea,
    );
    if (wallResult.hasCollision) {
      _profiler.recordCollision(wallResult);
      return wallResult;
    }

    // Check self collision at position
    final selfResult = SelfCollisionDetector.checkSelfCollisionAtPosition(
      context.snake,
      position,
    );
    if (selfResult.hasCollision) {
      _profiler.recordCollision(selfResult);
      return selfResult;
    }

    // Check food collision at position
    for (final food in context.foods) {
      if (food.isActive && food.position == position) {
        final detectionTime =
            (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;

        final foodResult = CollisionResult.foodCollision(
          collisionPoint: position,
          detectionTime: detectionTime,
        );
        _profiler.recordCollision(foodResult);
        return foodResult;
      }
    }

    final detectionTime =
        (DateTime.now().microsecondsSinceEpoch - startTime) / 1000.0;
    final noCollisionResult = CollisionResult.none(
      detectionTime: detectionTime,
    );
    _profiler.recordCollision(noCollisionResult);

    return noCollisionResult;
  }

  /// Performs batch collision checking for multiple positions.
  ///
  /// This is more efficient than checking positions individually.
  static Map<Position, CollisionResult> checkMultiplePositions(
    CollisionContext context,
    List<Position> positions,
  ) {
    final results = <Position, CollisionResult>{};

    for (final position in positions) {
      results[position] = checkCollisionAtPosition(context, position);
    }

    return results;
  }

  /// Checks if any collision would occur in the next move.
  ///
  /// Returns true if any game-ending collision would occur.
  static bool wouldCollideInNextMove(CollisionContext context) {
    final result = checkAllCollisions(context);
    return result.hasCollision && result.isGameEnding;
  }

  /// Gets all positions that would cause collisions.
  ///
  /// Returns a set of positions that the snake cannot move to safely.
  static Set<Position> getCollisionPositions(CollisionContext context) {
    final collisionPositions = <Position>{};

    // Add wall positions (out of bounds)
    final gameArea = context.gameArea;

    // Add positions outside game boundaries
    for (int x = -1; x <= gameArea.width; x++) {
      collisionPositions.add(Position(x, -1)); // Top boundary
      collisionPositions.add(
        Position(x, gameArea.height.toInt()),
      ); // Bottom boundary
    }
    for (int y = -1; y <= gameArea.height; y++) {
      collisionPositions.add(Position(-1, y)); // Left boundary
      collisionPositions.add(
        Position(gameArea.width.toInt(), y),
      ); // Right boundary
    }

    // Add self-collision positions
    collisionPositions.addAll(
      SelfCollisionDetector.getSelfCollisionPositions(context.snake),
    );

    return collisionPositions;
  }

  /// Gets safe positions around the snake's current position.
  ///
  /// Returns positions that would not result in immediate collision.
  static Set<Position> getSafePositions(CollisionContext context) {
    final safePositions = <Position>{};
    final snake = context.snake;
    final head = snake.head;

    // Check all adjacent positions
    final adjacentPositions = [
      Position(head.x, head.y - 1), // Up
      Position(head.x, head.y + 1), // Down
      Position(head.x - 1, head.y), // Left
      Position(head.x + 1, head.y), // Right
    ];

    for (final pos in adjacentPositions) {
      final result = checkCollisionAtPosition(context, pos);
      if (!result.hasCollision || !result.isGameEnding) {
        safePositions.add(pos);
      }
    }

    return safePositions;
  }

  /// Gets the collision profiler for performance analysis.
  static CollisionProfiler get profiler => _profiler;

  /// Resets the collision profiler.
  static void resetProfiler() {
    _profiler.reset();
  }

  /// Gets performance statistics.
  static Map<String, dynamic> getPerformanceStats() {
    return _profiler.getPerformanceReport();
  }

  /// Checks if collision detection meets performance requirements.
  static bool meetsPerformanceRequirements() {
    return _profiler.meetsPerformanceRequirements();
  }

  /// Clears all internal caches (useful for testing).
  static void clearCaches() {
    SelfCollisionDetector.clearCache();
    _profiler.reset();
  }
}
