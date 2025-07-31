import '../../../core/models/position.dart';

/// Types of collisions that can occur in the game.
enum CollisionType {
  /// No collision detected.
  none,

  /// Collision with game boundary/wall.
  wall,

  /// Collision with snake's own body.
  selfCollision,

  /// Collision with another snake (for future multiplayer).
  otherSnake,

  /// Collision with food (not game-ending).
  food,
}

/// Result of a collision detection check.
class CollisionResult {
  /// The type of collision detected.
  final CollisionType type;

  /// The exact position where the collision occurred (if applicable).
  final Position? collisionPoint;

  /// Whether this collision should end the game.
  final bool isGameEnding;

  /// Time taken to detect this collision in milliseconds.
  final double detectionTime;

  /// Additional metadata about the collision.
  final Map<String, dynamic> metadata;

  /// Creates a new collision result.
  const CollisionResult({
    required this.type,
    this.collisionPoint,
    required this.isGameEnding,
    required this.detectionTime,
    this.metadata = const {},
  });

  /// Creates a collision result with no collision.
  factory CollisionResult.none({required double detectionTime}) {
    return CollisionResult(
      type: CollisionType.none,
      isGameEnding: false,
      detectionTime: detectionTime,
    );
  }

  /// Creates a collision result for wall collision.
  factory CollisionResult.wallCollision({
    required Position collisionPoint,
    required double detectionTime,
    Map<String, dynamic> metadata = const {},
  }) {
    return CollisionResult(
      type: CollisionType.wall,
      collisionPoint: collisionPoint,
      isGameEnding: true,
      detectionTime: detectionTime,
      metadata: metadata,
    );
  }

  /// Creates a collision result for self collision.
  factory CollisionResult.selfCollision({
    required Position collisionPoint,
    required double detectionTime,
    Map<String, dynamic> metadata = const {},
  }) {
    return CollisionResult(
      type: CollisionType.selfCollision,
      collisionPoint: collisionPoint,
      isGameEnding: true,
      detectionTime: detectionTime,
      metadata: metadata,
    );
  }

  /// Creates a collision result for food collision.
  factory CollisionResult.foodCollision({
    required Position collisionPoint,
    required double detectionTime,
    Map<String, dynamic> metadata = const {},
  }) {
    return CollisionResult(
      type: CollisionType.food,
      collisionPoint: collisionPoint,
      isGameEnding: false,
      detectionTime: detectionTime,
      metadata: metadata,
    );
  }

  /// Whether this collision has occurred.
  bool get hasCollision => type != CollisionType.none;

  @override
  String toString() {
    return 'CollisionResult('
        'type: $type, '
        'point: $collisionPoint, '
        'gameEnding: $isGameEnding, '
        'time: ${detectionTime.toStringAsFixed(3)}ms'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CollisionResult &&
        other.type == type &&
        other.collisionPoint == collisionPoint &&
        other.isGameEnding == isGameEnding;
  }

  @override
  int get hashCode {
    return Object.hash(type, collisionPoint, isGameEnding);
  }
}
