import '../../../core/models/enums.dart';
import '../../../core/models/position.dart';

/// Represents the result of a snake movement operation.
class SnakeMoveResult {
  /// The new head position after the move.
  final Position newHeadPosition;

  /// Whether the snake consumed food during this move.
  final bool ateFood;

  /// The updated positions of the snake after the move.
  final List<Position> updatedPositions;

  /// Whether the move was successful.
  final bool success;

  /// Any error message if the move failed.
  final String? error;

  const SnakeMoveResult({
    required this.newHeadPosition,
    required this.ateFood,
    required this.updatedPositions,
    required this.success,
    this.error,
  });

  /// Creates a successful move result.
  factory SnakeMoveResult.success({
    required Position newHeadPosition,
    required List<Position> updatedPositions,
    bool ateFood = false,
  }) {
    return SnakeMoveResult(
      newHeadPosition: newHeadPosition,
      ateFood: ateFood,
      updatedPositions: updatedPositions,
      success: true,
    );
  }

  /// Creates a failed move result.
  factory SnakeMoveResult.failure({
    required Position newHeadPosition,
    required String error,
  }) {
    return SnakeMoveResult(
      newHeadPosition: newHeadPosition,
      ateFood: false,
      updatedPositions: const [],
      success: false,
      error: error,
    );
  }
}

/// Represents a collision result in multiplayer context.
class MultiplayerCollisionResult {
  /// The ID of the player involved in the collision.
  final String playerId;

  /// The type of collision that occurred.
  final MultiplayerCollisionType collisionType;

  /// The position where the collision occurred.
  final Position collisionPoint;

  /// Whether this collision results in the player's death.
  final bool isDead;

  /// The ID of the other player involved (for inter-player collisions).
  final String? otherPlayerId;

  /// Additional metadata about the collision.
  final Map<String, dynamic> metadata;

  const MultiplayerCollisionResult({
    required this.playerId,
    required this.collisionType,
    required this.collisionPoint,
    required this.isDead,
    this.otherPlayerId,
    this.metadata = const {},
  });

  @override
  String toString() {
    return 'MultiplayerCollisionResult('
        'player: $playerId, '
        'type: $collisionType, '
        'point: $collisionPoint, '
        'dead: $isDead, '
        'other: $otherPlayerId'
        ')';
  }
}

/// Types of collisions in multiplayer games.
enum MultiplayerCollisionType {
  /// No collision.
  none,

  /// Collision with game boundary.
  wall,

  /// Collision with own body.
  self,

  /// Collision with another snake's body.
  otherSnake,

  /// Head-to-head collision with another snake.
  headToHead,

  /// Collision with food.
  food,
}

/// Represents the result of a complete game update cycle.
class GameUpdateResult {
  /// Whether the game has ended.
  final bool gameEnded;

  /// The ID of the winning player (if game ended).
  final String? winner;

  /// Current state of all snakes.
  final Map<String, MultiplayerSnake> snakes;

  /// List of collisions that occurred this update.
  final List<MultiplayerCollisionResult> collisions;

  /// The current food position.
  final Position? foodPosition;

  /// Additional game state information.
  final Map<String, dynamic> metadata;

  const GameUpdateResult({
    required this.gameEnded,
    this.winner,
    required this.snakes,
    this.collisions = const [],
    this.foodPosition,
    this.metadata = const {},
  });
}

/// Represents a snake in multiplayer context.
class MultiplayerSnake {
  /// Current positions of the snake (head first).
  final List<Position> positions;

  /// Current direction of movement.
  final Direction direction;

  /// Whether the snake is alive.
  final bool alive;

  /// Current score of the snake.
  final int score;

  /// The color/identifier for visual representation.
  final String playerId;

  const MultiplayerSnake({
    required this.positions,
    required this.direction,
    required this.alive,
    required this.score,
    required this.playerId,
  });

  /// Gets the head position.
  Position get head =>
      positions.isNotEmpty ? positions.first : const Position(0, 0);

  /// Gets the tail position.
  Position get tail =>
      positions.isNotEmpty ? positions.last : const Position(0, 0);

  /// Gets the length of the snake.
  int get length => positions.length;

  /// Creates a copy with updated values.
  MultiplayerSnake copyWith({
    List<Position>? positions,
    Direction? direction,
    bool? alive,
    int? score,
    String? playerId,
  }) {
    return MultiplayerSnake(
      positions: positions ?? this.positions,
      direction: direction ?? this.direction,
      alive: alive ?? this.alive,
      score: score ?? this.score,
      playerId: playerId ?? this.playerId,
    );
  }

  @override
  String toString() {
    return 'MultiplayerSnake('
        'player: $playerId, '
        'length: $length, '
        'head: $head, '
        'alive: $alive, '
        'score: $score'
        ')';
  }
}
