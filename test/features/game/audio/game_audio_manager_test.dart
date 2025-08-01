import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/audio/game_audio_manager.dart';

void main() {
  group('GameAudioManager', () {
    late GameAudioManager gameAudioManager;

    setUp(() {
      gameAudioManager = GameAudioManager();
    });

    test('should not throw when calling audio methods', () {
      expect(() => gameAudioManager.onFoodConsumed(), returnsNormally);
      expect(() => gameAudioManager.onGameOver(), returnsNormally);
      expect(() => gameAudioManager.onCollision(), returnsNormally);
    });

    test('should determine score milestone correctly', () {
      // Test score milestone logic
      gameAudioManager.onScoreIncrease(50); // Should not trigger
      gameAudioManager.onScoreIncrease(100); // Should trigger
      gameAudioManager.onScoreIncrease(150); // Should not trigger
      gameAudioManager.onScoreIncrease(200); // Should trigger

      // These calls should not throw
      expect(() => gameAudioManager.onScoreIncrease(0), returnsNormally);
      expect(() => gameAudioManager.onScoreIncrease(-10), returnsNormally);
    });
  });
}
