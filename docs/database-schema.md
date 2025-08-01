# Database Schema Documentation

## Overview
This document describes the complete database schema for the Snakes Fight multiplayer game, implemented using Firebase Realtime Database with type-safe Dart data models.

## Database Structure

### Root Level Structure
```
/rooms
  /{roomId}
    - Room data and nested collections
/users
  /{userId}
    - User profile and statistics
```

## Data Models

### Room Model
**Path**: `/rooms/{roomId}`

**Structure**:
```json
{
  "id": "string",
  "roomCode": "string (6 chars, A-Z0-9)",
  "hostId": "string (user ID)",
  "status": "waiting|active|ended",
  "createdAt": "ISO timestamp",
  "maxPlayers": "number (default: 4)",
  "players": {
    "{playerId}": {
      "uid": "string",
      "displayName": "string",
      "color": "red|blue|green|yellow",
      "joinedAt": "ISO timestamp",
      "isReady": "boolean (default: false)",
      "isConnected": "boolean (default: true)"
    }
  },
  "gameState": {
    "startedAt": "ISO timestamp",
    "food": {
      "position": {
        "x": "number",
        "y": "number"
      },
      "value": "number (default: 1)"
    },
    "snakes": {
      "{playerId}": {
        "positions": [
          {
            "x": "number",
            "y": "number"
          }
        ],
        "direction": "up|down|left|right",
        "alive": "boolean (default: true)",
        "score": "number (default: 0)"
      }
    },
    "winner": "string (player ID) | null",
    "endedAt": "ISO timestamp | null"
  }
}
```

**Constraints**:
- `roomCode`: Must be exactly 6 characters, uppercase letters and numbers only
- `maxPlayers`: Between 2 and 4
- `players`: Map size cannot exceed `maxPlayers`
- `color`: Each player must have a unique color within the room
- `gameState`: Only present when `status` is "active" or "ended"

### User Model
**Path**: `/users/{userId}`

**Structure**:
```json
{
  "uid": "string",
  "displayName": "string",
  "isAnonymous": "boolean (default: false)",
  "stats": {
    "gamesPlayed": "number (default: 0)",
    "gamesWon": "number (default: 0)",
    "lastActive": "ISO timestamp"
  }
}
```

**Constraints**:
- `displayName`: 1-20 characters, alphanumeric, spaces, hyphens, underscores only
- `gamesWon`: Cannot exceed `gamesPlayed`
- `lastActive`: Updated on every user interaction

## Model Relationships

### Room → Players
- **Type**: One-to-Many (embedded)
- **Relationship**: A room contains multiple players
- **Constraint**: Number of players ≤ `maxPlayers`
- **Cascading**: Players are deleted when room is deleted

### Room → GameState
- **Type**: One-to-One (embedded)
- **Relationship**: A room can have one active game state
- **Constraint**: Only present during active games
- **Lifecycle**: Created when game starts, updated during play, preserved when ended

### GameState → Snakes
- **Type**: One-to-Many (embedded)
- **Relationship**: Game state contains one snake per player
- **Constraint**: Snake keys must match player IDs in room
- **Updates**: Real-time during game play

### GameState → Food
- **Type**: One-to-One (embedded)
- **Relationship**: Game state contains one food item
- **Updates**: Repositioned when consumed

### User → Room (implicit)
- **Type**: Many-to-Many (by reference)
- **Relationship**: Users can join multiple rooms over time
- **Reference**: `Player.uid` references `User.uid`
- **No foreign key**: Referential integrity maintained by application logic

## Validation Rules

### Room Validation
```dart
bool isValidRoom(Room room) {
  return room.players.length <= room.maxPlayers &&
         room.players.values.map((p) => p.color).toSet().length == room.players.length &&
         ModelUtils.isValidRoomCode(room.roomCode) &&
         (room.gameState == null || room.status != RoomStatus.waiting);
}
```

### Player Validation
```dart
bool isValidPlayer(Player player) {
  return ModelUtils.isValidDisplayName(player.displayName) &&
         player.joinedAt.isBefore(DateTime.now().add(Duration(minutes: 1)));
}
```

### Game State Validation
```dart
bool isValidGameState(GameState gameState) {
  return gameState.snakes.isNotEmpty &&
         gameState.food.position.x >= 0 &&
         gameState.food.position.y >= 0 &&
         (gameState.endedAt == null || gameState.endedAt!.isAfter(gameState.startedAt));
}
```

## Query Patterns

### Common Queries

1. **Find Room by Code**:
   ```dart
   // Query: /rooms orderBy "roomCode" equalTo "ABCD12"
   final room = await database.ref('rooms')
     .orderByChild('roomCode')
     .equalTo(roomCode)
     .once();
   ```

2. **Get User's Active Rooms**:
   ```dart
   // Query: /rooms orderBy "players/{userId}/isConnected" equalTo true
   final activeRooms = await database.ref('rooms')
     .orderByChild('players/$userId/isConnected')
     .equalTo(true)
     .once();
   ```

3. **Get Waiting Rooms**:
   ```dart
   // Query: /rooms orderBy "status" equalTo "waiting"
   final waitingRooms = await database.ref('rooms')
     .orderByChild('status')
     .equalTo('waiting')
     .once();
   ```

### Real-time Subscriptions

1. **Room Updates**:
   ```dart
   database.ref('rooms/$roomId').onValue.listen((event) {
     final room = Room.fromJson(event.snapshot.value);
     // Handle room updates
   });
   ```

2. **Game State Updates**:
   ```dart
   database.ref('rooms/$roomId/gameState').onValue.listen((event) {
     final gameState = GameState.fromJson(event.snapshot.value);
     // Handle game updates
   });
   ```

3. **Player Connection Status**:
   ```dart
   database.ref('rooms/$roomId/players/$playerId/isConnected')
     .onValue.listen((event) {
     final isConnected = event.snapshot.value as bool;
     // Handle connection changes
   });
   ```

## Security Rules

### Firebase Realtime Database Rules
```json
{
  "rules": {
    "rooms": {
      "$roomId": {
        ".read": "auth != null && data.child('players').child(auth.uid).exists()",
        ".write": "auth != null && (
          !data.exists() || 
          data.child('hostId').val() == auth.uid ||
          data.child('players').child(auth.uid).exists()
        )",
        "players": {
          "$playerId": {
            ".write": "auth != null && auth.uid == $playerId"
          }
        },
        "gameState": {
          ".write": "auth != null && root.child('rooms').child($roomId).child('hostId').val() == auth.uid"
        }
      }
    },
    "users": {
      "$userId": {
        ".read": "auth != null && auth.uid == $userId",
        ".write": "auth != null && auth.uid == $userId"
      }
    }
  }
}
```

## Performance Considerations

### Indexing
```json
{
  "rules": {
    "rooms": {
      ".indexOn": ["roomCode", "status", "createdAt"]
    },
    "users": {
      ".indexOn": ["stats/lastActive"]
    }
  }
}
```

### Data Size Limits
- Maximum room data size: ~1MB (Firebase limit)
- Recommended max players per room: 4
- Maximum snake length: Limited by grid size
- Game history: Not stored in real-time database (use Firestore for historical data)

### Real-time Updates
- Game state updates: 30-60 FPS during active gameplay
- Player status updates: Real-time on connection changes
- Room list updates: Real-time for lobby management

## Data Lifecycle

### Room Lifecycle
1. **Creation**: Room created with `waiting` status
2. **Player Join**: Players added to `players` map
3. **Game Start**: `gameState` created, status → `active`
4. **Game Play**: Real-time `gameState` updates
5. **Game End**: `winner` set, `endedAt` timestamp, status → `ended`
6. **Cleanup**: Room deleted after 24 hours (automated cleanup)

### User Lifecycle
1. **Registration**: User created on first authentication
2. **Game Participation**: Stats updated after each game
3. **Inactivity**: User marked inactive after 30 days
4. **Data Retention**: User data retained indefinitely

## Migration Strategy

### Schema Versioning
- Current version: 1.0
- Backward compatibility maintained for minor updates
- Migration scripts for major schema changes

### Data Migration
```dart
Future<void> migrateUserData() async {
  // Example migration for adding new user fields
  final users = await database.ref('users').once();
  for (final child in users.snapshot.children) {
    final userData = child.value as Map<String, dynamic>;
    if (!userData.containsKey('stats')) {
      await child.ref.update({
        'stats': UserStats.newUser().toJson(),
      });
    }
  }
}
```

## Error Handling

### Common Error Scenarios
1. **Room Not Found**: Handle gracefully with user message
2. **Room Full**: Prevent join, show error
3. **Player Disconnect**: Update connection status, pause game if needed
4. **Network Issues**: Retry with exponential backoff
5. **Data Corruption**: Validate data integrity, fallback to defaults

### Error Recovery
```dart
Future<Room?> safeGetRoom(String roomId) async {
  try {
    final snapshot = await database.ref('rooms/$roomId').once();
    if (snapshot.snapshot.value == null) return null;
    return Room.fromJson(snapshot.snapshot.value as Map<String, dynamic>);
  } catch (e) {
    logger.error('Failed to get room $roomId: $e');
    return null;
  }
}
```

## Monitoring and Metrics

### Key Metrics
- Room creation rate
- Player join/leave events
- Game completion rate
- Average game duration
- Error rates by operation type

### Alerting
- High error rates
- Database connection issues
- Unusual data patterns
- Performance degradation

This schema provides a robust foundation for the multiplayer Snake game with proper data modeling, validation, and real-time capabilities.
