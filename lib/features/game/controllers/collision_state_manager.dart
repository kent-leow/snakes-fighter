import '../../../core/models/position.dart';
import '../../../core/utils/grid_system.dart';
import '../events/collision_events.dart';
import '../logic/collision_manager.dart';
import '../models/collision.dart';
import '../models/collision_context.dart';
import '../models/food.dart';
import '../models/snake.dart';

/// Manages game state with integrated collision detection and event handling.
///
/// This class coordinates collision checking with game state updates and
/// provides event-driven collision handling for extensible game logic.
class CollisionStateManager {
  /// The collision event dispatcher.
  final CollisionEventDispatcher _eventDispatcher = CollisionEventDispatcher();

  /// Current frame number for collision context.
  int _frameNumber = 0;

  /// Whether collision events are enabled.
  bool _eventsEnabled = true;

  /// Grid system for collision context.
  final GridSystem _gridSystem;

  /// Creates a new collision state manager.
  CollisionStateManager({required GridSystem gridSystem})
    : _gridSystem = gridSystem {
    _setupDefaultEventHandlers();
  }

  /// Gets the collision event dispatcher.
  CollisionEventDispatcher get eventDispatcher => _eventDispatcher;

  /// Gets the current frame number.
  int get frameNumber => _frameNumber;

  /// Whether collision events are enabled.
  bool get eventsEnabled => _eventsEnabled;

  /// Enables or disables collision events.
  void setEventsEnabled(bool enabled) {
    _eventsEnabled = enabled;
  }

  /// Processes collision detection for the given game state.
  ///
  /// Returns the collision result and dispatches appropriate events.
  CollisionResult processCollisions({
    required Snake snake,
    Food? currentFood,
    Map<String, dynamic> metadata = const {},
  }) {
    // Create collision context
    final context = CollisionContext.fromGameState(
      snake: snake,
      gridWidth: _gridSystem.gridWidth,
      gridHeight: _gridSystem.gridHeight,
      currentFood: currentFood,
      frameNumber: _frameNumber,
      metadata: metadata,
    );

    // Check all collisions
    final result = CollisionManager.checkAllCollisions(context);

    // Dispatch collision events if enabled
    if (_eventsEnabled) {
      _eventDispatcher.dispatchCollisionResult(result);
    }

    // Increment frame counter
    _frameNumber++;

    return result;
  }

  /// Predicts collision for the next move without updating state.
  ///
  /// This is useful for AI or game logic that needs to look ahead.
  CollisionResult predictNextCollision({
    required Snake snake,
    Food? currentFood,
    Map<String, dynamic> metadata = const {},
  }) {
    final context = CollisionContext.fromGameState(
      snake: snake,
      gridWidth: _gridSystem.gridWidth,
      gridHeight: _gridSystem.gridHeight,
      currentFood: currentFood,
      frameNumber: _frameNumber,
      metadata: metadata,
    );

    return CollisionManager.checkAllCollisions(context);
  }

  /// Checks if a position is safe for the snake to move to.
  bool isPositionSafe({
    required Snake snake,
    required Position position,
    Food? currentFood,
  }) {
    final context = CollisionContext.fromGameState(
      snake: snake,
      gridWidth: _gridSystem.gridWidth,
      gridHeight: _gridSystem.gridHeight,
      currentFood: currentFood,
      frameNumber: _frameNumber,
    );

    final result = CollisionManager.checkCollisionAtPosition(context, position);
    return !result.hasCollision || !result.isGameEnding;
  }

  /// Gets all safe positions around the snake's current position.
  Set<Position> getSafePositions({required Snake snake, Food? currentFood}) {
    final context = CollisionContext.fromGameState(
      snake: snake,
      gridWidth: _gridSystem.gridWidth,
      gridHeight: _gridSystem.gridHeight,
      currentFood: currentFood,
      frameNumber: _frameNumber,
    );

    return CollisionManager.getSafePositions(context);
  }

  /// Registers a handler for wall collision events.
  void onWallCollision(CollisionEventHandler<WallCollisionEvent> handler) {
    _eventDispatcher.on<WallCollisionEvent>(handler);
  }

  /// Registers a handler for self collision events.
  void onSelfCollision(CollisionEventHandler<SelfCollisionEvent> handler) {
    _eventDispatcher.on<SelfCollisionEvent>(handler);
  }

  /// Registers a handler for food collision events.
  void onFoodCollision(CollisionEventHandler<FoodCollisionEvent> handler) {
    _eventDispatcher.on<FoodCollisionEvent>(handler);
  }

  /// Registers a handler for no collision events.
  void onNoCollision(CollisionEventHandler<NoCollisionEvent> handler) {
    _eventDispatcher.on<NoCollisionEvent>(handler);
  }

  /// Gets collision statistics from the event history.
  Map<String, dynamic> getCollisionStatistics() {
    final eventStats = _eventDispatcher.getCollisionStats();
    final performanceStats = CollisionManager.getPerformanceStats();

    return {
      'events': eventStats.map((type, count) => MapEntry(type.name, count)),
      'performance': performanceStats,
      'frame_number': _frameNumber,
      'events_enabled': _eventsEnabled,
    };
  }

  /// Resets the collision state and statistics.
  void reset() {
    _frameNumber = 0;
    _eventDispatcher.clearHistory();
    CollisionManager.resetProfiler();
  }

  /// Sets up default event handlers for common game logic.
  void _setupDefaultEventHandlers() {
    // Default handler for wall collisions
    onWallCollision((event) {
      // Log wall collision for debugging
      // In a real game, this might trigger game over logic
    });

    // Default handler for self collisions
    onSelfCollision((event) {
      // Log self collision for debugging
      // In a real game, this might trigger game over logic
    });

    // Default handler for food collisions
    onFoodCollision((event) {
      // Log food consumption for debugging
      // In a real game, this might trigger score updates and snake growth
    });
  }

  /// Gets recent collision events for analysis.
  List<CollisionEvent> getRecentEvents([int count = 50]) {
    return _eventDispatcher.getRecentEvents(count);
  }

  /// Gets events of a specific type.
  List<T> getEventsOfType<T extends CollisionEvent>() {
    return _eventDispatcher.getEventsOfType<T>();
  }

  /// Clears all event handlers (useful for testing).
  void clearEventHandlers() {
    _eventDispatcher.clearHandlers();
    _setupDefaultEventHandlers();
  }

  /// Gets performance metrics.
  bool meetsPerformanceRequirements() {
    return CollisionManager.meetsPerformanceRequirements();
  }

  /// Disposes of resources.
  void dispose() {
    _eventDispatcher.clearHandlers();
    _eventDispatcher.clearHistory();
    CollisionManager.clearCaches();
  }

  @override
  String toString() {
    return 'CollisionStateManager('
        'frame: $_frameNumber, '
        'events: $_eventsEnabled, '
        'handlers: ${_eventDispatcher.handlerCount}'
        ')';
  }
}
