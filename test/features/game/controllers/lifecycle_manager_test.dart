import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/controllers/lifecycle_manager.dart';

void main() {
  group('LifecycleManager', () {
    late GameStateManager stateManager;
    late LifecycleManager lifecycleManager;
    late List<LifecycleEvent> capturedEvents;

    setUp(() {
      stateManager = GameStateManager();
      lifecycleManager = LifecycleManager(stateManager: stateManager);
      capturedEvents = [];

      // Register callbacks to capture all events
      for (final event in LifecycleEvent.values) {
        lifecycleManager.registerCallback(event, () {
          capturedEvents.add(event);
        });
      }
    });

    tearDown(() {
      lifecycleManager.dispose();
      stateManager.dispose();
    });

    group('initialization', () {
      test('should start uninitialized', () {
        expect(lifecycleManager.isInitialized, isFalse);
        expect(lifecycleManager.sessionDuration, isNull);
      });

      test('should initialize successfully', () async {
        await lifecycleManager.initialize();

        expect(lifecycleManager.isInitialized, isTrue);
        expect(lifecycleManager.sessionDuration, isA<Duration>());
        expect(capturedEvents, contains(LifecycleEvent.initialize));
      });

      test('should not initialize twice', () async {
        await lifecycleManager.initialize();
        final firstInitTime = lifecycleManager.sessionDuration;

        await lifecycleManager.initialize(); // Second call

        expect(lifecycleManager.isInitialized, isTrue);
        // Should not restart the timer - duration should be close to first time
        final secondInitTime = lifecycleManager.sessionDuration;
        expect(
          secondInitTime!.inMicroseconds - firstInitTime!.inMicroseconds,
          lessThan(1000),
        ); // Within 1ms
      });

      test('should initialize session stats', () async {
        await lifecycleManager.initialize();

        final stats = lifecycleManager.sessionStats;
        expect(stats['gamesPlayed'], 0);
        expect(stats['totalScore'], 0);
        expect(stats['highScore'], 0);
      });
    });

    group('game session management', () {
      setUp(() async {
        await lifecycleManager.initialize();
        capturedEvents.clear(); // Clear initialization events
      });

      test('should start game session', () async {
        await lifecycleManager.startGame();

        expect(stateManager.currentState, GameState.playing);
        expect(capturedEvents, contains(LifecycleEvent.preStart));
        expect(capturedEvents, contains(LifecycleEvent.postStart));
        expect(lifecycleManager.sessionStats['gamesPlayed'], 1);
      });

      test('should not start if not initialized', () async {
        final uninitializedManager = LifecycleManager(
          stateManager: GameStateManager(),
        );

        expect(
          () => uninitializedManager.startGame(),
          throwsA(isA<StateError>()),
        );

        uninitializedManager.dispose();
      });

      test('should pause game session', () async {
        await lifecycleManager.startGame();
        capturedEvents.clear();

        await lifecycleManager.pauseGame();

        expect(stateManager.currentState, GameState.paused);
        expect(capturedEvents, contains(LifecycleEvent.prePause));
        expect(capturedEvents, contains(LifecycleEvent.postPause));
      });

      test('should not pause if not playing', () async {
        await lifecycleManager.pauseGame(); // Not playing

        expect(stateManager.currentState, GameState.menu);
        expect(capturedEvents, isEmpty);
      });

      test('should resume game session', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.pauseGame();
        capturedEvents.clear();

        await lifecycleManager.resumeGame();

        expect(stateManager.currentState, GameState.playing);
        expect(capturedEvents, contains(LifecycleEvent.preResume));
        expect(capturedEvents, contains(LifecycleEvent.postResume));
      });

      test('should not resume if not paused', () async {
        await lifecycleManager.resumeGame(); // Not paused

        expect(stateManager.currentState, GameState.menu);
        expect(capturedEvents, isEmpty);
      });

      test('should end game session', () async {
        await lifecycleManager.startGame();
        capturedEvents.clear();

        await lifecycleManager.endGame(finalScore: 150);

        expect(stateManager.currentState, GameState.gameOver);
        expect(capturedEvents, contains(LifecycleEvent.preEnd));
        expect(capturedEvents, contains(LifecycleEvent.postEnd));
        expect(lifecycleManager.sessionStats['totalScore'], 150);
        expect(lifecycleManager.sessionStats['highScore'], 150);
      });

      test('should not end if already ended', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.endGame();
        capturedEvents.clear();

        await lifecycleManager.endGame(); // Already ended

        expect(stateManager.currentState, GameState.gameOver);
        expect(capturedEvents, isEmpty);
      });

      test('should restart game session', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.endGame();
        capturedEvents.clear();

        await lifecycleManager.restartGame();

        expect(stateManager.currentState, GameState.playing);
        expect(capturedEvents, contains(LifecycleEvent.preRestart));
        expect(capturedEvents, contains(LifecycleEvent.cleanup));
        expect(capturedEvents, contains(LifecycleEvent.postRestart));
        expect(lifecycleManager.sessionStats['gamesPlayed'], 2);
      });

      test('should return to menu', () async {
        await lifecycleManager.startGame();
        capturedEvents.clear();

        await lifecycleManager.returnToMenu();

        expect(stateManager.currentState, GameState.menu);
        expect(capturedEvents, contains(LifecycleEvent.preMenu));
        expect(capturedEvents, contains(LifecycleEvent.cleanup));
        expect(capturedEvents, contains(LifecycleEvent.postMenu));
      });
    });

    group('score tracking', () {
      setUp(() async {
        await lifecycleManager.initialize();
      });

      test('should track total score across games', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.endGame(finalScore: 100);

        await lifecycleManager.restartGame();
        await lifecycleManager.endGame(finalScore: 150);

        expect(lifecycleManager.sessionStats['totalScore'], 250);
        expect(lifecycleManager.sessionStats['gamesPlayed'], 2);
      });

      test('should track high score', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.endGame(finalScore: 100);

        await lifecycleManager.restartGame();
        await lifecycleManager.endGame(finalScore: 80);

        await lifecycleManager.restartGame();
        await lifecycleManager.endGame(finalScore: 150);

        expect(lifecycleManager.sessionStats['highScore'], 150);
      });

      test('should handle null scores', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.endGame(); // No score provided

        expect(lifecycleManager.sessionStats['totalScore'], 0);
        expect(lifecycleManager.sessionStats['highScore'], 0);
      });
    });

    group('callback management', () {
      test('should register and trigger callbacks', () async {
        var callbackTriggered = false;
        lifecycleManager.registerCallback(LifecycleEvent.postStart, () {
          callbackTriggered = true;
        });

        await lifecycleManager.initialize();
        await lifecycleManager.startGame();

        expect(callbackTriggered, isTrue);
      });

      test('should unregister callbacks', () async {
        var callbackTriggered = false;
        void callback() {
          callbackTriggered = true;
        }

        lifecycleManager.registerCallback(LifecycleEvent.postStart, callback);
        lifecycleManager.unregisterCallback(LifecycleEvent.postStart, callback);

        await lifecycleManager.initialize();
        await lifecycleManager.startGame();

        expect(callbackTriggered, isFalse);
      });

      test('should clear all callbacks for an event', () async {
        var callback1Triggered = false;
        var callback2Triggered = false;

        lifecycleManager.registerCallback(LifecycleEvent.postStart, () {
          callback1Triggered = true;
        });
        lifecycleManager.registerCallback(LifecycleEvent.postStart, () {
          callback2Triggered = true;
        });

        lifecycleManager.clearCallbacks(LifecycleEvent.postStart);

        await lifecycleManager.initialize();
        await lifecycleManager.startGame();

        expect(callback1Triggered, isFalse);
        expect(callback2Triggered, isFalse);
      });

      test('should handle callback errors gracefully', () async {
        lifecycleManager.registerCallback(LifecycleEvent.postStart, () {
          throw Exception('Callback error');
        });

        await lifecycleManager.initialize();

        // Should not throw despite callback error
        expect(() => lifecycleManager.startGame(), returnsNormally);
      });
    });

    group('statistics and monitoring', () {
      setUp(() async {
        await lifecycleManager.initialize();
      });

      test('should provide lifecycle statistics', () async {
        await lifecycleManager.startGame();
        await lifecycleManager.pauseGame();

        final stats = lifecycleManager.getLifecycleStats();

        expect(stats['isInitialized'], isTrue);
        expect(stats['currentState'], 'paused');
        expect(stats['sessionDuration'], isA<int>());
        expect(stats['sessionStats'], isA<Map>());
        expect(stats['stateStats'], isA<Map>());
      });

      test('should track session duration', () async {
        await Future.delayed(const Duration(milliseconds: 10));

        final duration = lifecycleManager.sessionDuration;
        expect(duration, isNotNull);
        expect(duration!.inMilliseconds, greaterThan(0));
      });
    });

    group('error handling', () {
      test('should handle invalid state transitions gracefully', () async {
        await lifecycleManager.initialize();

        // Try to restart without being in a valid state
        expect(
          () => lifecycleManager.restartGame(),
          throwsA(isA<StateError>()),
        );
      });

      test('should handle state manager errors', () async {
        // Create a scenario where state transition fails
        final restrictiveStateManager = GameStateManager();
        final restrictiveLifecycleManager = LifecycleManager(
          stateManager: restrictiveStateManager,
        );

        await restrictiveLifecycleManager.initialize();

        // Try to pause without playing (should fail)
        expect(
          () => restrictiveLifecycleManager.pauseGame(),
          returnsNormally, // Should handle gracefully
        );

        restrictiveLifecycleManager.dispose();
        restrictiveStateManager.dispose();
      });
    });

    group('disposal', () {
      test('should dispose cleanly', () async {
        await lifecycleManager.initialize();
        await lifecycleManager.startGame();

        lifecycleManager.dispose();

        expect(lifecycleManager.isInitialized, isFalse);
        expect(lifecycleManager.sessionStats, isEmpty);
        expect(capturedEvents, contains(LifecycleEvent.dispose));
      });

      test('should handle multiple dispose calls', () {
        lifecycleManager.dispose();

        expect(() => lifecycleManager.dispose(), returnsNormally);
      });
    });

    group('state change notifications', () {
      test('should notify listeners on lifecycle changes', () async {
        var notificationCount = 0;
        lifecycleManager.addListener(() {
          notificationCount++;
        });

        await lifecycleManager.initialize();
        await lifecycleManager.startGame();
        await lifecycleManager.pauseGame();

        expect(notificationCount, greaterThan(0));
      });
    });

    group('string representation', () {
      test('should provide meaningful toString', () async {
        await lifecycleManager.initialize();
        await lifecycleManager.startGame();

        final str = lifecycleManager.toString();

        expect(str, contains('LifecycleManager'));
        expect(str, contains('initialized: true'));
        expect(str, contains('playing'));
      });
    });
  });
}
