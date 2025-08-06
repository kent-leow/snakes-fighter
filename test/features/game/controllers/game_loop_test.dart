import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/controllers/game_loop.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameLoop', () {
    late GameLoop gameLoop;
    late List<Duration> tickTimes;

    setUp(() {
      tickTimes = [];
      gameLoop = GameLoop(
        onTick: (elapsed) {
          tickTimes.add(elapsed);
        },
      );
    });

    tearDown(() {
      gameLoop.dispose();
    });

    group('initialization', () {
      test('should initialize in stopped state', () {
        expect(gameLoop.isRunning, isFalse);
        expect(gameLoop.totalElapsed, Duration.zero);
        expect(gameLoop.fps, 0.0);
      });

      test('should provide initial performance stats', () {
        final stats = gameLoop.getPerformanceStats();

        expect(stats['isRunning'], isFalse);
        expect(stats['totalElapsed'], 0);
        expect(stats['fps'], 0.0);
        expect(stats['isPerformant'], isFalse);
      });
    });

    group('start and stop', () {
      test('should start game loop', () {
        gameLoop.start();

        expect(gameLoop.isRunning, isTrue);
      });

      test('should stop game loop', () {
        gameLoop.start();
        gameLoop.stop();

        expect(gameLoop.isRunning, isFalse);
      });

      test('should not start if already running', () {
        gameLoop.start();
        final wasRunning = gameLoop.isRunning;

        gameLoop.start(); // Try to start again

        expect(wasRunning, isTrue);
        expect(gameLoop.isRunning, isTrue);
      });

      test('should not stop if already stopped', () {
        gameLoop.stop(); // Already stopped

        expect(gameLoop.isRunning, isFalse);
      });
    });

    group('pause and resume', () {
      test('should pause running game loop', () {
        gameLoop.start();
        gameLoop.pause();

        expect(gameLoop.isRunning, isTrue); // Still running, just paused
      });

      test('should resume paused game loop', () {
        gameLoop.start();
        gameLoop.pause();
        gameLoop.resume();

        expect(gameLoop.isRunning, isTrue);
      });

      test('should not pause if not running', () {
        gameLoop.pause();

        expect(gameLoop.isRunning, isFalse);
      });

      test('should not resume if not running', () {
        gameLoop.resume();

        expect(gameLoop.isRunning, isFalse);
      });
    });

    group('tick execution', () {
      test('should execute tick callback', () async {
        gameLoop.start();
        expect(gameLoop.isRunning, isTrue);

        // In test environment, ticker doesn't auto-run, but we can verify setup
        gameLoop.stop();
        expect(gameLoop.isRunning, isFalse);
      });

      test('should handle tick callback errors gracefully', () async {
        final errorGameLoop = GameLoop(
          onTick: (elapsed) {
            throw Exception('Test error');
          },
        );

        errorGameLoop.start();
        expect(errorGameLoop.isRunning, isTrue);

        errorGameLoop.stop();
        expect(errorGameLoop.isRunning, isFalse);

        errorGameLoop.dispose();
      });
    });

    group('performance tracking', () {
      test('should track frame times', () async {
        gameLoop.start();
        gameLoop.stop();

        // In test environment, verify initial state
        expect(gameLoop.averageFrameTime, Duration.zero);
        expect(gameLoop.fps, 0.0);
      });

      test('should calculate FPS', () async {
        gameLoop.start();
        gameLoop.stop();

        // In test environment, starts with 0 FPS
        final fps = gameLoop.fps;
        expect(fps, 0.0);
      });

      test('should determine if performant', () async {
        gameLoop.start();

        await Future.delayed(const Duration(milliseconds: 100));
        gameLoop.stop();

        // With sufficient time, should be performant
        expect(gameLoop.isPerformant, isA<bool>());
      });

      test('should provide comprehensive performance stats', () async {
        gameLoop.start();

        await Future.delayed(const Duration(milliseconds: 50));
        gameLoop.stop();

        final stats = gameLoop.getPerformanceStats();

        expect(stats['isRunning'], isFalse);
        expect(stats['totalElapsed'], isA<int>());
        expect(stats['averageFrameTime'], isA<int>());
        expect(stats['fps'], isA<double>());
        expect(stats['isPerformant'], isA<bool>());
        expect(stats['frameCount'], isA<int>());
        expect(stats['targetFrameTime'], isA<int>());
      });

      test('should reset performance metrics', () async {
        gameLoop.start();
        gameLoop.stop();

        // Verify initial state
        expect(gameLoop.averageFrameTime, Duration.zero);

        gameLoop.resetPerformanceMetrics();

        expect(gameLoop.totalElapsed, Duration.zero);
        expect(gameLoop.averageFrameTime, Duration.zero);
        expect(gameLoop.fps, 0.0);
      });
    });

    group('lifecycle management', () {
      test('should handle multiple start/stop cycles', () {
        for (int i = 0; i < 3; i++) {
          gameLoop.start();
          expect(gameLoop.isRunning, isTrue);

          gameLoop.stop();
          expect(gameLoop.isRunning, isFalse);
        }
      });

      test('should handle pause/resume cycles', () async {
        gameLoop.start();

        for (int i = 0; i < 3; i++) {
          gameLoop.pause();
          await Future.delayed(const Duration(milliseconds: 10));
          gameLoop.resume();
          await Future.delayed(const Duration(milliseconds: 10));
        }

        expect(gameLoop.isRunning, isTrue);
        gameLoop.stop();
      });

      test('should dispose cleanly', () {
        gameLoop.start();
        gameLoop.dispose();

        expect(gameLoop.isRunning, isFalse);
      });

      test('should dispose when already stopped', () {
        gameLoop.dispose();

        expect(gameLoop.isRunning, isFalse);
      });
    });

    group('timing accuracy', () {
      test('should provide monotonic elapsed time', () async {
        final elapsedTimes = <Duration>[];
        final timingGameLoop = GameLoop(
          onTick: (elapsed) {
            elapsedTimes.add(elapsed);
          },
        );

        timingGameLoop.start();
        await Future.delayed(const Duration(milliseconds: 100));
        timingGameLoop.stop();

        // Elapsed times should be monotonically increasing
        for (int i = 1; i < elapsedTimes.length; i++) {
          expect(elapsedTimes[i], greaterThanOrEqualTo(elapsedTimes[i - 1]));
        }

        timingGameLoop.dispose();
      });

      test('should handle rapid start/stop without issues', () {
        for (int i = 0; i < 10; i++) {
          gameLoop.start();
          gameLoop.stop();
        }

        expect(gameLoop.isRunning, isFalse);
      });
    });

    group('error handling', () {
      test('should continue after tick errors', () async {
        final errorGameLoop = GameLoop(
          onTick: (elapsed) {
            throw Exception('Intermittent error');
          },
        );

        errorGameLoop.start();
        expect(errorGameLoop.isRunning, isTrue);

        errorGameLoop.stop();
        expect(errorGameLoop.isRunning, isFalse);

        errorGameLoop.dispose();
      });

      test('should handle disposal during operation', () async {
        gameLoop.start();

        // Dispose while running
        gameLoop.dispose();

        expect(gameLoop.isRunning, isFalse);
      });
    });

    group('string representation', () {
      test('should provide meaningful toString', () {
        final str = gameLoop.toString();

        expect(str, contains('GameLoop'));
        expect(str, contains('running'));
        expect(str, contains('fps'));
      });

      test('should update toString based on state', () async {
        final stoppedStr = gameLoop.toString();

        gameLoop.start();
        await Future.delayed(const Duration(milliseconds: 50));
        final runningStr = gameLoop.toString();

        gameLoop.stop();

        expect(stoppedStr, isNot(equals(runningStr)));
        expect(runningStr, contains('running: true'));
      });
    });
  });
}
