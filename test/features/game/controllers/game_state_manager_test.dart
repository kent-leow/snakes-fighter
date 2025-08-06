import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';

void main() {
  group('GameStateManager', () {
    late GameStateManager stateManager;

    setUp(() {
      stateManager = GameStateManager();
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('initialization', () {
      test('should start in menu state', () {
        expect(stateManager.currentState, GameState.menu);
        expect(stateManager.previousState, isNull);
        expect(stateManager.isInMenu, isTrue);
      });

      test('should track state entry time', () {
        expect(stateManager.timeInCurrentState, isA<Duration>());
        expect(
          stateManager.timeInCurrentState.inMilliseconds,
          greaterThanOrEqualTo(0),
        );
      });
    });

    group('state transitions', () {
      test('should transition from menu to playing', () {
        final success = stateManager.transitionTo(GameState.playing);

        expect(success, isTrue);
        expect(stateManager.currentState, GameState.playing);
        expect(stateManager.previousState, GameState.menu);
        expect(stateManager.isPlaying, isTrue);
      });

      test('should not allow invalid transitions', () {
        final success = stateManager.transitionTo(GameState.paused);

        expect(success, isFalse);
        expect(stateManager.currentState, GameState.menu);
      });

      test('should not transition to same state', () {
        final success = stateManager.transitionTo(GameState.menu);

        expect(success, isFalse);
        expect(stateManager.currentState, GameState.menu);
      });

      test('should handle playing to paused transition', () {
        stateManager.transitionTo(GameState.playing);
        final success = stateManager.transitionTo(GameState.paused);

        expect(success, isTrue);
        expect(stateManager.currentState, GameState.paused);
        expect(stateManager.isPaused, isTrue);
      });

      test('should handle paused to playing transition', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        final success = stateManager.transitionTo(GameState.playing);

        expect(success, isTrue);
        expect(stateManager.currentState, GameState.playing);
        expect(stateManager.isPlaying, isTrue);
      });

      test('should handle game over transitions', () {
        stateManager.transitionTo(GameState.playing);
        final success = stateManager.transitionTo(GameState.gameOver);

        expect(success, isTrue);
        expect(stateManager.currentState, GameState.gameOver);
        expect(stateManager.isGameOver, isTrue);
      });

      test('should handle restart transitions', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.gameOver);
        var success = stateManager.transitionTo(GameState.restarting);

        expect(success, isTrue);
        expect(stateManager.currentState, GameState.restarting);
        expect(stateManager.isRestarting, isTrue);

        success = stateManager.transitionTo(GameState.playing);
        expect(success, isTrue);
        expect(stateManager.currentState, GameState.playing);
      });
    });

    group('state properties', () {
      test('should correctly identify active states', () {
        stateManager.transitionTo(GameState.playing);
        expect(stateManager.isActive, isTrue);
        expect(stateManager.isTerminal, isFalse);

        stateManager.transitionTo(GameState.paused);
        expect(stateManager.isActive, isTrue);
        expect(stateManager.isTerminal, isFalse);
      });

      test('should correctly identify terminal states', () {
        expect(stateManager.isTerminal, isTrue); // starts in menu

        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.gameOver);
        expect(stateManager.isTerminal, isTrue);
      });
    });

    group('state history', () {
      test('should track state changes in history', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        stateManager.transitionTo(GameState.playing);

        expect(stateManager.stateHistory.length, 3);
        expect(stateManager.stateHistory[0].from, GameState.menu);
        expect(stateManager.stateHistory[0].to, GameState.playing);
        expect(stateManager.stateHistory[1].from, GameState.playing);
        expect(stateManager.stateHistory[1].to, GameState.paused);
      });

      test('should provide state statistics', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);
        stateManager.transitionTo(GameState.playing);

        final stats = stateManager.getStateStatistics();

        expect(stats['currentState'], 'playing');
        expect(stats['previousState'], 'paused');
        expect(stats['totalTransitions'], 3);
        expect(stats['stateCounts'], isA<Map>());
      });

      test('should limit history size', () {
        // Create many transitions to test history limit
        for (int i = 0; i < 60; i++) {
          stateManager.transitionTo(GameState.playing);
          stateManager.transitionTo(GameState.paused);
        }

        expect(stateManager.stateHistory.length, lessThanOrEqualTo(50));
      });
    });

    group('state validation', () {
      test('should validate all menu transitions', () {
        expect(stateManager.canTransitionTo(GameState.playing), isTrue);
        expect(stateManager.canTransitionTo(GameState.paused), isFalse);
        expect(stateManager.canTransitionTo(GameState.gameOver), isFalse);
        expect(stateManager.canTransitionTo(GameState.restarting), isFalse);
      });

      test('should validate all playing transitions', () {
        stateManager.transitionTo(GameState.playing);

        expect(stateManager.canTransitionTo(GameState.menu), isFalse);
        expect(stateManager.canTransitionTo(GameState.paused), isTrue);
        expect(stateManager.canTransitionTo(GameState.gameOver), isTrue);
        expect(stateManager.canTransitionTo(GameState.restarting), isTrue);
      });

      test('should validate all paused transitions', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);

        expect(stateManager.canTransitionTo(GameState.menu), isTrue);
        expect(stateManager.canTransitionTo(GameState.playing), isTrue);
        expect(stateManager.canTransitionTo(GameState.gameOver), isTrue);
        expect(stateManager.canTransitionTo(GameState.restarting), isTrue);
      });

      test('should validate all game over transitions', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.gameOver);

        expect(stateManager.canTransitionTo(GameState.menu), isTrue);
        expect(stateManager.canTransitionTo(GameState.playing), isFalse);
        expect(stateManager.canTransitionTo(GameState.paused), isFalse);
        expect(stateManager.canTransitionTo(GameState.restarting), isTrue);
      });

      test('should validate all restarting transitions', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.restarting);

        expect(stateManager.canTransitionTo(GameState.menu), isTrue);
        expect(stateManager.canTransitionTo(GameState.playing), isTrue);
        expect(stateManager.canTransitionTo(GameState.paused), isFalse);
        expect(stateManager.canTransitionTo(GameState.gameOver), isFalse);
      });
    });

    group('reset functionality', () {
      test('should reset to initial state', () {
        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);

        stateManager.reset();

        expect(stateManager.currentState, GameState.menu);
        expect(stateManager.previousState, isNull);
        expect(stateManager.stateHistory, isEmpty);
      });
    });

    group('change notifications', () {
      test('should notify listeners on state change', () {
        var notificationCount = 0;
        stateManager.addListener(() {
          notificationCount++;
        });

        stateManager.transitionTo(GameState.playing);
        stateManager.transitionTo(GameState.paused);

        expect(notificationCount, 2);
      });

      test('should not notify on invalid transitions', () {
        var notificationCount = 0;
        stateManager.addListener(() {
          notificationCount++;
        });

        stateManager.transitionTo(GameState.paused); // Invalid from menu

        expect(notificationCount, 0);
      });
    });
  });
}
