import 'dart:async';

import '../../../core/models/models.dart';
import '../../../core/services/database_service.dart';

/// Service for real-time game state synchronization.
///
/// Handles synchronization of game state changes across all players
/// using Firebase Realtime Database. Provides methods for syncing
/// player movements, food consumption, deaths, and other game events.
class GameSyncService {
  /// Creates a new game sync service.
  GameSyncService(this._databaseService);

  final DatabaseService _databaseService;
  final Map<String, StreamSubscription> _subscriptions = {};

  /// Watches game state changes for a room.
  ///
  /// Returns a stream of game state updates that filters out null values.
  Stream<GameState> watchGameState(String roomId) {
    return _databaseService
        .watchGameState(roomId)
        .where((state) => state != null)
        .cast<GameState>();
  }

  /// Synchronizes a player's movement.
  ///
  /// Updates the player's snake direction and last update timestamp
  /// in the database. This triggers real-time updates for all players
  /// watching the game state.
  Future<void> syncPlayerMove(
    String roomId,
    String playerId,
    Direction direction,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/snakes/$playerId/direction': direction.name,
      'rooms/$roomId/gameState/snakes/$playerId/lastUpdate': timestamp,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Synchronizes food consumption event.
  ///
  /// Updates the food position, increments player score, and handles
  /// snake growth in a single atomic operation.
  Future<void> syncFoodConsumption(
    String roomId,
    String playerId,
    Position foodPosition,
    Position newFoodPosition,
    int newScore,
  ) async {
    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/food/position': newFoodPosition.toJson(),
      'rooms/$roomId/gameState/snakes/$playerId/score': newScore,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Synchronizes a player's death.
  ///
  /// Marks the player's snake as not alive and records the death time.
  Future<void> syncPlayerDeath(String roomId, String playerId) async {
    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/snakes/$playerId/alive': false,
      'rooms/$roomId/gameState/snakes/$playerId/deathTime':
          DateTime.now().millisecondsSinceEpoch,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Synchronizes complete snake positions.
  ///
  /// Updates all positions for a snake, typically used when the snake
  /// moves or grows. Uses optimized batch updates for performance.
  Future<void> syncSnakePositions(
    String roomId,
    String playerId,
    List<Position> positions,
    Direction direction,
    bool alive,
    int score,
  ) async {
    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/snakes/$playerId/positions': positions
          .map((p) => p.toJson())
          .toList(),
      'rooms/$roomId/gameState/snakes/$playerId/direction': direction.name,
      'rooms/$roomId/gameState/snakes/$playerId/alive': alive,
      'rooms/$roomId/gameState/snakes/$playerId/score': score,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Synchronizes game end state.
  ///
  /// Marks the game as ended, sets the winner, and records end time.
  Future<void> syncGameEnd(String roomId, String? winnerId) async {
    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/endedAt': DateTime.now().toIso8601String(),
      'rooms/$roomId/gameState/winner': winnerId,
      'rooms/$roomId/status': RoomStatus.ended.name,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Synchronizes game start.
  ///
  /// Marks the game as active and sets the start time.
  Future<void> syncGameStart(String roomId) async {
    final updates = <String, dynamic>{
      'rooms/$roomId/gameState/startedAt': DateTime.now().toIso8601String(),
      'rooms/$roomId/status': RoomStatus.active.name,
    };

    await _databaseService.batchUpdate(updates);
  }

  /// Performs atomic game state update.
  ///
  /// Wraps multiple updates in a single atomic operation to ensure
  /// consistency across related changes.
  Future<void> atomicUpdate(
    String roomId,
    Future<void> Function() updateOperation,
  ) async {
    await _databaseService.runAtomicOperation(updateOperation);
  }

  /// Disposes of all active subscriptions.
  ///
  /// Should be called when the service is no longer needed to prevent
  /// memory leaks from active database listeners.
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
}
