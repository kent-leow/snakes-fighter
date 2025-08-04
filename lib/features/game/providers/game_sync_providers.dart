import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/database_providers.dart';
import '../services/services.dart';

/// Provider for the game synchronization service.
/// 
/// This service handles real-time synchronization of game state
/// across all players in a multiplayer game.
final gameSyncServiceProvider = Provider<GameSyncService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return GameSyncService(databaseService);
});

/// Provider for the game event broadcaster.
/// 
/// This service manages broadcasting of game events to all
/// players in a room for real-time multiplayer experience.
final gameEventBroadcasterProvider = Provider<GameEventBroadcaster>((ref) {
  return GameEventBroadcaster();
});

/// Provider for the delta update service.
/// 
/// This service optimizes network bandwidth by calculating
/// and applying only the changed parts of game state updates.
final deltaUpdateServiceProvider = Provider<DeltaUpdateService>((ref) {
  return DeltaUpdateService();
});

/// Provider for watching game state changes in a specific room.
/// 
/// Returns a stream of game state updates that automatically
/// filters out null values for reliable state management.
final gameStateStreamProvider = StreamProvider.family<GameState, String>((ref, roomId) {
  final syncService = ref.watch(gameSyncServiceProvider);
  return syncService.watchGameState(roomId);
});

/// Provider for game event streams in a specific room.
/// 
/// Returns a broadcast stream of all game events for the specified room.
/// Multiple widgets can listen to the same stream without conflicts.
final gameEventStreamProvider = StreamProvider.family<GameEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getEventStream(roomId);
});

/// Provider for player move events in a specific room.
/// 
/// Returns a stream of PlayerMoveEvent objects for the specified room.
final playerMoveEventStreamProvider = StreamProvider.family<PlayerMoveEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getFilteredEventStream<PlayerMoveEvent>(roomId);
});

/// Provider for food consumed events in a specific room.
/// 
/// Returns a stream of FoodConsumedEvent objects for the specified room.
final foodConsumedEventStreamProvider = StreamProvider.family<FoodConsumedEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getFilteredEventStream<FoodConsumedEvent>(roomId);
});

/// Provider for player death events in a specific room.
/// 
/// Returns a stream of PlayerDeathEvent objects for the specified room.
final playerDeathEventStreamProvider = StreamProvider.family<PlayerDeathEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getFilteredEventStream<PlayerDeathEvent>(roomId);
});

/// Provider for game start events in a specific room.
/// 
/// Returns a stream of GameStartEvent objects for the specified room.
final gameStartEventStreamProvider = StreamProvider.family<GameStartEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getFilteredEventStream<GameStartEvent>(roomId);
});

/// Provider for game end events in a specific room.
/// 
/// Returns a stream of GameEndEvent objects for the specified room.
final gameEndEventStreamProvider = StreamProvider.family<GameEndEvent, String>((ref, roomId) {
  final broadcaster = ref.watch(gameEventBroadcasterProvider);
  return broadcaster.getFilteredEventStream<GameEndEvent>(roomId);
});
