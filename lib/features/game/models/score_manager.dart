import 'dart:async';

import 'package:flutter/foundation.dart';

/// Manages score tracking and calculation for the game.
///
/// Handles real-time score updates, high score tracking, and provides
/// streams for UI components to listen to score changes.
class ScoreManager extends ChangeNotifier {
  int _currentScore = 0;
  int _highScore = 0;
  int _foodEaten = 0;
  int _gameSessionCount = 0;
  
  final StreamController<int> _scoreStreamController = 
      StreamController<int>.broadcast();
  final StreamController<int> _highScoreStreamController = 
      StreamController<int>.broadcast();

  /// Gets the current score.
  int get currentScore => _currentScore;
  
  /// Gets the high score.
  int get highScore => _highScore;
  
  /// Gets the number of food items eaten this session.
  int get foodEaten => _foodEaten;
  
  /// Gets the number of game sessions played.
  int get gameSessionCount => _gameSessionCount;
  
  /// Stream of score updates for real-time UI updates.
  Stream<int> get scoreStream => _scoreStreamController.stream;
  
  /// Stream of high score updates.
  Stream<int> get highScoreStream => _highScoreStreamController.stream;

  /// Adds points to the current score.
  ///
  /// Points are typically awarded for food consumption and game achievements.
  /// Automatically updates high score if current score exceeds it.
  void addPoints(int points) {
    if (points <= 0) return;
    
    _currentScore += points;
    _scoreStreamController.add(_currentScore);
    
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      _highScoreStreamController.add(_highScore);
    }
    
    notifyListeners();
  }
  
  /// Adds points specifically for food consumption.
  ///
  /// Uses base points with potential multipliers based on game progress.
  void addFoodPoints({int basePoints = 10, int snakeLength = 1}) {
    _foodEaten++;
    
    // Calculate bonus points based on snake length
    final bonusMultiplier = (snakeLength / 10).floor();
    final totalPoints = basePoints + bonusMultiplier;
    
    addPoints(totalPoints);
  }
  
  /// Resets the current score to zero.
  ///
  /// Typically called when starting a new game session.
  void resetScore() {
    _currentScore = 0;
    _foodEaten = 0;
    _scoreStreamController.add(_currentScore);
    notifyListeners();
  }
  
  /// Updates high score manually.
  ///
  /// Usually called when loading saved high scores or manual updates.
  void updateHighScore(int newHighScore) {
    if (newHighScore > _highScore) {
      _highScore = newHighScore;
      _highScoreStreamController.add(_highScore);
      notifyListeners();
    }
  }
  
  /// Starts a new game session.
  ///
  /// Resets current score and increments session count.
  void startNewSession() {
    _gameSessionCount++;
    resetScore();
  }
  
  /// Gets comprehensive score statistics.
  Map<String, dynamic> getScoreStats() {
    return {
      'currentScore': _currentScore,
      'highScore': _highScore,
      'foodEaten': _foodEaten,
      'gameSessionCount': _gameSessionCount,
      'averageScorePerFood': _foodEaten > 0 ? _currentScore / _foodEaten : 0.0,
    };
  }
  
  /// Calculates potential score for given parameters.
  ///
  /// Useful for previewing score calculations.
  int calculatePotentialScore({
    required int foodCount,
    required int averageSnakeLength,
    int basePointsPerFood = 10,
  }) {
    int totalScore = 0;
    
    for (int i = 1; i <= foodCount; i++) {
      final currentLength = 3 + i; // Initial length + growth
      final bonusMultiplier = (currentLength / 10).floor();
      totalScore += basePointsPerFood + bonusMultiplier;
    }
    
    return totalScore;
  }

  @override
  void dispose() {
    _scoreStreamController.close();
    _highScoreStreamController.close();
    super.dispose();
  }
}
