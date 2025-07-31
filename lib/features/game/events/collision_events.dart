import '../../../core/models/position.dart';
import '../models/collision.dart';

/// Base class for all collision events.
abstract class CollisionEvent {
  /// The collision result that triggered this event.
  final CollisionResult collision;

  /// Timestamp when this event was created.
  final DateTime timestamp;

  /// Whether this event has been handled.
  bool _handled = false;

  /// Creates a new collision event.
  CollisionEvent({required this.collision, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Whether this event has been handled.
  bool get handled => _handled;

  /// Marks this event as handled.
  void markHandled() {
    _handled = true;
  }

  /// Gets the collision type.
  CollisionType get collisionType => collision.type;

  /// Gets the collision point.
  Position? get collisionPoint => collision.collisionPoint;

  /// Whether this collision ends the game.
  bool get isGameEnding => collision.isGameEnding;
}

/// Event fired when a wall collision occurs.
class WallCollisionEvent extends CollisionEvent {
  /// The boundary that was hit.
  final String boundaryType;

  /// Creates a new wall collision event.
  WallCollisionEvent({
    required super.collision,
    required this.boundaryType,
    super.timestamp,
  });

  @override
  String toString() {
    return 'WallCollisionEvent(boundary: $boundaryType, point: $collisionPoint)';
  }
}

/// Event fired when a self collision occurs.
class SelfCollisionEvent extends CollisionEvent {
  /// The index of the body segment that was hit.
  final int collisionSegmentIndex;

  /// The length of the snake when collision occurred.
  final int snakeLength;

  /// Creates a new self collision event.
  SelfCollisionEvent({
    required super.collision,
    required this.collisionSegmentIndex,
    required this.snakeLength,
    super.timestamp,
  });

  @override
  String toString() {
    return 'SelfCollisionEvent(segment: $collisionSegmentIndex/$snakeLength, point: $collisionPoint)';
  }
}

/// Event fired when a food collision occurs.
class FoodCollisionEvent extends CollisionEvent {
  /// The score value of the consumed food.
  final int scoreValue;

  /// ID of the food item that was consumed.
  final int foodId;

  /// Creates a new food collision event.
  FoodCollisionEvent({
    required super.collision,
    required this.scoreValue,
    required this.foodId,
    super.timestamp,
  });

  @override
  String toString() {
    return 'FoodCollisionEvent(foodId: $foodId, score: $scoreValue, point: $collisionPoint)';
  }
}

/// Event fired when no collision occurs (for completeness).
class NoCollisionEvent extends CollisionEvent {
  /// Creates a new no collision event.
  NoCollisionEvent({required super.collision, super.timestamp});

  @override
  String toString() {
    return 'NoCollisionEvent(detectionTime: ${collision.detectionTime}ms)';
  }
}

/// Event handler function type for collision events.
typedef CollisionEventHandler<T extends CollisionEvent> =
    void Function(T event);

/// Collision event dispatcher for managing collision event handling.
class CollisionEventDispatcher {
  /// Map of event handlers by event type.
  final Map<Type, List<Function>> _handlers = {};

  /// List of all events for debugging/analysis.
  final List<CollisionEvent> _eventHistory = [];

  /// Maximum events to keep in history.
  static const int maxHistorySize = 1000;

  /// Registers an event handler for a specific collision event type.
  void on<T extends CollisionEvent>(CollisionEventHandler<T> handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  /// Unregisters an event handler.
  void off<T extends CollisionEvent>(CollisionEventHandler<T> handler) {
    _handlers[T]?.remove(handler);
  }

  /// Dispatches a collision event to all registered handlers.
  void dispatch(CollisionEvent event) {
    // Add to history
    _eventHistory.add(event);
    if (_eventHistory.length > maxHistorySize) {
      _eventHistory.removeAt(0);
    }

    // Get handlers for this event type
    final handlers = _handlers[event.runtimeType];
    if (handlers != null) {
      for (final handler in handlers) {
        (handler as Function)(event);
      }
    }

    // Mark event as handled after dispatching
    event.markHandled();
  }

  /// Creates and dispatches appropriate collision event based on collision result.
  void dispatchCollisionResult(CollisionResult result) {
    CollisionEvent event;

    switch (result.type) {
      case CollisionType.wall:
        event = WallCollisionEvent(
          collision: result,
          boundaryType: result.metadata['boundary_violated'] ?? 'unknown',
        );
        break;

      case CollisionType.selfCollision:
        event = SelfCollisionEvent(
          collision: result,
          collisionSegmentIndex:
              result.metadata['collision_segment_index'] ?? -1,
          snakeLength: result.metadata['snake_length'] ?? 0,
        );
        break;

      case CollisionType.food:
        event = FoodCollisionEvent(
          collision: result,
          scoreValue: result.metadata['score_value'] ?? 10,
          foodId: result.metadata['food_id'] ?? 0,
        );
        break;

      case CollisionType.none:
        event = NoCollisionEvent(collision: result);
        break;

      case CollisionType.otherSnake:
        // For future multiplayer implementation
        event = NoCollisionEvent(collision: result);
        break;
    }

    dispatch(event);
  }

  /// Gets the event history.
  List<CollisionEvent> get eventHistory => List.unmodifiable(_eventHistory);

  /// Gets events of a specific type from history.
  List<T> getEventsOfType<T extends CollisionEvent>() {
    return _eventHistory.whereType<T>().toList();
  }

  /// Gets recent events (last N events).
  List<CollisionEvent> getRecentEvents([int count = 50]) {
    final startIndex = (_eventHistory.length - count).clamp(
      0,
      _eventHistory.length,
    );
    return _eventHistory.sublist(startIndex);
  }

  /// Gets collision statistics from event history.
  Map<CollisionType, int> getCollisionStats() {
    final stats = <CollisionType, int>{};

    for (final event in _eventHistory) {
      final type = event.collisionType;
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return stats;
  }

  /// Clears the event history.
  void clearHistory() {
    _eventHistory.clear();
  }

  /// Clears all handlers.
  void clearHandlers() {
    _handlers.clear();
  }

  /// Gets the number of registered handlers.
  int get handlerCount =>
      _handlers.values.fold(0, (sum, handlers) => sum + handlers.length);

  @override
  String toString() {
    return 'CollisionEventDispatcher(handlers: $handlerCount, history: ${_eventHistory.length})';
  }
}
