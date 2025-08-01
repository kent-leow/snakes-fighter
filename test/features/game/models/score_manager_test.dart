import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/models/score_manager.dart';

void main() {
  group('ScoreManager', () {
    late ScoreManager scoreManager;

    setUp(() {
      scoreManager = ScoreManager();
    });

    tearDown(() {
      scoreManager.dispose();
    });

    group('initialization', () {
      test('should initialize with zero scores', () {
        expect(scoreManager.currentScore, 0);
        expect(scoreManager.highScore, 0);
        expect(scoreManager.foodEaten, 0);
        expect(scoreManager.gameSessionCount, 0);
      });

      test('should provide score streams', () {
        expect(scoreManager.scoreStream, isNotNull);
        expect(scoreManager.highScoreStream, isNotNull);
      });
    });

    group('score management', () {
      test('should add points correctly', () {
        scoreManager.addPoints(10);
        expect(scoreManager.currentScore, 10);

        scoreManager.addPoints(5);
        expect(scoreManager.currentScore, 15);
      });

      test('should not add negative or zero points', () {
        scoreManager.addPoints(-10);
        expect(scoreManager.currentScore, 0);

        scoreManager.addPoints(0);
        expect(scoreManager.currentScore, 0);
      });

      test('should update high score automatically', () {
        scoreManager.addPoints(50);
        expect(scoreManager.highScore, 50);

        scoreManager.addPoints(25);
        expect(scoreManager.highScore, 75);
      });

      test('should not decrease high score', () {
        scoreManager.addPoints(100);
        expect(scoreManager.highScore, 100);

        scoreManager.resetScore();
        scoreManager.addPoints(50);
        expect(scoreManager.highScore, 100);
        expect(scoreManager.currentScore, 50);
      });

      test('should reset current score only', () {
        scoreManager.addPoints(100);
        expect(scoreManager.currentScore, 100);
        expect(scoreManager.highScore, 100);

        scoreManager.resetScore();
        expect(scoreManager.currentScore, 0);
        expect(scoreManager.highScore, 100);
        expect(scoreManager.foodEaten, 0);
      });
    });

    group('food scoring', () {
      test('should calculate basic food points', () {
        scoreManager.addFoodPoints();
        expect(scoreManager.currentScore, 10);
        expect(scoreManager.foodEaten, 1);
      });

      test('should calculate bonus points based on snake length', () {
        // Length 1-9: no bonus
        scoreManager.addFoodPoints(snakeLength: 5);
        expect(scoreManager.currentScore, 10);

        // Length 10-19: +1 bonus
        scoreManager.addFoodPoints(snakeLength: 15);
        expect(scoreManager.currentScore, 21); // 10 + 11

        // Length 20-29: +2 bonus
        scoreManager.addFoodPoints(snakeLength: 25);
        expect(scoreManager.currentScore, 33); // 21 + 12
      });

      test('should use custom base points', () {
        scoreManager.addFoodPoints(basePoints: 20, snakeLength: 1);
        expect(scoreManager.currentScore, 20);
        expect(scoreManager.foodEaten, 1);
      });

      test('should track food eaten count', () {
        scoreManager.addFoodPoints();
        scoreManager.addFoodPoints();
        scoreManager.addFoodPoints();
        expect(scoreManager.foodEaten, 3);
      });
    });

    group('session management', () {
      test('should start new session correctly', () {
        scoreManager.addPoints(50);
        expect(scoreManager.gameSessionCount, 0);

        scoreManager.startNewSession();
        expect(scoreManager.gameSessionCount, 1);
        expect(scoreManager.currentScore, 0);
        expect(scoreManager.foodEaten, 0);
      });

      test('should track multiple sessions', () {
        scoreManager.startNewSession();
        scoreManager.startNewSession();
        scoreManager.startNewSession();
        expect(scoreManager.gameSessionCount, 3);
      });
    });

    group('statistics', () {
      test('should provide comprehensive stats', () {
        scoreManager.startNewSession();
        scoreManager.addFoodPoints();
        scoreManager.addFoodPoints();

        final stats = scoreManager.getScoreStats();

        expect(stats['currentScore'], 20);
        expect(stats['highScore'], 20);
        expect(stats['foodEaten'], 2);
        expect(stats['gameSessionCount'], 1);
        expect(stats['averageScorePerFood'], 10.0);
      });

      test('should handle zero food case in stats', () {
        final stats = scoreManager.getScoreStats();
        expect(stats['averageScorePerFood'], 0.0);
      });
    });

    group('score calculation', () {
      test('should calculate potential score correctly', () {
        final potentialScore = scoreManager.calculatePotentialScore(
          foodCount: 5,
          averageSnakeLength: 10,
        );

        // Expected calculation:
        // Food 1: length 4 (3+1), bonus 0, score 10
        // Food 2: length 5 (3+2), bonus 0, score 10  
        // Food 3: length 6 (3+3), bonus 0, score 10
        // Food 4: length 7 (3+4), bonus 0, score 10
        // Food 5: length 8 (3+5), bonus 0, score 10
        // Total: 50
        expect(potentialScore, 50);
      });

      test('should use custom base points in calculation', () {
        final potentialScore = scoreManager.calculatePotentialScore(
          foodCount: 2,
          averageSnakeLength: 5,
          basePointsPerFood: 20,
        );

        expect(potentialScore, 40); // 20 + 20, no bonus yet
      });
    });

    group('streams', () {
      test('should emit score updates through stream', () async {
        final scores = <int>[];
        final subscription = scoreManager.scoreStream.listen((score) {
          scores.add(score);
        });

        scoreManager.addPoints(10);
        scoreManager.addPoints(5);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(scores, [10, 15]);
        await subscription.cancel();
      });

      test('should emit high score updates through stream', () async {
        final highScores = <int>[];
        final subscription = scoreManager.highScoreStream.listen((score) {
          highScores.add(score);
        });

        scoreManager.addPoints(25);
        scoreManager.resetScore();
        scoreManager.addPoints(50); // Should trigger new high score

        await Future.delayed(const Duration(milliseconds: 10));

        expect(highScores, [25, 50]);
        await subscription.cancel();
      });
    });

    group('manual high score updates', () {
      test('should update high score manually if higher', () {
        scoreManager.updateHighScore(100);
        expect(scoreManager.highScore, 100);
      });

      test('should not update high score if lower', () {
        scoreManager.addPoints(50);
        scoreManager.updateHighScore(25);
        expect(scoreManager.highScore, 50);
      });
    });
  });
}
