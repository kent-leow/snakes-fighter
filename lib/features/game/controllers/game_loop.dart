import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// A custom ticker provider for the game loop.
class _GameLoopTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'GameLoop');
  }
}

/// Handles the main game loop using Flutter's Ticker for consistent timing.
///
/// This class manages the game loop execution, providing 60fps updates
/// and proper frame timing for smooth gameplay.
class GameLoop {
  /// The ticker provider for creating tickers.
  final TickerProvider _tickerProvider = _GameLoopTickerProvider();

  /// The ticker that drives the game loop.
  Ticker? _ticker;

  /// Callback function to execute on each frame.
  final void Function(Duration elapsed) _onTick;

  /// Whether the game loop is currently running.
  bool _isRunning = false;

  /// Time when the loop was last paused.
  DateTime? _pauseTime;

  /// Total elapsed time in the current session.
  Duration _totalElapsed = Duration.zero;

  /// Performance metrics.
  final List<Duration> _frameTimes = [];
  static const int _maxFrameHistory = 60; // Keep 1 second of frame data

  /// Target frame rate (60 FPS).
  static const Duration _targetFrameTime = Duration(microseconds: 16667);

  /// Creates a new game loop with the specified tick callback.
  GameLoop({required void Function(Duration elapsed) onTick})
    : _onTick = onTick;

  /// Gets whether the game loop is currently running.
  bool get isRunning => _isRunning;

  /// Gets the total elapsed time since the loop started.
  Duration get totalElapsed => _totalElapsed;

  /// Gets the average frame time over recent frames.
  Duration get averageFrameTime {
    if (_frameTimes.isEmpty) return Duration.zero;

    final totalMicros = _frameTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicros ~/ _frameTimes.length);
  }

  /// Gets the current FPS based on recent frame times.
  double get fps {
    final avgFrameTime = averageFrameTime;
    if (avgFrameTime == Duration.zero) return 0.0;

    return 1000000.0 / avgFrameTime.inMicroseconds;
  }

  /// Gets whether the game loop is maintaining target performance.
  bool get isPerformant => fps >= 55.0; // Allow 5fps variance

  /// Starts the game loop.
  ///
  /// Creates a new ticker and begins frame callbacks.
  void start() {
    if (_isRunning) return;

    _isRunning = true;

    _ticker = _tickerProvider.createTicker(_tick);
    _ticker!.start();

    debugPrint('Game loop started');
  }

  /// Stops the game loop.
  ///
  /// Disposes of the ticker and resets timing.
  void stop() {
    if (!_isRunning) return;

    _ticker?.dispose();
    _ticker = null;
    _isRunning = false;
    _pauseTime = null;

    debugPrint('Game loop stopped');
  }

  /// Pauses the game loop.
  ///
  /// Stops the ticker but preserves state for resuming.
  void pause() {
    if (!_isRunning || _ticker == null) return;

    _pauseTime = DateTime.now();
    _ticker!.stop();

    debugPrint('Game loop paused');
  }

  /// Resumes the game loop from pause.
  ///
  /// Restarts the ticker and adjusts timing for the pause duration.
  void resume() {
    if (!_isRunning || _ticker == null || _pauseTime == null) return;

    _ticker!.start();
    _pauseTime = null;

    debugPrint('Game loop resumed');
  }

  /// Internal tick callback that handles frame timing and performance tracking.
  void _tick(Duration elapsed) {
    if (!_isRunning) return;

    final frameStart = DateTime.now();

    // Update total elapsed time
    _totalElapsed = elapsed;

    // Execute the game tick callback
    try {
      _onTick(elapsed);
    } catch (error, stackTrace) {
      debugPrint('Error in game tick: $error');
      debugPrint('Stack trace: $stackTrace');
      // Continue running despite errors
    }

    // Track frame performance
    _trackFramePerformance(frameStart);
  }

  /// Tracks frame performance metrics.
  void _trackFramePerformance(DateTime frameStart) {
    final frameEnd = DateTime.now();
    final frameTime = frameEnd.difference(frameStart);

    // Add to frame time history
    _frameTimes.add(frameTime);

    // Keep history size manageable
    if (_frameTimes.length > _maxFrameHistory) {
      _frameTimes.removeAt(0);
    }

    // Log performance warnings
    if (frameTime > _targetFrameTime * 2) {
      debugPrint(
        'Frame took ${frameTime.inMilliseconds}ms (target: ${_targetFrameTime.inMilliseconds}ms)',
      );
    }
  }

  /// Gets performance statistics for monitoring.
  Map<String, dynamic> getPerformanceStats() {
    return {
      'isRunning': _isRunning,
      'totalElapsed': _totalElapsed.inMilliseconds,
      'averageFrameTime': averageFrameTime.inMilliseconds,
      'fps': fps,
      'isPerformant': isPerformant,
      'frameCount': _frameTimes.length,
      'targetFrameTime': _targetFrameTime.inMilliseconds,
    };
  }

  /// Resets performance metrics.
  void resetPerformanceMetrics() {
    _frameTimes.clear();
    _totalElapsed = Duration.zero;
    _pauseTime = null;
  }

  /// Disposes of the game loop and cleans up resources.
  void dispose() {
    stop();
    _frameTimes.clear();
    debugPrint('Game loop disposed');
  }

  @override
  String toString() {
    return 'GameLoop(running: $_isRunning, fps: ${fps.toStringAsFixed(1)})';
  }
}
