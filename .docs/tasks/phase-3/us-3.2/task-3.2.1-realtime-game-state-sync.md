# Task 3.2.1: Real-time Game State Synchronization

## Overview
- User Story: us-3.2-realtime-sync
- Task ID: task-3.2.1-realtime-game-state-sync
- Priority: Critical
- Effort: 16 hours
- Dependencies: task-3.1.2-room-joining-player-management

## Description
Implement real-time synchronization of game state across all players using Firebase Realtime Database. Ensure all game events (movements, food consumption, deaths) are immediately synchronized with minimal latency.

## Technical Requirements
### Components
- Game State Sync: Real-time game state updates
- Event Broadcasting: Multiplayer event propagation
- Conflict Resolution: Handle simultaneous events
- Network Optimization: Minimize bandwidth usage

### Tech Stack
- Firebase Realtime Database: Real-time data sync
- Stream Controllers: Event broadcasting
- Delta Updates: Efficient data synchronization
- Custom Serialization: Optimized data transfer

## Implementation Steps
### Step 1: Design Synchronization Architecture
- Action: Plan real-time sync strategy and data flow
- Deliverable: Synchronization architecture document
- Acceptance: Architecture supports all multiplayer scenarios
- Files: Synchronization design documentation

### Step 2: Implement Game State Synchronization Service
- Action: Create service for real-time game state sync
- Deliverable: Working synchronization service
- Acceptance: Game state changes propagate to all clients
- Files: `lib/features/game/services/game_sync_service.dart`

### Step 3: Build Event Broadcasting System
- Action: Implement system for broadcasting game events
- Deliverable: Event broadcasting functionality
- Acceptance: All game events reach all players instantly
- Files: `lib/features/game/services/event_broadcaster.dart`

### Step 4: Optimize Network Performance
- Action: Implement delta updates and bandwidth optimization
- Deliverable: Optimized network communication
- Acceptance: Sync latency under 200ms with minimal bandwidth
- Files: Network optimization utilities

## Technical Specs
### Game Synchronization Service
```dart
class GameSyncService {
  final DatabaseService _databaseService;
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, GameEventController> _eventControllers = {};
  
  GameSyncService(this._databaseService);
  
  Stream<GameState> watchGameState(String roomId) {
    return _databaseService.watchGameState(roomId)
        .where((state) => state != null)
        .cast<GameState>();
  }
  
  Future<void> syncPlayerMove(
    String roomId,
    String playerId,
    Direction direction,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    await _databaseService.updateGameState(roomId, {
      'snakes/$playerId/direction': direction.name,
      'snakes/$playerId/lastUpdate': timestamp,
    });
  }
  
  Future<void> syncFoodConsumption(
    String roomId,
    String playerId,
    Position foodPosition,
    Position newFoodPosition,
  ) async {
    final batch = <String, dynamic>{
      'food': newFoodPosition.toJson(),
      'snakes/$playerId/score': FieldValue.increment(1),
      'snakes/$playerId/length': FieldValue.increment(1),
    };
    
    await _databaseService.batchUpdate(roomId, batch);
  }
  
  Future<void> syncPlayerDeath(
    String roomId,
    String playerId,
  ) async {
    await _databaseService.updateGameState(roomId, {
      'snakes/$playerId/alive': false,
      'snakes/$playerId/deathTime': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

### Event Broadcasting System
```dart
class GameEventBroadcaster {
  final Map<String, StreamController<GameEvent>> _controllers = {};
  
  Stream<GameEvent> getEventStream(String roomId) {
    _controllers[roomId] ??= StreamController<GameEvent>.broadcast();
    return _controllers[roomId]!.stream;
  }
  
  void broadcastEvent(String roomId, GameEvent event) {
    final controller = _controllers[roomId];
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }
  
  void dispose(String roomId) {
    final controller = _controllers[roomId];
    if (controller != null) {
      controller.close();
      _controllers.remove(roomId);
    }
  }
}

abstract class GameEvent {
  final String playerId;
  final int timestamp;
  
  const GameEvent({
    required this.playerId,
    required this.timestamp,
  });
}

class PlayerMoveEvent extends GameEvent {
  final Direction direction;
  final Position newHeadPosition;
  
  const PlayerMoveEvent({
    required super.playerId,
    required super.timestamp,
    required this.direction,
    required this.newHeadPosition,
  });
}

class FoodConsumedEvent extends GameEvent {
  final Position foodPosition;
  final Position newFoodPosition;
  
  const FoodConsumedEvent({
    required super.playerId,
    required super.timestamp,
    required this.foodPosition,
    required this.newFoodPosition,
  });
}
```

### Delta Update System
```dart
class DeltaUpdateService {
  final Map<String, GameState> _lastKnownStates = {};
  
  Map<String, dynamic> calculateDelta(String roomId, GameState newState) {
    final lastState = _lastKnownStates[roomId];
    if (lastState == null) {
      _lastKnownStates[roomId] = newState;
      return newState.toJson();
    }
    
    final delta = <String, dynamic>{};
    
    // Compare and add only changed snake data
    for (final entry in newState.snakes.entries) {
      final playerId = entry.key;
      final newSnake = entry.value;
      final oldSnake = lastState.snakes[playerId];
      
      if (oldSnake == null || !_snakesEqual(oldSnake, newSnake)) {
        delta['snakes/$playerId'] = newSnake.toJson();
      }
    }
    
    // Compare food position
    if (lastState.food != newState.food) {
      delta['food'] = newState.food.toJson();
    }
    
    // Compare winner
    if (lastState.winner != newState.winner) {
      delta['winner'] = newState.winner;
    }
    
    _lastKnownStates[roomId] = newState;
    return delta;
  }
  
  bool _snakesEqual(Snake snake1, Snake snake2) {
    return snake1.direction == snake2.direction &&
           snake1.alive == snake2.alive &&
           snake1.score == snake2.score &&
           _positionsEqual(snake1.positions, snake2.positions);
  }
  
  bool _positionsEqual(List<Position> pos1, List<Position> pos2) {
    if (pos1.length != pos2.length) return false;
    for (int i = 0; i < pos1.length; i++) {
      if (pos1[i] != pos2[i]) return false;
    }
    return true;
  }
}
```

## Testing
- [ ] Unit tests for synchronization service methods
- [ ] Integration tests for real-time sync across multiple clients
- [ ] Performance tests for sync latency under various network conditions

## Acceptance Criteria
- [ ] Game state changes synchronized across all clients
- [ ] Sync latency consistently under 200ms
- [ ] Event broadcasting reaches all players instantly
- [ ] Delta updates minimize bandwidth usage
- [ ] Conflict resolution handles simultaneous events
- [ ] Network interruption recovery working

## Dependencies
- Before: Room management system complete
- After: Multiplayer game loop can use synchronized state
- External: Firebase Realtime Database for real-time sync

## Risks
- Risk: Network latency affecting gameplay fairness
- Mitigation: Implement client-side prediction and lag compensation

## Definition of Done
- [ ] Real-time synchronization implemented and tested
- [ ] Event broadcasting system functional
- [ ] Performance requirements met
- [ ] Delta updates optimizing bandwidth
- [ ] Cross-platform sync verified
- [ ] Documentation complete
