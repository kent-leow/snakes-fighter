# Task 2.3.1: Data Models Design and Implementation

## Overview
- User Story: us-2.3-database-schema
- Task ID: task-2.3.1-data-models-design
- Priority: High
- Effort: 8 hours
- Dependencies: task-2.1.1-firebase-project-setup

## Description
Design and implement comprehensive data models for rooms, players, game state, and user information. Create type-safe models with proper serialization/deserialization for Firebase Realtime Database integration.

## Technical Requirements
### Components
- Data Models: Type-safe Dart classes
- Serialization: JSON conversion methods
- Validation: Input validation and constraints
- Documentation: Model relationships and usage

### Tech Stack
- Dart: Data class implementation
- json_annotation: Serialization support
- build_runner: Code generation
- freezed: Immutable data classes

## Implementation Steps
### Step 1: Design Database Schema Structure
- Action: Define database schema with clear relationships
- Deliverable: Complete database schema documentation
- Acceptance: Schema supports all game functionality requirements
- Files: Database schema design document

### Step 2: Implement Core Data Models
- Action: Create Room, Player, GameState, and User models
- Deliverable: Complete set of data models with serialization
- Acceptance: Models compile and serialize correctly
- Files: `lib/core/models/` directory with all model files

### Step 3: Add Model Validation
- Action: Implement validation logic for all data models
- Deliverable: Validated data models with constraint checking
- Acceptance: Models reject invalid data appropriately
- Files: Validation methods in model classes

### Step 4: Create Model Utilities
- Action: Build helper utilities for model operations
- Deliverable: Utility functions for common model operations
- Acceptance: Utilities simplify model usage throughout app
- Files: `lib/core/utils/model_utils.dart`

## Technical Specs
### Database Schema Structure
```
/rooms
  /{roomId}
    /metadata
      - roomCode: string
      - hostId: string
      - status: "waiting" | "active" | "ended"
      - createdAt: timestamp
      - maxPlayers: number
    /players
      /{playerId}
        - uid: string
        - displayName: string
        - color: string
        - isReady: boolean
        - joinedAt: timestamp
    /gameState
      - startedAt: timestamp
      - food: {x: number, y: number}
      - snakes
        /{playerId}
          - positions: [{x: number, y: number}]
          - direction: "up" | "down" | "left" | "right"
          - alive: boolean
          - score: number
      - winner: string | null
      - endedAt: timestamp | null

/users
  /{userId}
    - displayName: string
    - isAnonymous: boolean
    - stats
      - gamesPlayed: number
      - gamesWon: number
      - lastActive: timestamp
```

### Room Model
```dart
@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String roomCode,
    required String hostId,
    required RoomStatus status,
    required DateTime createdAt,
    @Default(4) int maxPlayers,
    @Default({}) Map<String, Player> players,
    GameState? gameState,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

enum RoomStatus {
  waiting,
  active,
  ended,
}
```

### Player Model
```dart
@freezed
class Player with _$Player {
  const factory Player({
    required String uid,
    required String displayName,
    required PlayerColor color,
    required DateTime joinedAt,
    @Default(false) bool isReady,
    @Default(true) bool isConnected,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

enum PlayerColor {
  red,
  blue,
  green,
  yellow,
}
```

### Game State Model
```dart
@freezed
class GameState with _$GameState {
  const factory GameState({
    required DateTime startedAt,
    required Food food,
    required Map<String, Snake> snakes,
    String? winner,
    DateTime? endedAt,
  }) = _GameState;

  factory GameState.fromJson(Map<String, dynamic> json) => 
      _$GameStateFromJson(json);
}

@freezed
class Snake with _$Snake {
  const factory Snake({
    required List<Position> positions,
    required Direction direction,
    @Default(true) bool alive,
    @Default(0) int score,
  }) = _Snake;

  factory Snake.fromJson(Map<String, dynamic> json) => _$SnakeFromJson(json);
}
```

## Testing
- [ ] Unit tests for data model creation and validation
- [ ] Serialization/deserialization tests for all models
- [ ] Integration tests with Firebase Realtime Database

## Acceptance Criteria
- [ ] All data models implemented with proper typing
- [ ] Models support JSON serialization/deserialization
- [ ] Validation logic prevents invalid data states
- [ ] Model relationships properly defined
- [ ] Utility functions created for common operations
- [ ] Documentation complete for all models

## Dependencies
- Before: Firebase project setup required
- After: Database service can use type-safe models
- External: Code generation tools for serialization

## Risks
- Risk: Model complexity affecting performance
- Mitigation: Keep models lightweight and optimize serialization

## Definition of Done
- [ ] Data models implemented and tested
- [ ] Serialization working correctly
- [ ] Validation logic implemented
- [ ] Model utilities created
- [ ] Documentation complete
- [ ] Code generation setup functional
