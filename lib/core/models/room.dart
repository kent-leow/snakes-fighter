import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'game_state.dart';
import 'player.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// Represents a game room.
@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String roomCode,
    required String hostId,
    required RoomStatus status,
    required DateTime createdAt,
    @Default(4) int maxPlayers,
    @JsonKey(fromJson: _playersFromJson, toJson: _playersToJson)
    @Default({})
    Map<String, Player> players,
    @JsonKey(fromJson: _gameStateFromJson, toJson: _gameStateToJson)
    GameState? gameState,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

Map<String, Player> _playersFromJson(Map<String, dynamic> json) {
  return json.map(
    (key, value) =>
        MapEntry(key, Player.fromJson(value as Map<String, dynamic>)),
  );
}

Map<String, dynamic> _playersToJson(Map<String, Player> players) {
  return players.map((key, value) => MapEntry(key, value.toJson()));
}

GameState? _gameStateFromJson(Map<String, dynamic>? json) {
  return json != null ? GameState.fromJson(json) : null;
}

Map<String, dynamic>? _gameStateToJson(GameState? gameState) {
  return gameState?.toJson();
}

/// Extension methods for Room.
extension RoomExtension on Room {
  /// Checks if the room is full.
  bool get isFull => players.length >= maxPlayers;

  /// Checks if the room can start a game.
  bool get canStartGame {
    return status == RoomStatus.waiting &&
        players.length >= 2 &&
        players.values.every((player) => player.isReady && player.isConnected);
  }

  /// Gets the host player.
  Player? get host => players[hostId];

  /// Checks if a user is the host.
  bool isHost(String userId) => hostId == userId;

  /// Gets all ready players.
  Map<String, Player> get readyPlayers {
    return Map.fromEntries(
      players.entries.where((entry) => entry.value.isReady),
    );
  }

  /// Gets all connected players.
  Map<String, Player> get connectedPlayers {
    return Map.fromEntries(
      players.entries.where((entry) => entry.value.isConnected),
    );
  }

  /// Gets the number of connected players.
  int get connectedPlayerCount => connectedPlayers.length;

  /// Checks if the room has space for more players.
  bool get hasSpace => players.length < maxPlayers;

  /// Checks if the room is active.
  bool get isActive => status == RoomStatus.active;

  /// Checks if the room is waiting for players.
  bool get isWaiting => status == RoomStatus.waiting;

  /// Checks if the room has ended.
  bool get hasEnded => status == RoomStatus.ended;

  /// Gets a player by their ID.
  Player? getPlayer(String playerId) => players[playerId];

  /// Checks if a player exists in the room.
  bool hasPlayer(String playerId) => players.containsKey(playerId);

  /// Gets available colors for new players.
  List<PlayerColor> get availableColors {
    final usedColors = players.values.map((p) => p.color).toSet();
    return PlayerColor.values
        .where((color) => !usedColors.contains(color))
        .toList();
  }
}
