import '../../../core/models/position.dart';
import '../models/collision.dart';
import '../models/collision_context.dart';

/// High-performance wall collision detector.
///
/// This class provides optimized algorithms for detecting collisions
/// between the snake and the game boundaries with sub-millisecond
/// performance requirements.
class WallCollisionDetector {
  /// Checks for wall collision at the given position.
  ///
  /// Returns a collision result with performance timing information.
  static CollisionResult checkWallCollision(
    Position position,
    GameAreaSize gameArea,
  ) {
    final startTime = DateTime.now().microsecondsSinceEpoch;

    final isOutOfBounds =
        position.x < 0 ||
        position.x >= gameArea.width ||
        position.y < 0 ||
        position.y >= gameArea.height;

    final endTime = DateTime.now().microsecondsSinceEpoch;
    final detectionTime =
        (endTime - startTime) / 1000.0; // Convert to milliseconds

    if (isOutOfBounds) {
      return CollisionResult.wallCollision(
        collisionPoint: position,
        detectionTime: detectionTime,
        metadata: {
          'boundary_violated': _getBoundaryViolationType(position, gameArea),
          'distance_from_boundary': _getDistanceFromNearestBoundary(
            position,
            gameArea,
          ),
        },
      );
    }

    return CollisionResult.none(detectionTime: detectionTime);
  }

  /// Checks for wall collision using collision context.
  ///
  /// This method uses the context's next head position for collision checking.
  static CollisionResult checkWallCollisionFromContext(
    CollisionContext context,
  ) {
    return checkWallCollision(context.nextHeadPosition, context.gameArea);
  }

  /// Checks if a position is out of bounds (without timing).
  ///
  /// This is a lightweight check for cases where performance timing is not needed.
  static bool isPositionOutOfBounds(Position position, GameAreaSize gameArea) {
    return position.x < 0 ||
        position.x >= gameArea.width ||
        position.y < 0 ||
        position.y >= gameArea.height;
  }

  /// Checks if a position is within bounds.
  static bool isPositionInBounds(Position position, GameAreaSize gameArea) {
    return !isPositionOutOfBounds(position, gameArea);
  }

  /// Gets all boundary positions for the given game area.
  ///
  /// Returns a set of all positions that are on the boundary of the game area.
  static Set<Position> getBoundaryPositions(GameAreaSize gameArea) {
    final boundaries = <Position>{};
    final width = gameArea.width.toInt();
    final height = gameArea.height.toInt();

    // Top and bottom boundaries
    for (int x = 0; x < width; x++) {
      boundaries.add(Position(x, 0)); // Top
      boundaries.add(Position(x, height - 1)); // Bottom
    }

    // Left and right boundaries (excluding corners already added)
    for (int y = 1; y < height - 1; y++) {
      boundaries.add(Position(0, y)); // Left
      boundaries.add(Position(width - 1, y)); // Right
    }

    return boundaries;
  }

  /// Calculates the minimum distance from a position to any boundary.
  static double getDistanceToNearestBoundary(
    Position position,
    GameAreaSize gameArea,
  ) {
    final distanceToLeft = position.x.toDouble();
    final distanceToRight = gameArea.width - position.x.toDouble() - 1;
    final distanceToTop = position.y.toDouble();
    final distanceToBottom = gameArea.height - position.y.toDouble() - 1;

    final distances = [
      distanceToLeft,
      distanceToRight,
      distanceToTop,
      distanceToBottom,
    ];
    return distances.reduce((a, b) => a < b ? a : b);
  }

  /// Gets the type of boundary violation for an out-of-bounds position.
  static String _getBoundaryViolationType(
    Position position,
    GameAreaSize gameArea,
  ) {
    final violations = <String>[];

    if (position.x < 0) violations.add('left');
    if (position.x >= gameArea.width) violations.add('right');
    if (position.y < 0) violations.add('top');
    if (position.y >= gameArea.height) violations.add('bottom');

    return violations.join('+');
  }

  /// Gets the distance from the nearest boundary (negative if out of bounds).
  static double _getDistanceFromNearestBoundary(
    Position position,
    GameAreaSize gameArea,
  ) {
    if (isPositionInBounds(position, gameArea)) {
      return getDistanceToNearestBoundary(position, gameArea);
    }

    // For out of bounds positions, calculate how far outside
    double distance = 0.0;

    if (position.x < 0) distance = position.x.abs().toDouble();
    if (position.x >= gameArea.width) {
      distance = (position.x - gameArea.width + 1).toDouble();
    }
    if (position.y < 0) distance = position.y.abs().toDouble();
    if (position.y >= gameArea.height) {
      distance = (position.y - gameArea.height + 1).toDouble();
    }

    return -distance; // Negative to indicate out of bounds
  }

  /// Performs batch collision checking for multiple positions.
  ///
  /// This is more efficient than checking positions individually when
  /// checking multiple positions against the same game area.
  static Map<Position, CollisionResult> checkMultiplePositions(
    List<Position> positions,
    GameAreaSize gameArea,
  ) {
    final startTime = DateTime.now().microsecondsSinceEpoch;
    final results = <Position, CollisionResult>{};

    for (final position in positions) {
      final isOutOfBounds =
          position.x < 0 ||
          position.x >= gameArea.width ||
          position.y < 0 ||
          position.y >= gameArea.height;

      final individualTime =
          (DateTime.now().microsecondsSinceEpoch - startTime) /
          1000.0 /
          positions.length;

      if (isOutOfBounds) {
        results[position] = CollisionResult.wallCollision(
          collisionPoint: position,
          detectionTime: individualTime,
        );
      } else {
        results[position] = CollisionResult.none(detectionTime: individualTime);
      }
    }

    return results;
  }
}
