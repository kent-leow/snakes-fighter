import '../../../core/services/audio_service.dart';

/// Manages game-specific audio effects and sound feedback.
///
/// Provides convenient methods for playing sounds during game events
/// like food consumption, collisions, and game over scenarios.
class GameAudioManager {
  final AudioService _audioService = AudioService.instance;

  /// Play sound when snake consumes food.
  void onFoodConsumed() {
    _audioService.playSound('food_eat');
  }

  /// Play sound when game ends.
  void onGameOver() {
    _audioService.playSound('game_over');
  }

  /// Play sound when snake collides with wall or itself.
  void onCollision() {
    _audioService.playSound('collision');
  }

  /// Play sound when score increases significantly.
  ///
  /// [currentScore] - The current score to check for milestones
  void onScoreIncrease(int currentScore) {
    // Play milestone sound for every 100 points
    if (_shouldPlayScoreSound(currentScore)) {
      _audioService.playSound('food_eat'); // Reuse food sound for now
    }
  }

  /// Determine if score milestone sound should play.
  bool _shouldPlayScoreSound(int score) {
    // Play sound at score milestones (every 100 points)
    return score > 0 && score % 100 == 0;
  }
}
