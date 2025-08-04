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
  Future<Room> createRoom({
    int maxPlayers = 4,
  }) async {
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
        isReady: false,
        isConnected: true,
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

  /// Generates a unique room ID.
  String _generateRoomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'room_${timestamp}_$random';
  }
}
