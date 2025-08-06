/// Represents different difficulty levels for the game.
enum GameDifficulty {
  /// Easy difficulty - slower speed, more forgiving.
  easy,

  /// Normal difficulty - balanced gameplay.
  normal,

  /// Hard difficulty - faster speed, more challenging.
  hard;

  /// Get the display name for the difficulty.
  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.normal:
        return 'Normal';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  /// Get the game tick duration for this difficulty.
  Duration get tickDuration {
    switch (this) {
      case GameDifficulty.easy:
        return const Duration(milliseconds: 200);
      case GameDifficulty.normal:
        return const Duration(milliseconds: 150);
      case GameDifficulty.hard:
        return const Duration(milliseconds: 100);
    }
  }
}
