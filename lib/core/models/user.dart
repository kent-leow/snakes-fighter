import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Represents user statistics.
@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int gamesPlayed,
    @Default(0) int gamesWon,
    required DateTime lastActive,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

/// Represents a user in the system.
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String displayName,
    @Default(false) bool isAnonymous,
    required UserStats stats,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Extension methods for User.
extension UserExtension on User {
  /// Calculates the user's win rate.
  double get winRate {
    if (stats.gamesPlayed == 0) return 0.0;
    return stats.gamesWon / stats.gamesPlayed;
  }

  /// Gets the user's win rate as a percentage.
  double get winRatePercentage => winRate * 100;

  /// Checks if the user is a new player.
  bool get isNewPlayer => stats.gamesPlayed == 0;

  /// Gets a user-friendly win rate string.
  String get winRateString {
    if (stats.gamesPlayed == 0) return 'No games played';
    return '${winRatePercentage.toStringAsFixed(1)}%';
  }
}

/// Extension methods for UserStats.
extension UserStatsExtension on UserStats {
  /// Creates stats for a new user.
  static UserStats newUser() {
    return UserStats(lastActive: DateTime.now());
  }

  /// Updates the stats after a game is played.
  UserStats afterGame({required bool won}) {
    return copyWith(
      gamesPlayed: gamesPlayed + 1,
      gamesWon: won ? gamesWon + 1 : gamesWon,
      lastActive: DateTime.now(),
    );
  }

  /// Updates the last active timestamp.
  UserStats updateLastActive() {
    return copyWith(lastActive: DateTime.now());
  }
}
