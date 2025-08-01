# Task 2.3.3: Database Indexing and Performance Optimization

## Overview
- User Story: us-2.3-database-schema
- Task ID: task-2.3.3-database-indexing-optimization
- Priority: Medium
- Effort: 6 hours
- Dependencies: task-2.3.2-firebase-database-service

## Description
Optimize Firebase Realtime Database performance through proper indexing, query optimization, and data structure refinements. Ensure efficient data retrieval and minimal bandwidth usage for real-time multiplayer functionality.

## Technical Requirements
### Components
- Database Indexing: Firebase database rules with indexing
- Query Optimization: Efficient data retrieval patterns
- Data Structure: Optimized for real-time synchronization
- Bandwidth Optimization: Minimize data transfer

### Tech Stack
- Firebase Database Rules: Indexing configuration
- Query Optimization: Efficient Firebase queries
- Data Denormalization: Optimized data structure
- Compression: Minimal data payloads

## Implementation Steps
### Step 1: Analyze Query Patterns
- Action: Identify frequently accessed data patterns and bottlenecks
- Deliverable: Query analysis and optimization plan
- Acceptance: All query patterns documented with performance requirements
- Files: Database performance analysis document

### Step 2: Configure Database Indexing
- Action: Add indexing rules to Firebase Realtime Database
- Deliverable: Optimized database rules with proper indexing
- Acceptance: Query performance improved with indexing
- Files: Updated `database.rules.json` with indexing

### Step 3: Optimize Data Structure
- Action: Refine data structure for efficient real-time synchronization
- Deliverable: Optimized database schema
- Acceptance: Data transfer minimized while maintaining functionality
- Files: Updated data models and database structure

### Step 4: Implement Caching Strategies
- Action: Add client-side caching for frequently accessed data
- Deliverable: Caching layer for improved performance
- Acceptance: Reduced database calls and improved response times
- Files: `lib/core/services/cache_service.dart`

## Technical Specs
### Database Rules with Indexing
```json
{
  "rules": {
    "rooms": {
      ".indexOn": ["roomCode", "createdAt", "status"],
      "$roomId": {
        ".read": "auth != null && (data.child('players').child(auth.uid).exists() || !data.exists())",
        ".write": "auth != null",
        "players": {
          ".indexOn": ["joinedAt", "isReady"],
          "$playerId": {
            ".write": "auth != null && $playerId == auth.uid"
          }
        },
        "gameState": {
          ".write": "auth != null && data.parent().child('players').child(auth.uid).exists()",
          "snakes": {
            ".indexOn": ["alive", "score"]
          }
        }
      }
    },
    "users": {
      ".indexOn": ["lastActive"],
      "$userId": {
        ".read": "auth != null && $userId == auth.uid",
        ".write": "auth != null && $userId == auth.uid"
      }
    }
  }
}
```

### Optimized Query Patterns
```dart
class OptimizedDatabaseQueries {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Efficient room lookup by code
  Future<Room?> findRoomByCode(String roomCode) async {
    final query = _database
        .ref('rooms')
        .orderByChild('metadata/roomCode')
        .equalTo(roomCode)
        .limitToFirst(1);
    
    final snapshot = await query.get();
    if (!snapshot.exists) return null;
    
    final roomData = snapshot.children.first;
    return Room.fromJson(
      Map<String, dynamic>.from(roomData.value as Map)
    );
  }
  
  // Get active rooms with player count
  Stream<List<Room>> getActiveRoomsStream() {
    return _database
        .ref('rooms')
        .orderByChild('metadata/status')
        .equalTo('waiting')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return <Room>[];
          
          final roomsMap = Map<String, dynamic>.from(
            event.snapshot.value as Map
          );
          
          return roomsMap.entries
              .map((entry) => Room.fromJson(
                  Map<String, dynamic>.from(entry.value as Map)
              ))
              .where((room) => room.players.length < room.maxPlayers)
              .toList();
        });
  }
}
```

### Caching Service
```dart
class CacheService {
  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl = const Duration(minutes: 5);
  
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }
  
  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      value: value,
      expiry: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }
  
  void invalidate(String key) {
    _cache.remove(key);
  }
  
  void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiry;
  
  CacheEntry({required this.value, required this.expiry});
  
  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

### Data Structure Optimization
```dart
// Optimized for minimal real-time sync payload
class OptimizedGameState {
  // Only sync changed snake positions, not entire snake
  static Map<String, dynamic> encodeSnakeUpdate(
    String playerId, 
    Snake snake,
  ) {
    return {
      'snakes/$playerId/head': snake.positions.first.toJson(),
      'snakes/$playerId/direction': snake.direction.name,
      'snakes/$playerId/alive': snake.alive,
      'snakes/$playerId/score': snake.score,
    };
  }
  
  // Batch multiple updates to reduce Firebase calls
  static Future<void> batchUpdateGameState(
    String roomId,
    List<Map<String, dynamic>> updates,
  ) async {
    final batch = <String, dynamic>{};
    
    for (final update in updates) {
      for (final entry in update.entries) {
        batch['rooms/$roomId/gameState/${entry.key}'] = entry.value;
      }
    }
    
    await FirebaseDatabase.instance.ref().update(batch);
  }
}
```

## Testing
- [ ] Performance tests for database queries with indexing
- [ ] Load tests with multiple concurrent users
- [ ] Caching functionality tests

## Acceptance Criteria
- [ ] Database indexing configured for all query patterns
- [ ] Query performance meets <100ms response time requirement
- [ ] Data structure optimized for minimal bandwidth usage
- [ ] Caching service reduces redundant database calls
- [ ] Real-time sync performance optimized
- [ ] Performance benchmarks documented

## Dependencies
- Before: Database service implementation complete
- After: Room management can use optimized database operations
- External: Firebase Realtime Database performance monitoring

## Risks
- Risk: Over-indexing causing write performance degradation
- Mitigation: Balanced indexing strategy based on read/write patterns

## Definition of Done
- [ ] Database indexing implemented and tested
- [ ] Query optimization completed
- [ ] Caching service functional
- [ ] Performance benchmarks met
- [ ] Data structure optimized
- [ ] Documentation updated with performance guidelines
