import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Represents a player in the game.
@freezed
class Player with _$Player {
  const factory Player({
    required String uid,
    required String displayName,
    required PlayerColor color,
    required DateTime joinedAt,
    @Default(false) bool isReady,
    @Default(true) bool isConnected,
  }) = _Player;

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
}

/// Extension methods for Player.
extension PlayerExtension on Player {
  /// Checks if the player is ready to start the game.
  bool get canStartGame => isReady && isConnected;

  /// Creates a copy of the player with updated ready status.
  Player toggleReady() => copyWith(isReady: !isReady);

  /// Creates a copy of the player with updated connection status.
  Player updateConnection(bool connected) => copyWith(isConnected: connected);
}
