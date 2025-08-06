import '../../../core/models/models.dart';

/// Service for calculating and applying delta updates to game state.
///
/// Optimizes network bandwidth by only sending changed data instead of
/// complete game state updates. Tracks last known states and calculates
/// minimal diffs for efficient synchronization.
class DeltaUpdateService {
  /// Creates a new delta update service.
  DeltaUpdateService();

  final Map<String, GameState> _lastKnownStates = {};

  /// Calculates the delta (difference) between current and last known state.
  ///
  /// Returns a map containing only the fields that have changed since the
  /// last update. If no previous state exists, returns the complete state.
  ///
  /// [roomId] The room identifier for tracking state
  /// [newState] The current game state to compare
  ///
  /// Returns a map of changed fields suitable for batch database updates
  Map<String, dynamic> calculateDelta(String roomId, GameState newState) {
    final lastState = _lastKnownStates[roomId];
    if (lastState == null) {
      _lastKnownStates[roomId] = newState;
      return _buildCompleteStateUpdate(newState);
    }

    final delta = <String, dynamic>{};

    // Compare and add only changed snake data
    _compareSnakes(lastState, newState, delta);

    // Compare food position
    if (!_foodEqual(lastState.food, newState.food)) {
      delta['food'] = newState.food.toJson();
    }

    // Compare winner
    if (lastState.winner != newState.winner) {
      delta['winner'] = newState.winner;
    }

    // Compare end time
    if (lastState.endedAt != newState.endedAt) {
      delta['endedAt'] = newState.endedAt?.toIso8601String();
    }

    _lastKnownStates[roomId] = newState;
    return delta;
  }

  /// Builds a complete state update for initial synchronization.
  Map<String, dynamic> _buildCompleteStateUpdate(GameState state) {
    return {
      'food': state.food.toJson(),
      'snakes': _snakesToJson(state.snakes),
      'winner': state.winner,
      'endedAt': state.endedAt?.toIso8601String(),
      'startedAt': state.startedAt.toIso8601String(),
    };
  }

  /// Compares snakes between states and adds changes to delta.
  void _compareSnakes(
    GameState lastState,
    GameState newState,
    Map<String, dynamic> delta,
  ) {
    // Check for new or modified snakes
    for (final entry in newState.snakes.entries) {
      final playerId = entry.key;
      final newSnake = entry.value;
      final oldSnake = lastState.snakes[playerId];

      if (oldSnake == null || !_snakesEqual(oldSnake, newSnake)) {
        delta['snakes/$playerId'] = newSnake.toJson();
      }
    }

    // Check for removed snakes
    for (final playerId in lastState.snakes.keys) {
      if (!newState.snakes.containsKey(playerId)) {
        delta['snakes/$playerId'] = null; // Remove snake
      }
    }
  }

  /// Compares two snakes for equality.
  bool _snakesEqual(Snake snake1, Snake snake2) {
    return snake1.direction == snake2.direction &&
        snake1.alive == snake2.alive &&
        snake1.score == snake2.score &&
        _positionsEqual(snake1.positions, snake2.positions);
  }

  /// Compares two food objects for equality.
  bool _foodEqual(Food food1, Food food2) {
    return food1.position == food2.position && food1.value == food2.value;
  }

  /// Compares two position lists for equality.
  bool _positionsEqual(List<Position> pos1, List<Position> pos2) {
    if (pos1.length != pos2.length) return false;
    for (int i = 0; i < pos1.length; i++) {
      if (pos1[i] != pos2[i]) return false;
    }
    return true;
  }

  /// Converts snakes map to JSON format.
  Map<String, dynamic> _snakesToJson(Map<String, Snake> snakes) {
    return snakes.map((key, value) => MapEntry(key, value.toJson()));
  }

  /// Calculates optimized snake position update.
  ///
  /// For performance, only sends essential snake data: head position,
  /// direction, alive status, and score. Full position arrays are only
  /// sent when necessary (snake growth, respawn, etc.).
  Map<String, dynamic> calculateSnakePositionDelta(
    String roomId,
    String playerId,
    Snake newSnake,
  ) {
    final lastState = _lastKnownStates[roomId];
    final lastSnake = lastState?.snakes[playerId];

    if (lastSnake == null) {
      // First time or snake respawn - send complete data
      return {'snakes/$playerId': newSnake.toJson()};
    }

    final delta = <String, dynamic>{};

    // Always update head position and direction for movement
    if (newSnake.positions.isNotEmpty) {
      delta['snakes/$playerId/head'] = newSnake.head.toJson();
    }

    // Update direction if changed
    if (lastSnake.direction != newSnake.direction) {
      delta['snakes/$playerId/direction'] = newSnake.direction.name;
    }

    // Update alive status if changed
    if (lastSnake.alive != newSnake.alive) {
      delta['snakes/$playerId/alive'] = newSnake.alive;
    }

    // Update score if changed
    if (lastSnake.score != newSnake.score) {
      delta['snakes/$playerId/score'] = newSnake.score;
    }

    // Send full positions only if snake grew/shrank significantly
    if (lastSnake.positions.length != newSnake.positions.length ||
        _shouldSendFullPositions(lastSnake, newSnake)) {
      delta['snakes/$playerId/positions'] = newSnake.positions
          .map((p) => p.toJson())
          .toList();
    }

    return delta;
  }

  /// Determines if full position array should be sent.
  ///
  /// Returns true if the snake has grown, been reset, or if there's
  /// a significant discrepancy in positions that requires full sync.
  bool _shouldSendFullPositions(Snake lastSnake, Snake newSnake) {
    // If lengths differ significantly, send full positions
    final lengthDiff = (newSnake.positions.length - lastSnake.positions.length)
        .abs();
    if (lengthDiff > 1) return true;

    // If snake died and respawned, send full positions
    if (!lastSnake.alive && newSnake.alive) return true;

    // If more than just the head changed, send full positions
    if (newSnake.positions.length > 1 && lastSnake.positions.length > 1) {
      // Check if body positions match (excluding head)
      final newBody = newSnake.body;
      final lastBody = lastSnake.body;

      if (newBody.length != lastBody.length) return true;

      // Check if any body position changed unexpectedly
      for (int i = 0; i < newBody.length && i < lastBody.length; i++) {
        if (newBody[i] != lastBody[i]) return true;
      }
    }

    return false;
  }

  /// Calculates the size of a delta update in bytes (approximate).
  ///
  /// Useful for monitoring bandwidth usage and optimization.
  /// Returns approximate JSON size in bytes.
  int calculateDeltaSize(Map<String, dynamic> delta) {
    // Rough estimation: JSON overhead + key/value sizes
    int size = 10; // Base JSON object overhead

    for (final entry in delta.entries) {
      size += entry.key.length + 5; // Key + quotes + colon + comma
      size += _estimateValueSize(entry.value);
    }

    return size;
  }

  /// Estimates the size of a JSON value in bytes.
  int _estimateValueSize(dynamic value) {
    if (value == null) return 4; // "null"
    if (value is bool) return value ? 4 : 5; // "true" or "false"
    if (value is int) return value.toString().length;
    if (value is double) return value.toString().length;
    if (value is String) return value.length + 2; // String + quotes
    if (value is List) {
      int size = 2; // [ ]
      for (final item in value) {
        size += _estimateValueSize(item) + 1; // Item + comma
      }
      return size;
    }
    if (value is Map) {
      int size = 2; // { }
      for (final entry in value.entries) {
        size += entry.key.toString().length + 3; // Key + quotes + colon
        size += _estimateValueSize(entry.value) + 1; // Value + comma
      }
      return size;
    }
    return 10; // Default estimate for unknown types
  }

  /// Clears the cached state for a room.
  ///
  /// Should be called when a room is reset or deleted to prevent
  /// memory leaks and stale state comparisons.
  void clearRoomState(String roomId) {
    _lastKnownStates.remove(roomId);
  }

  /// Clears all cached states.
  ///
  /// Should be called when the service is being disposed.
  void clearAllStates() {
    _lastKnownStates.clear();
  }

  /// Gets statistics about cached states.
  ///
  /// Returns information about memory usage and cached room count.
  Map<String, dynamic> getStats() {
    return {
      'cachedRooms': _lastKnownStates.length,
      'roomIds': _lastKnownStates.keys.toList(),
    };
  }
}
