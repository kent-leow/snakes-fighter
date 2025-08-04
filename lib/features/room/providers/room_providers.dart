import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/room_code_service.dart';
import '../services/player_management_service.dart';
import '../services/room_service.dart';

/// State for room creation operations.
class RoomCreationState {
  const RoomCreationState({
    this.isLoading = false,
    this.createdRoom,
    this.error,
  });

  final bool isLoading;
  final Room? createdRoom;
  final String? error;

  RoomCreationState copyWith({
    bool? isLoading,
    Room? createdRoom,
    String? error,
  }) {
    return RoomCreationState(
      isLoading: isLoading ?? this.isLoading,
      createdRoom: createdRoom ?? this.createdRoom,
      error: error ?? this.error,
    );
  }
}

/// State for current room operations.
class CurrentRoomState {
  const CurrentRoomState({
    this.room,
    this.isLoading = false,
    this.error,
    this.isHost = false,
  });

  final Room? room;
  final bool isLoading;
  final String? error;
  final bool isHost;

  CurrentRoomState copyWith({
    Room? room,
    bool? isLoading,
    String? error,
    bool? isHost,
  }) {
    return CurrentRoomState(
      room: room ?? this.room,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isHost: isHost ?? this.isHost,
    );
  }
}

/// State for room joining operations.
class RoomJoiningState {
  const RoomJoiningState({this.isLoading = false, this.joinedRoom, this.error});

  final bool isLoading;
  final Room? joinedRoom;
  final String? error;

  RoomJoiningState copyWith({
    bool? isLoading,
    Room? joinedRoom,
    String? error,
  }) {
    return RoomJoiningState(
      isLoading: isLoading ?? this.isLoading,
      joinedRoom: joinedRoom ?? this.joinedRoom,
      error: error ?? this.error,
    );
  }
}

/// Notifier for room creation state.
class RoomCreationNotifier extends StateNotifier<RoomCreationState> {
  RoomCreationNotifier(this._roomService) : super(const RoomCreationState());

  final RoomService _roomService;

  /// Creates a new room with the specified maximum number of players.
  Future<void> createRoom({int maxPlayers = 4}) async {
    state = state.copyWith(isLoading: true);

    try {
      final room = await _roomService.createRoom(maxPlayers: maxPlayers);
      state = state.copyWith(isLoading: false, createdRoom: room);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clears the current room creation state.
  void clearState() {
    state = const RoomCreationState();
  }
}

/// Notifier for current room state.
class CurrentRoomNotifier extends StateNotifier<CurrentRoomState> {
  CurrentRoomNotifier(
    this._databaseService,
    this._roomService,
    this._playerManagementService,
    this._authService,
  ) : super(const CurrentRoomState());

  final DatabaseService _databaseService;
  final RoomService _roomService;
  final PlayerManagementService _playerManagementService;
  final AuthService _authService;
  StreamSubscription<Room?>? _roomSubscription;

  /// Joins a room by room code.
  Future<void> joinRoom(String roomCode) async {
    state = state.copyWith(isLoading: true);

    try {
      final room = await _roomService.joinRoom(roomCode);
      _subscribeToRoom(room.id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sets the current room and starts listening for updates.
  void setRoom(String roomId) {
    state = state.copyWith(isLoading: true);
    _subscribeToRoom(roomId);
  }

  /// Leaves the current room.
  Future<void> leaveRoom() async {
    final room = state.room;
    if (room == null) return;

    try {
      await _roomService.leaveRoom(room.id);
      _roomSubscription?.cancel();
      state = const CurrentRoomState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Updates the current player's ready status.
  Future<void> updatePlayerReady(bool isReady) async {
    final room = state.room;
    final user = _authService.currentUser;
    if (room == null || user == null) return;

    try {
      await _playerManagementService.updatePlayerReady(
        room.id,
        user.uid,
        isReady,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Kicks a player from the room (host only).
  Future<void> kickPlayer(String playerId) async {
    final room = state.room;
    final user = _authService.currentUser;
    if (room == null || user == null) return;

    try {
      await _playerManagementService.kickPlayer(room.id, user.uid, playerId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Transfers host privileges to another player.
  Future<void> transferHost(String newHostId) async {
    final room = state.room;
    final user = _authService.currentUser;
    if (room == null || user == null) return;

    try {
      await _playerManagementService.transferHost(room.id, user.uid, newHostId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _roomSubscription = _databaseService
        .watchRoom(roomId)
        .listen(
          (room) {
            if (room != null) {
              final user = _authService.currentUser;
              final isHost = user?.uid == room.hostId;
              state = state.copyWith(
                room: room,
                isLoading: false,
                isHost: isHost,
              );
            } else {
              // Room was deleted
              state = state.copyWith(
                isLoading: false,
                error: 'Room no longer exists',
              );
            }
          },
          onError: (error) {
            state = state.copyWith(isLoading: false, error: error.toString());
          },
        );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}

/// Notifier for room joining state.
class RoomJoiningNotifier extends StateNotifier<RoomJoiningState> {
  RoomJoiningNotifier(this._roomService) : super(const RoomJoiningState());

  final RoomService _roomService;

  /// Joins a room by room code.
  Future<void> joinRoom(String roomCode) async {
    state = state.copyWith(isLoading: true);

    try {
      final room = await _roomService.joinRoom(roomCode);
      state = state.copyWith(isLoading: false, joinedRoom: room);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clears the room joining state.
  void clearState() {
    state = const RoomJoiningState();
  }
}

/// Provider for room code service.
final roomCodeServiceProvider = Provider<RoomCodeService>((ref) {
  return RoomCodeService(ref.read(databaseServiceProvider));
});

/// Provider for room service.
final roomServiceProvider = Provider<RoomService>((ref) {
  return RoomService(
    ref.read(databaseServiceProvider),
    ref.read(authServiceProvider),
    ref.read(roomCodeServiceProvider),
  );
});

/// Provider for player management service.
final playerManagementServiceProvider = Provider<PlayerManagementService>((
  ref,
) {
  return PlayerManagementService(ref.read(databaseServiceProvider));
});

/// Provider for room creation state.
final roomCreationProvider =
    StateNotifierProvider<RoomCreationNotifier, RoomCreationState>((ref) {
      return RoomCreationNotifier(ref.read(roomServiceProvider));
    });

/// Provider for current room state.
final currentRoomProvider =
    StateNotifierProvider<CurrentRoomNotifier, CurrentRoomState>((ref) {
      return CurrentRoomNotifier(
        ref.read(databaseServiceProvider),
        ref.read(roomServiceProvider),
        ref.read(playerManagementServiceProvider),
        ref.read(authServiceProvider),
      );
    });

/// Provider for room joining state.
final roomJoiningProvider =
    StateNotifierProvider<RoomJoiningNotifier, RoomJoiningState>((ref) {
      return RoomJoiningNotifier(ref.read(roomServiceProvider));
    });
