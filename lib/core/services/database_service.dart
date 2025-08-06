import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import '../models/models.dart';
import 'cache_service.dart';

/// Exception thrown when database operations fail.
class DatabaseException implements Exception {
  /// Creates a new database exception.
  const DatabaseException(this.message, {this.code, this.originalError});

  /// The error message.
  final String message;

  /// Optional error code for specific error types.
  final String? code;

  /// The original error that caused this exception.
  final dynamic originalError;

  @override
  String toString() => 'DatabaseException: $message';
}

/// Error codes for database operations.
enum DatabaseErrorCode {
  /// Failed to connect to the database.
  connectionFailed,

  /// Permission denied for the operation.
  permissionDenied,

  /// Requested data was not found.
  dataNotFound,

  /// Invalid data provided.
  invalidData,

  /// Transaction was aborted.
  transactionAborted,
}

/// Abstract interface for database operations.
abstract class DatabaseService {
  // Room operations
  /// Creates a new room in the database.
  Future<Room> createRoom(Room room);

  /// Retrieves a room by its ID.
  Future<Room?> getRoomById(String roomId);

  /// Retrieves a room by its room code.
  Future<Room?> getRoomByCode(String roomCode);

  /// Updates an existing room.
  Future<void> updateRoom(Room room);

  /// Deletes a room from the database.
  Future<void> deleteRoom(String roomId);

  /// Watches for changes to a room.
  Stream<Room?> watchRoom(String roomId);

  // Player operations
  /// Adds a player to a room.
  Future<void> addPlayerToRoom(String roomId, Player player);

  /// Removes a player from a room.
  Future<void> removePlayerFromRoom(String roomId, String playerId);

  /// Updates a player in a room.
  Future<void> updatePlayer(String roomId, Player player);

  /// Watches for changes to players in a room.
  Stream<Map<String, Player>> watchRoomPlayers(String roomId);

  // Game state operations
  /// Updates the game state for a room.
  Future<void> updateGameState(String roomId, GameState gameState);

  /// Watches for changes to game state in a room.
  Stream<GameState?> watchGameState(String roomId);

  // Transaction operations
  /// Runs an atomic database operation.
  Future<T> runAtomicOperation<T>(Future<T> Function() operation);

  /// Performs a batch update operation on multiple paths.
  Future<void> batchUpdate(Map<String, dynamic> updates);
}

/// Firebase implementation of the database service.
class FirebaseDatabaseService implements DatabaseService {
  /// Creates a new Firebase database service.
  FirebaseDatabaseService({
    FirebaseDatabase? database,
    CacheService? cacheService,
  }) : _database = database ?? FirebaseDatabase.instance,
       _cache = cacheService ?? CacheService();

  final FirebaseDatabase _database;
  final CacheService _cache;

  @override
  Future<Room> createRoom(Room room) async {
    try {
      final ref = _database.ref('rooms/${room.id}');
      await ref.set(room.toJson());
      return room;
    } catch (e) {
      throw DatabaseException(
        'Failed to create room: $e',
        code: DatabaseErrorCode.connectionFailed.name,
        originalError: e,
      );
    }
  }

  @override
  Future<Room?> getRoomById(String roomId) async {
    // Check cache first
    final cacheKey = 'room:$roomId';
    final cached = _cache.get<Room>(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final ref = _database.ref('rooms/$roomId');
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.value == null) {
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final room = Room.fromJson(data);

      // Cache for short duration since room state changes frequently
      _cache.set(cacheKey, room, ttl: const Duration(seconds: 30));

      return room;
    } catch (e) {
      throw DatabaseException(
        'Failed to get room by ID: $e',
        code: DatabaseErrorCode.dataNotFound.name,
        originalError: e,
      );
    }
  }

  @override
  Future<Room?> getRoomByCode(String roomCode) async {
    // Check cache first
    final cacheKey = 'room_by_code:$roomCode';
    final cached = _cache.get<Room>(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      // Optimized query using indexed field
      final ref = _database.ref('rooms');
      final query = ref
          .orderByChild('roomCode')
          .equalTo(roomCode)
          .limitToFirst(1);
      final snapshot = await query.get();

      if (!snapshot.exists || snapshot.value == null) {
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final roomEntry = data.entries.first;
      final roomData = Map<String, dynamic>.from(roomEntry.value as Map);

      final room = Room.fromJson(roomData);

      // Cache for short duration since room state changes frequently
      _cache.set(cacheKey, room, ttl: const Duration(seconds: 30));

      return room;
    } catch (e) {
      throw DatabaseException(
        'Failed to get room by code: $e',
        code: DatabaseErrorCode.dataNotFound.name,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateRoom(Room room) async {
    try {
      final ref = _database.ref('rooms/${room.id}');
      await ref.update(room.toJson());

      // Invalidate cache
      invalidateRoomCache(room.id);
    } catch (e) {
      throw DatabaseException(
        'Failed to update room: $e',
        code: DatabaseErrorCode.invalidData.name,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      final ref = _database.ref('rooms/$roomId');
      await ref.remove();
    } catch (e) {
      throw DatabaseException(
        'Failed to delete room: $e',
        code: DatabaseErrorCode.connectionFailed.name,
        originalError: e,
      );
    }
  }

  @override
  Stream<Room?> watchRoom(String roomId) {
    return _database
        .ref('rooms/$roomId')
        .onValue
        .map((event) {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return null;
          }

          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            return Room.fromJson(data);
          } catch (e) {
            throw DatabaseException(
              'Failed to parse room data: $e',
              code: DatabaseErrorCode.invalidData.name,
              originalError: e,
            );
          }
        })
        .handleError((error) {
          throw DatabaseException(
            'Failed to watch room: $error',
            code: DatabaseErrorCode.connectionFailed.name,
            originalError: error,
          );
        });
  }

  @override
  Future<void> addPlayerToRoom(String roomId, Player player) async {
    try {
      final ref = _database.ref('rooms/$roomId/players/${player.uid}');
      await ref.set(player.toJson());

      // Invalidate cache
      invalidateRoomCache(roomId);
    } catch (e) {
      throw DatabaseException(
        'Failed to add player to room: $e',
        code: DatabaseErrorCode.invalidData.name,
        originalError: e,
      );
    }
  }

  @override
  Future<void> removePlayerFromRoom(String roomId, String playerId) async {
    try {
      final ref = _database.ref('rooms/$roomId/players/$playerId');
      await ref.remove();

      // Invalidate cache
      invalidateRoomCache(roomId);
    } catch (e) {
      throw DatabaseException(
        'Failed to remove player from room: $e',
        code: DatabaseErrorCode.connectionFailed.name,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updatePlayer(String roomId, Player player) async {
    try {
      final ref = _database.ref('rooms/$roomId/players/${player.uid}');
      await ref.update(player.toJson());
    } catch (e) {
      throw DatabaseException(
        'Failed to update player: $e',
        code: DatabaseErrorCode.invalidData.name,
        originalError: e,
      );
    }
  }

  @override
  Stream<Map<String, Player>> watchRoomPlayers(String roomId) {
    return _database
        .ref('rooms/$roomId/players')
        .onValue
        .map((event) {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return <String, Player>{};
          }

          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            return data.map((key, value) {
              final playerData = Map<String, dynamic>.from(value as Map);
              return MapEntry(key, Player.fromJson(playerData));
            });
          } catch (e) {
            throw DatabaseException(
              'Failed to parse players data: $e',
              code: DatabaseErrorCode.invalidData.name,
              originalError: e,
            );
          }
        })
        .handleError((error) {
          throw DatabaseException(
            'Failed to watch room players: $error',
            code: DatabaseErrorCode.connectionFailed.name,
            originalError: error,
          );
        });
  }

  @override
  Future<void> updateGameState(String roomId, GameState gameState) async {
    try {
      final ref = _database.ref('rooms/$roomId/gameState');
      await ref.set(gameState.toJson());
    } catch (e) {
      throw DatabaseException(
        'Failed to update game state: $e',
        code: DatabaseErrorCode.invalidData.name,
        originalError: e,
      );
    }
  }

  @override
  Stream<GameState?> watchGameState(String roomId) {
    return _database
        .ref('rooms/$roomId/gameState')
        .onValue
        .map((event) {
          if (!event.snapshot.exists || event.snapshot.value == null) {
            return null;
          }

          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            return GameState.fromJson(data);
          } catch (e) {
            throw DatabaseException(
              'Failed to parse game state data: $e',
              code: DatabaseErrorCode.invalidData.name,
              originalError: e,
            );
          }
        })
        .handleError((error) {
          throw DatabaseException(
            'Failed to watch game state: $error',
            code: DatabaseErrorCode.connectionFailed.name,
            originalError: error,
          );
        });
  }

  @override
  Future<T> runAtomicOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw DatabaseException(
        'Atomic operation failed: $e',
        code: DatabaseErrorCode.transactionAborted.name,
        originalError: e,
      );
    }
  }

  // Optimized query methods

  /// Gets active rooms with efficient querying
  Future<List<Room>> getActiveRooms({int? limit}) async {
    const cacheKey = 'active_rooms';
    final cached = _cache.get<List<Room>>(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      var query = _database
          .ref('rooms')
          .orderByChild('status')
          .equalTo('waiting');

      if (limit != null) {
        query = query.limitToFirst(limit);
      }

      final snapshot = await query.get();
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final roomsMap = Map<String, dynamic>.from(snapshot.value as Map);
      final rooms = roomsMap.entries
          .map((entry) {
            final roomData = Map<String, dynamic>.from(entry.value as Map);
            return Room.fromJson(roomData);
          })
          .where((room) => room.players.length < room.maxPlayers)
          .toList();

      // Cache for short duration
      _cache.set(cacheKey, rooms, ttl: const Duration(seconds: 15));

      return rooms;
    } catch (e) {
      throw DatabaseException(
        'Failed to get active rooms: $e',
        code: DatabaseErrorCode.dataNotFound.name,
        originalError: e,
      );
    }
  }

  /// Batch update multiple paths atomically
  @override
  Future<void> batchUpdate(Map<String, dynamic> updates) async {
    try {
      await _database.ref().update(updates);

      // Invalidate relevant cache entries
      for (final path in updates.keys) {
        if (path.contains('rooms/')) {
          final roomId = path.split('/')[1];
          _cache.invalidate('room:$roomId');
          _cache.invalidate('active_rooms');
        }
      }
    } catch (e) {
      throw DatabaseException(
        'Batch update failed: $e',
        code: DatabaseErrorCode.connectionFailed.name,
        originalError: e,
      );
    }
  }

  /// Optimized snake position update for minimal bandwidth
  Future<void> updateSnakePositions(
    String roomId,
    Map<String, dynamic> snakeUpdates,
  ) async {
    try {
      final batch = <String, dynamic>{};

      for (final entry in snakeUpdates.entries) {
        final playerId = entry.key;
        final snakeData = entry.value as Map<String, dynamic>;

        // Only sync essential data
        batch['rooms/$roomId/gameState/snakes/$playerId/head'] =
            snakeData['head'];
        batch['rooms/$roomId/gameState/snakes/$playerId/direction'] =
            snakeData['direction'];
        batch['rooms/$roomId/gameState/snakes/$playerId/alive'] =
            snakeData['alive'];
        batch['rooms/$roomId/gameState/snakes/$playerId/score'] =
            snakeData['score'];
      }

      await _database.ref().update(batch);

      // Invalidate game state cache
      _cache.invalidate('gamestate:$roomId');
    } catch (e) {
      throw DatabaseException(
        'Failed to update snake positions: $e',
        code: DatabaseErrorCode.invalidData.name,
        originalError: e,
      );
    }
  }

  /// Cache management methods

  /// Invalidates cache entries for a room
  void invalidateRoomCache(String roomId) {
    _cache.invalidate('room:$roomId');
    _cache.invalidate('gamestate:$roomId');
    _cache.invalidate('players:$roomId');
    _cache.invalidate('active_rooms');
  }

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    return {'size': _cache.size, 'keys': _cache.keys.toList()};
  }

  /// Clears all cache entries
  void clearCache() {
    _cache.clear();
  }
}
