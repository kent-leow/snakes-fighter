# Task 3.3.1: Multiplayer Game Logic Implementation

## Overview
- User Story: us-3.3-multiplayer-game-loop
- Task ID: task-3.3.1-multiplayer-game-logic
- Priority: Critical
- Effort: 16 hours
- Dependencies: task-3.2.1-realtime-game-state-sync

## Description
Implement multiplayer game logic including game initialization, turn management, collision detection for multiple players, and win condition evaluation. Adapt single-player game engine for multiplayer scenarios.

## Technical Requirements
### Components
- Multiplayer Game Engine: Multi-player game logic
- Collision System: Multi-snake collision detection
- Win Condition Handler: Last survivor determination
- Game State Manager: Centralized game state management

### Tech Stack
- Custom Game Engine: Multiplayer game mechanics
- Firebase Cloud Functions: Server-side validation
- Stream Management: Real-time game updates
- State Machines: Game flow management

## Implementation Steps
### Step 1: Adapt Game Engine for Multiplayer
- Action: Modify single-player game engine for multiple snakes
- Deliverable: Multiplayer-capable game engine
- Acceptance: Engine handles 2-4 snakes simultaneously
- Files: `lib/features/game/engine/multiplayer_game_engine.dart`

### Step 2: Implement Multi-Snake Collision Detection
- Action: Create collision detection for multiple snakes
- Deliverable: Comprehensive collision system
- Acceptance: All collision scenarios handled correctly
- Files: `lib/features/game/engine/multiplayer_collision_detector.dart`

### Step 3: Build Win Condition System
- Action: Implement last-survivor win condition logic
- Deliverable: Win condition evaluation system
- Acceptance: Correct winner determined in all scenarios
- Files: `lib/features/game/engine/win_condition_handler.dart`

### Step 4: Create Game Flow Manager
- Action: Implement overall game flow and state management
- Deliverable: Complete game flow management
- Acceptance: Game transitions through states correctly
- Files: `lib/features/game/managers/game_flow_manager.dart`

## Technical Specs
### Multiplayer Game Engine
```dart
class MultiplayerGameEngine {
  final Map<String, Snake> _snakes = {};
  final GameBoard _board;
  final MultiplayerCollisionDetector _collisionDetector;
  final WinConditionHandler _winConditionHandler;
  final GameSyncService _syncService;
  
  MultiplayerGameEngine({
    required GameBoard board,
    required GameSyncService syncService,
  }) : _board = board,
       _syncService = syncService,
       _collisionDetector = MultiplayerCollisionDetector(board),
       _winConditionHandler = WinConditionHandler();
  
  void initializeGame(Map<String, Player> players) {
    _snakes.clear();
    
    final startPositions = _generateStartPositions(players.length);
    int positionIndex = 0;
    
    for (final player in players.values) {
      final snake = Snake(
        positions: [startPositions[positionIndex]],
        direction: Direction.right,
        alive: true,
        score: 0,
      );
      
      _snakes[player.uid] = snake;
      positionIndex++;
    }
  }
  
  Future<GameUpdateResult> updateGame(String roomId) async {
    final alivePlayers = _snakes.entries
        .where((entry) => entry.value.alive)
        .toList();
    
    if (alivePlayers.length <= 1) {
      final winner = alivePlayers.isNotEmpty ? alivePlayers.first.key : null;
      return GameUpdateResult(
        gameEnded: true,
        winner: winner,
        snakes: Map.from(_snakes),
      );
    }
    
    // Move all alive snakes
    final moveResults = <String, SnakeMoveResult>{};
    for (final entry in alivePlayers) {
      final playerId = entry.key;
      final snake = entry.value;
      
      final moveResult = _moveSnake(playerId, snake);
      moveResults[playerId] = moveResult;
    }
    
    // Check collisions
    final collisionResults = _collisionDetector.checkAllCollisions(
      _snakes,
      moveResults,
    );
    
    // Apply collision results
    for (final result in collisionResults) {
      if (result.isDead) {
        _snakes[result.playerId] = _snakes[result.playerId]!
            .copyWith(alive: false);
      }
    }
    
    // Sync state
    await _syncGameState(roomId);
    
    return GameUpdateResult(
      gameEnded: false,
      snakes: Map.from(_snakes),
      collisions: collisionResults,
    );
  }
  
  List<Position> _generateStartPositions(int playerCount) {
    final positions = <Position>[];
    final boardCenter = Position(
      x: _board.width ~/ 2,
      y: _board.height ~/ 2,
    );
    
    switch (playerCount) {
      case 2:
        positions.addAll([
          Position(x: boardCenter.x - 5, y: boardCenter.y),
          Position(x: boardCenter.x + 5, y: boardCenter.y),
        ]);
        break;
      case 3:
        positions.addAll([
          Position(x: boardCenter.x, y: boardCenter.y - 5),
          Position(x: boardCenter.x - 5, y: boardCenter.y + 3),
          Position(x: boardCenter.x + 5, y: boardCenter.y + 3),
        ]);
        break;
      case 4:
        positions.addAll([
          Position(x: boardCenter.x - 5, y: boardCenter.y - 5),
          Position(x: boardCenter.x + 5, y: boardCenter.y - 5),
          Position(x: boardCenter.x - 5, y: boardCenter.y + 5),
          Position(x: boardCenter.x + 5, y: boardCenter.y + 5),
        ]);
        break;
    }
    
    return positions;
  }
}
```

### Multiplayer Collision Detector
```dart
class MultiplayerCollisionDetector {
  final GameBoard _board;
  
  MultiplayerCollisionDetector(this._board);
  
  List<CollisionResult> checkAllCollisions(
    Map<String, Snake> snakes,
    Map<String, SnakeMoveResult> moveResults,
  ) {
    final results = <CollisionResult>[];
    
    for (final entry in moveResults.entries) {
      final playerId = entry.key;
      final moveResult = entry.value;
      final snake = snakes[playerId]!;
      
      if (!snake.alive) continue;
      
      final newHeadPosition = moveResult.newHeadPosition;
      
      // Check wall collision
      if (_isWallCollision(newHeadPosition)) {
        results.add(CollisionResult(
          playerId: playerId,
          collisionType: CollisionType.wall,
          isDead: true,
        ));
        continue;
      }
      
      // Check self collision
      if (_isSelfCollision(snake, newHeadPosition)) {
        results.add(CollisionResult(
          playerId: playerId,
          collisionType: CollisionType.self,
          isDead: true,
        ));
        continue;
      }
      
      // Check collision with other snakes
      final otherSnakeCollision = _checkOtherSnakeCollisions(
        playerId,
        newHeadPosition,
        snakes,
        moveResults,
      );
      
      if (otherSnakeCollision != null) {
        results.add(otherSnakeCollision);
      }
    }
    
    return results;
  }
  
  CollisionResult? _checkOtherSnakeCollisions(
    String playerId,
    Position newHeadPosition,
    Map<String, Snake> snakes,
    Map<String, SnakeMoveResult> moveResults,
  ) {
    for (final entry in snakes.entries) {
      final otherPlayerId = entry.key;
      final otherSnake = entry.value;
      
      if (otherPlayerId == playerId || !otherSnake.alive) continue;
      
      // Check collision with other snake's body
      for (int i = 0; i < otherSnake.positions.length; i++) {
        if (otherSnake.positions[i] == newHeadPosition) {
          return CollisionResult(
            playerId: playerId,
            collisionType: CollisionType.otherSnake,
            otherPlayerId: otherPlayerId,
            isDead: true,
          );
        }
      }
      
      // Check head-to-head collision
      final otherMoveResult = moveResults[otherPlayerId];
      if (otherMoveResult != null &&
          otherMoveResult.newHeadPosition == newHeadPosition) {
        return CollisionResult(
          playerId: playerId,
          collisionType: CollisionType.headToHead,
          otherPlayerId: otherPlayerId,
          isDead: true,
        );
      }
    }
    
    return null;
  }
}
```

### Win Condition Handler
```dart
class WinConditionHandler {
  GameEndResult evaluateGameEnd(Map<String, Snake> snakes) {
    final aliveSnakes = snakes.entries
        .where((entry) => entry.value.alive)
        .toList();
    
    if (aliveSnakes.isEmpty) {
      return GameEndResult(
        isGameEnded: true,
        winner: null,
        endReason: GameEndReason.allPlayersDead,
      );
    }
    
    if (aliveSnakes.length == 1) {
      return GameEndResult(
        isGameEnded: true,
        winner: aliveSnakes.first.key,
        endReason: GameEndReason.lastSurvivor,
        finalScores: _calculateFinalScores(snakes),
      );
    }
    
    return GameEndResult(isGameEnded: false);
  }
  
  Map<String, int> _calculateFinalScores(Map<String, Snake> snakes) {
    return snakes.map((playerId, snake) => 
        MapEntry(playerId, snake.score));
  }
}

class GameEndResult {
  final bool isGameEnded;
  final String? winner;
  final GameEndReason? endReason;
  final Map<String, int>? finalScores;
  
  const GameEndResult({
    required this.isGameEnded,
    this.winner,
    this.endReason,
    this.finalScores,
  });
}

enum GameEndReason {
  lastSurvivor,
  allPlayersDead,
  timeout,
}
```

## Testing
- [ ] Unit tests for multiplayer game engine logic
- [ ] Integration tests for multi-player collision scenarios
- [ ] End-to-end tests for complete multiplayer games

## Acceptance Criteria
- [ ] Game engine handles 2-4 players simultaneously
- [ ] Collision detection works for all multi-player scenarios
- [ ] Win conditions correctly determine last survivor
- [ ] Game state properly synchronized across clients
- [ ] All edge cases handled (simultaneous deaths, etc.)
- [ ] Performance maintained with multiple players

## Dependencies
- Before: Real-time synchronization system complete
- After: Complete multiplayer game functionality ready
- External: Server-side validation for game logic

## Risks
- Risk: Race conditions in multiplayer collision detection
- Mitigation: Use deterministic collision resolution order

## Definition of Done
- [ ] Multiplayer game engine implemented
- [ ] Collision detection working for all scenarios
- [ ] Win condition system functional
- [ ] Game flow management complete
- [ ] Cross-platform multiplayer tested
- [ ] Performance benchmarks met
