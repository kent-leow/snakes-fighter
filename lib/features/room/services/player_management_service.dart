import '../../../core/models/models.dart';
import '../../../core/services/database_service.dart';
import 'room_service.dart';

/// Service for managing players within rooms.
class PlayerManagementService {
  const PlayerManagementService(this._databaseService);

  final DatabaseService _databaseService;

  /// Updates a player's ready status in a room.
  ///
  /// Throws [RoomException] if room or player not found.
  Future<void> updatePlayerReady(
    String roomId,
    String playerId,
    bool isReady,
  ) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) throw const RoomException('Room not found');

    final player = room.players[playerId];
    if (player == null) throw const RoomException('Player not found in room');

    final updatedPlayer = player.copyWith(isReady: isReady);
    await _databaseService.updatePlayer(roomId, updatedPlayer);
  }

  /// Updates a player's connection status in a room.
  ///
  /// This is typically called when a player connects or disconnects.
  Future<void> updatePlayerConnection(
    String roomId,
    String playerId,
    bool isConnected,
  ) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) return;

    final player = room.players[playerId];
    if (player == null) return;

    final updatedPlayer = player.copyWith(isConnected: isConnected);
    await _databaseService.updatePlayer(roomId, updatedPlayer);
  }

  /// Checks if the game can be started in a room.
  ///
  /// A game can start if there are at least 2 connected players
  /// and all connected players are ready.
  Future<bool> canStartGame(String roomId) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) return false;

    final connectedPlayers = room.players.values
        .where((p) => p.isConnected)
        .toList();

    return connectedPlayers.length >= 2 &&
        connectedPlayers.every((p) => p.isReady);
  }

  /// Gets all players in a room with their current status.
  Future<Map<String, Player>> getRoomPlayers(String roomId) async {
    final room = await _databaseService.getRoomById(roomId);
    return room?.players ?? {};
  }

  /// Kicks a player from a room (host only).
  ///
  /// Throws [RoomException] if the requester is not the host.
  Future<void> kickPlayer(String roomId, String hostId, String playerId) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) throw const RoomException('Room not found');

    if (room.hostId != hostId) {
      throw const RoomException('Only the host can kick players');
    }

    if (playerId == hostId) {
      throw const RoomException('Host cannot kick themselves');
    }

    await _databaseService.removePlayerFromRoom(roomId, playerId);
  }

  /// Transfers host privileges to another player.
  ///
  /// Throws [RoomException] if the requester is not the current host
  /// or the target player is not in the room.
  Future<void> transferHost(
    String roomId,
    String currentHostId,
    String newHostId,
  ) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) throw const RoomException('Room not found');

    if (room.hostId != currentHostId) {
      throw const RoomException(
        'Only the current host can transfer host privileges',
      );
    }

    if (!room.players.containsKey(newHostId)) {
      throw const RoomException('New host must be a player in the room');
    }

    final updatedRoom = room.copyWith(hostId: newHostId);
    await _databaseService.updateRoom(updatedRoom);
  }

  /// Gets the count of ready players in a room.
  Future<int> getReadyPlayerCount(String roomId) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) return 0;

    return room.players.values.where((p) => p.isReady && p.isConnected).length;
  }

  /// Gets the count of connected players in a room.
  Future<int> getConnectedPlayerCount(String roomId) async {
    final room = await _databaseService.getRoomById(roomId);
    if (room == null) return 0;

    return room.players.values.where((p) => p.isConnected).length;
  }
}
