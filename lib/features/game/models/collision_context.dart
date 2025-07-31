import '../../../core/models/position.dart';
import 'food.dart';
import 'snake.dart';

/// Simple size class for collision context.
class GameAreaSize {
  final double width;
  final double height;

  const GameAreaSize(this.width, this.height);
}

/// Context information for collision detection operations.
///
/// This class contains all the necessary information for performing
/// collision detection in a specific game state.
class CollisionContext {
  /// The snake being checked for collisions.
  final Snake snake;

  /// The size of the game area (in grid units).
  final GameAreaSize gameArea;

  /// List of all active food items.
  final List<Food> foods;

  /// Current frame number for tracking.
  final int frameNumber;

  /// Timestamp when this context was created.
  final DateTime timestamp;

  /// Additional context-specific metadata.
  final Map<String, dynamic> metadata;

  /// Creates a new collision context.
  const CollisionContext({
    required this.snake,
    required this.gameArea,
    required this.foods,
    required this.frameNumber,
    required this.timestamp,
    this.metadata = const {},
  });

  /// Creates a collision context from game state.
  factory CollisionContext.fromGameState({
    required Snake snake,
    required int gridWidth,
    required int gridHeight,
    Food? currentFood,
    required int frameNumber,
    Map<String, dynamic> metadata = const {},
  }) {
    final foods = currentFood != null ? [currentFood] : <Food>[];

    return CollisionContext(
      snake: snake,
      gameArea: GameAreaSize(gridWidth.toDouble(), gridHeight.toDouble()),
      foods: foods,
      frameNumber: frameNumber,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Gets the next position the snake's head would move to.
  Position get nextHeadPosition {
    final direction = snake.nextDirection ?? snake.currentDirection;
    final (dx, dy) = direction.delta;
    return Position(snake.head.x + dx, snake.head.y + dy);
  }

  /// Gets all positions currently occupied by the snake.
  Set<Position> get snakePositions => snake.occupiedPositions;

  /// Gets all positions currently occupied by food.
  Set<Position> get foodPositions {
    return foods
        .where((food) => food.isActive)
        .map((food) => food.position)
        .toSet();
  }

  /// Gets all positions that are blocked (occupied by snake body excluding tail if growing).
  Set<Position> get blockedPositions {
    final positions = <Position>{};

    // Add snake body positions (excluding tail if not growing)
    final bodyToCheck = snake.shouldGrow
        ? snake.body
        : snake.body.take(snake.length - 1);

    positions.addAll(bodyToCheck);

    return positions;
  }

  /// Whether the game area includes the given position.
  bool isPositionInBounds(Position position) {
    return position.x >= 0 &&
        position.x < gameArea.width &&
        position.y >= 0 &&
        position.y < gameArea.height;
  }

  /// Creates a copy of this context with updated values.
  CollisionContext copyWith({
    Snake? snake,
    GameAreaSize? gameArea,
    List<Food>? foods,
    int? frameNumber,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return CollisionContext(
      snake: snake ?? this.snake,
      gameArea: gameArea ?? this.gameArea,
      foods: foods ?? this.foods,
      frameNumber: frameNumber ?? this.frameNumber,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'CollisionContext('
        'snake: ${snake.length} segments, '
        'gameArea: ${gameArea.width}x${gameArea.height}, '
        'foods: ${foods.length}, '
        'frame: $frameNumber'
        ')';
  }
}
