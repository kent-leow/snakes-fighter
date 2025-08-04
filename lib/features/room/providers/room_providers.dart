import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/database_providers.dart';
import '../../../core/services/room_code_service.dart';
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

/// Notifier for room creation state.
class RoomCreationNotifier extends StateNotifier<RoomCreationState> {
  RoomCreationNotifier(this._roomService) : super(const RoomCreationState());

  final RoomService _roomService;

  /// Creates a new room with the specified maximum number of players.
  Future<void> createRoom({int maxPlayers = 4}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final room = await _roomService.createRoom(maxPlayers: maxPlayers);
      state = state.copyWith(
        isLoading: false,
        createdRoom: room,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clears the current room creation state.
  void clearState() {
    state = const RoomCreationState();
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

/// Provider for room creation state.
final roomCreationProvider = StateNotifierProvider<RoomCreationNotifier, RoomCreationState>((ref) {
  return RoomCreationNotifier(ref.read(roomServiceProvider));
});
