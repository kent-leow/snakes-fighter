import 'dart:math';

import '../../../core/models/models.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/room_code_service.dart';

/// Exception thrown when room operations fail.
class RoomException implements Exception {
  const RoomException(this.message);

  final String message;

  @override
  String toString() => 'RoomException: $message';
}

/// Service for room management operations.
class RoomService {
  const RoomService(
    this._databaseService,
    this._authService,
    this._roomCodeService,
  );

  final DatabaseService _databaseService;
  final AuthService _authService;
  final RoomCodeService _roomCodeService;

  /// Creates a new room with the current user as host.
  ///
  /// [maxPlayers] defaults to 4 if not specified.
  ///
  /// Throws [RoomException] if user is not authenticated or room creation fails.
  Future<Room> createRoom({int maxPlayers = 4}) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const RoomException('User must be authenticated to create room');
    }

    if (maxPlayers < 2 || maxPlayers > 8) {
      throw const RoomException('Max players must be between 2 and 8');
    }

    try {
      final roomCode = await _roomCodeService.generateUniqueRoomCode();
      final roomId = _generateRoomId();

      // Get the next available color for the host
      final hostColor = PlayerColor.values.first;

      final host = Player(
        uid: user.uid,
        displayName: user.displayName ?? 'Anonymous',
        color: hostColor,
        joinedAt: DateTime.now(),
      );

      final room = Room(
        id: roomId,
        roomCode: roomCode,
        hostId: user.uid,
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        maxPlayers: maxPlayers,
        players: {user.uid: host},
      );

      return await _databaseService.createRoom(room);
    } catch (e) {
      throw RoomException('Failed to create room: $e');
    }
  }

  /// Joins an existing room using a room code.
  ///
  /// Throws [RoomException] if user is not authenticated, room not found,
  /// room is full, or user is already in the room.
  Future<Room> joinRoom(String roomCode) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const RoomException('User must be authenticated to join room');
    }

    final room = await _databaseService.getRoomByCode(roomCode);
    if (room == null) {
      throw RoomException('Room not found with code: $roomCode');
    }

    if (room.status != RoomStatus.waiting) {
      throw const RoomException('Room is not accepting new players');
    }

    if (room.players.length >= room.maxPlayers) {
      throw const RoomException('Room is full');
    }

    if (room.players.containsKey(user.uid)) {
      throw const RoomException('You are already in this room');
    }

    final availableColor = _getAvailableColor(room.players.values.toList());
    final player = Player(
      uid: user.uid,
      displayName: user.displayName ?? 'Anonymous',
      color: availableColor,
      joinedAt: DateTime.now(),
    );

    await _databaseService.addPlayerToRoom(room.id, player);

    return room.copyWith(players: {...room.players, user.uid: player});
  }

  /// Leaves the current room.
  ///
  /// If the user is the host and there are other players, the host role
  /// is transferred to the next player.
  Future<void> leaveRoom(String roomId) async {
    final user = _authService.currentUser;
    if (user == null) return;

    final room = await _databaseService.getRoomById(roomId);
    if (room == null) return;

    await _databaseService.removePlayerFromRoom(roomId, user.uid);

    // If the user was the host and there are other players, transfer host
    if (room.hostId == user.uid && room.players.length > 1) {
      final remainingPlayers = room.players.values
          .where((p) => p.uid != user.uid)
          .toList();

      if (remainingPlayers.isNotEmpty) {
        final newHost = remainingPlayers.first;
        final updatedRoom = room.copyWith(hostId: newHost.uid);
        await _databaseService.updateRoom(updatedRoom);
      }
    }
  }

  /// Gets the next available color for a new player.
  PlayerColor _getAvailableColor(List<Player> existingPlayers) {
    final usedColors = existingPlayers.map((p) => p.color).toSet();

    for (final color in PlayerColor.values) {
      if (!usedColors.contains(color)) {
        return color;
      }
    }

    // Fallback to red if all colors used (shouldn't happen with max players)
    return PlayerColor.red;
  }

  /// Generates a unique room ID.
  String _generateRoomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'room_${timestamp}_$random';
  }
}
