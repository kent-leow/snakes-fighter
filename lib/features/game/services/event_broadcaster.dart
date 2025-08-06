import 'dart:async';

import '../../../core/models/models.dart';

/// Abstract base class for all game events.
///
/// Contains common properties shared by all game events including
/// player ID and timestamp for ordering events.
abstract class GameEvent {
  /// Creates a new game event.
  const GameEvent({required this.playerId, required this.timestamp});

  /// The ID of the player who triggered this event.
  final String playerId;

  /// Timestamp when the event occurred (milliseconds since epoch).
  final int timestamp;

  /// Converts the event to JSON format for serialization.
  Map<String, dynamic> toJson();

  /// Creates an event from JSON data.
  static GameEvent fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'playerMove':
        return PlayerMoveEvent.fromJson(json);
      case 'foodConsumed':
        return FoodConsumedEvent.fromJson(json);
      case 'playerDeath':
        return PlayerDeathEvent.fromJson(json);
      case 'gameStart':
        return GameStartEvent.fromJson(json);
      case 'gameEnd':
        return GameEndEvent.fromJson(json);
      default:
        throw ArgumentError('Unknown event type: $type');
    }
  }
}

/// Event triggered when a player moves their snake.
class PlayerMoveEvent extends GameEvent {
  /// Creates a new player move event.
  const PlayerMoveEvent({
    required super.playerId,
    required super.timestamp,
    required this.direction,
    required this.newHeadPosition,
  });

  /// The new direction the snake is moving.
  final Direction direction;

  /// The new head position after the move.
  final Position newHeadPosition;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'playerMove',
    'playerId': playerId,
    'timestamp': timestamp,
    'direction': direction.name,
    'newHeadPosition': newHeadPosition.toJson(),
  };

  /// Creates a PlayerMoveEvent from JSON data.
  factory PlayerMoveEvent.fromJson(Map<String, dynamic> json) {
    return PlayerMoveEvent(
      playerId: json['playerId'] as String,
      timestamp: json['timestamp'] as int,
      direction: Direction.values.byName(json['direction'] as String),
      newHeadPosition: Position.fromJson(
        json['newHeadPosition'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Event triggered when a player's snake consumes food.
class FoodConsumedEvent extends GameEvent {
  /// Creates a new food consumed event.
  const FoodConsumedEvent({
    required super.playerId,
    required super.timestamp,
    required this.foodPosition,
    required this.newFoodPosition,
    required this.newScore,
  });

  /// The position where food was consumed.
  final Position foodPosition;

  /// The new position where food spawned.
  final Position newFoodPosition;

  /// The player's new score after consuming food.
  final int newScore;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'foodConsumed',
    'playerId': playerId,
    'timestamp': timestamp,
    'foodPosition': foodPosition.toJson(),
    'newFoodPosition': newFoodPosition.toJson(),
    'newScore': newScore,
  };

  /// Creates a FoodConsumedEvent from JSON data.
  factory FoodConsumedEvent.fromJson(Map<String, dynamic> json) {
    return FoodConsumedEvent(
      playerId: json['playerId'] as String,
      timestamp: json['timestamp'] as int,
      foodPosition: Position.fromJson(
        json['foodPosition'] as Map<String, dynamic>,
      ),
      newFoodPosition: Position.fromJson(
        json['newFoodPosition'] as Map<String, dynamic>,
      ),
      newScore: json['newScore'] as int,
    );
  }
}

/// Event triggered when a player's snake dies.
class PlayerDeathEvent extends GameEvent {
  /// Creates a new player death event.
  const PlayerDeathEvent({
    required super.playerId,
    required super.timestamp,
    required this.cause,
    required this.finalScore,
  });

  /// The cause of death (collision, wall, etc.).
  final String cause;

  /// The player's final score.
  final int finalScore;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'playerDeath',
    'playerId': playerId,
    'timestamp': timestamp,
    'cause': cause,
    'finalScore': finalScore,
  };

  /// Creates a PlayerDeathEvent from JSON data.
  factory PlayerDeathEvent.fromJson(Map<String, dynamic> json) {
    return PlayerDeathEvent(
      playerId: json['playerId'] as String,
      timestamp: json['timestamp'] as int,
      cause: json['cause'] as String,
      finalScore: json['finalScore'] as int,
    );
  }
}

/// Event triggered when a game starts.
class GameStartEvent extends GameEvent {
  /// Creates a new game start event.
  const GameStartEvent({
    required super.playerId,
    required super.timestamp,
    required this.roomId,
  });

  /// The ID of the room where the game started.
  final String roomId;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'gameStart',
    'playerId': playerId,
    'timestamp': timestamp,
    'roomId': roomId,
  };

  /// Creates a GameStartEvent from JSON data.
  factory GameStartEvent.fromJson(Map<String, dynamic> json) {
    return GameStartEvent(
      playerId: json['playerId'] as String,
      timestamp: json['timestamp'] as int,
      roomId: json['roomId'] as String,
    );
  }
}

/// Event triggered when a game ends.
class GameEndEvent extends GameEvent {
  /// Creates a new game end event.
  const GameEndEvent({
    required super.playerId,
    required super.timestamp,
    required this.roomId,
    this.winnerId,
  });

  /// The ID of the room where the game ended.
  final String roomId;

  /// The ID of the winning player (null for draw).
  final String? winnerId;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'gameEnd',
    'playerId': playerId,
    'timestamp': timestamp,
    'roomId': roomId,
    'winnerId': winnerId,
  };

  /// Creates a GameEndEvent from JSON data.
  factory GameEndEvent.fromJson(Map<String, dynamic> json) {
    return GameEndEvent(
      playerId: json['playerId'] as String,
      timestamp: json['timestamp'] as int,
      roomId: json['roomId'] as String,
      winnerId: json['winnerId'] as String?,
    );
  }
}

/// Service for broadcasting game events to all players in a room.
///
/// Manages event streams for each room and provides methods to broadcast
/// events to all listening clients. Events are delivered instantly to
/// provide real-time multiplayer experience.
class GameEventBroadcaster {
  /// Creates a new game event broadcaster.
  GameEventBroadcaster();

  final Map<String, StreamController<GameEvent>> _controllers = {};

  /// Gets the event stream for a room.
  ///
  /// Creates a new broadcast stream controller if one doesn't exist
  /// for the specified room. Multiple listeners can subscribe to the
  /// same stream.
  ///
  /// Note: StreamController is intentionally not closed here as it's
  /// managed by dispose() and disposeAll() methods.
  Stream<GameEvent> getEventStream(String roomId) {
    // ignore: close_sinks
    _controllers[roomId] ??= StreamController<GameEvent>.broadcast();
    return _controllers[roomId]!.stream;
  }

  /// Broadcasts an event to all listeners in a room.
  ///
  /// Sends the event to all clients currently listening to the
  /// event stream for the specified room. Events are delivered
  /// immediately without buffering.
  void broadcastEvent(String roomId, GameEvent event) {
    final controller = _controllers[roomId];
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  /// Broadcasts multiple events to all listeners in a room.
  ///
  /// Efficient method for sending multiple events at once.
  /// Events are sent in the order provided.
  void broadcastEvents(String roomId, List<GameEvent> events) {
    final controller = _controllers[roomId];
    if (controller != null && !controller.isClosed) {
      for (final event in events) {
        controller.add(event);
      }
    }
  }

  /// Filters events by type for a room.
  ///
  /// Returns a stream that only emits events of the specified type.
  /// Useful for listening to specific game events like player moves
  /// or food consumption.
  Stream<T> getFilteredEventStream<T extends GameEvent>(String roomId) {
    return getEventStream(roomId).where((event) => event is T).cast<T>();
  }

  /// Checks if a room has active listeners.
  ///
  /// Returns true if there are active subscriptions to the room's
  /// event stream. Useful for optimization to avoid broadcasting
  /// events when no one is listening.
  bool hasActiveListeners(String roomId) {
    final controller = _controllers[roomId];
    return controller != null && !controller.isClosed && controller.hasListener;
  }

  /// Gets the number of active listeners for a room.
  ///
  /// Returns the count of active subscriptions to the room's event stream.
  int getListenerCount(String roomId) {
    final controller = _controllers[roomId];
    if (controller == null || controller.isClosed) {
      return 0;
    }

    // StreamController doesn't expose listener count directly,
    // so we return 1 if there are listeners, 0 otherwise
    return controller.hasListener ? 1 : 0;
  }

  /// Disposes of the event stream for a room.
  ///
  /// Closes the stream controller and removes it from the internal
  /// map. Should be called when a room is no longer active to
  /// prevent memory leaks.
  void dispose(String roomId) {
    final controller = _controllers[roomId];
    if (controller != null) {
      controller.close();
      _controllers.remove(roomId);
    }
  }

  /// Disposes of all event streams.
  ///
  /// Closes all active stream controllers and clears the internal
  /// map. Should be called when the broadcaster is no longer needed.
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
