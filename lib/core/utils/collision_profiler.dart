import 'dart:math' as math;

import '../../features/game/models/collision.dart';

/// Performance profiler for collision detection operations.
///
/// This class tracks collision detection performance metrics including
/// timing, frequency, and collision statistics for optimization analysis.
class CollisionProfiler {
  /// List of detection times for performance analysis.
  final List<double> _detectionTimes = <double>[];

  /// Count of each collision type encountered.
  final Map<CollisionType, int> _collisionCounts = <CollisionType, int>{};

  /// Total number of collision checks performed.
  int _totalChecks = 0;

  /// Start time for the current profiling session.
  DateTime? _sessionStartTime;

  /// Maximum number of timing samples to keep in memory.
  static const int maxSamples = 1000;

  /// Records a collision result for performance tracking.
  void recordCollision(CollisionResult result) {
    _detectionTimes.add(result.detectionTime);
    _collisionCounts[result.type] = (_collisionCounts[result.type] ?? 0) + 1;
    _totalChecks++;

    // Keep memory usage reasonable by limiting sample size
    if (_detectionTimes.length > maxSamples) {
      _detectionTimes.removeAt(0);
    }

    _sessionStartTime ??= DateTime.now();
  }

  /// Records a detection time without a collision result.
  void recordTotalDetectionTime(double time) {
    _detectionTimes.add(time);
    _totalChecks++;

    if (_detectionTimes.length > maxSamples) {
      _detectionTimes.removeAt(0);
    }

    _sessionStartTime ??= DateTime.now();
  }

  /// Gets the average detection time in milliseconds.
  double get averageDetectionTime {
    if (_detectionTimes.isEmpty) return 0.0;
    return _detectionTimes.reduce((a, b) => a + b) / _detectionTimes.length;
  }

  /// Gets the maximum detection time in milliseconds.
  double get maxDetectionTime {
    if (_detectionTimes.isEmpty) return 0.0;
    return _detectionTimes.reduce(math.max);
  }

  /// Gets the minimum detection time in milliseconds.
  double get minDetectionTime {
    if (_detectionTimes.isEmpty) return 0.0;
    return _detectionTimes.reduce(math.min);
  }

  /// Gets the 95th percentile detection time.
  double get p95DetectionTime {
    if (_detectionTimes.isEmpty) return 0.0;

    final sortedTimes = List<double>.from(_detectionTimes)..sort();
    final index = (sortedTimes.length * 0.95).ceil() - 1;
    return sortedTimes[index.clamp(0, sortedTimes.length - 1)];
  }

  /// Gets the 99th percentile detection time.
  double get p99DetectionTime {
    if (_detectionTimes.isEmpty) return 0.0;

    final sortedTimes = List<double>.from(_detectionTimes)..sort();
    final index = (sortedTimes.length * 0.99).ceil() - 1;
    return sortedTimes[index.clamp(0, sortedTimes.length - 1)];
  }

  /// Gets the standard deviation of detection times.
  double get detectionTimeStdDev {
    if (_detectionTimes.length < 2) return 0.0;

    final mean = averageDetectionTime;
    final variance =
        _detectionTimes
            .map((time) => math.pow(time - mean, 2))
            .reduce((a, b) => a + b) /
        _detectionTimes.length;

    return math.sqrt(variance);
  }

  /// Gets collision statistics by type.
  Map<CollisionType, int> get collisionStats =>
      Map.unmodifiable(_collisionCounts);

  /// Gets the total number of collision checks performed.
  int get totalChecks => _totalChecks;

  /// Gets the number of collision samples recorded.
  int get sampleCount => _detectionTimes.length;

  /// Gets collision rate (collisions per check).
  double get collisionRate {
    if (_totalChecks == 0) return 0.0;
    final totalCollisions = _collisionCounts.values
        .where((count) => count > 0)
        .fold(0, (sum, count) => sum + count);
    return totalCollisions / _totalChecks;
  }

  /// Gets checks per second (if session time is available).
  double get checksPerSecond {
    if (_sessionStartTime == null || _totalChecks == 0) return 0.0;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    final seconds = sessionDuration.inMilliseconds / 1000.0;

    return seconds > 0 ? _totalChecks / seconds : 0.0;
  }

  /// Checks if performance meets the specified requirements.
  bool meetsPerformanceRequirements({
    double maxAverageTime = 0.1, // 0.1ms requirement
    double maxP95Time = 0.2, // 95th percentile
    double maxP99Time = 0.5, // 99th percentile
  }) {
    return averageDetectionTime <= maxAverageTime &&
        p95DetectionTime <= maxP95Time &&
        p99DetectionTime <= maxP99Time;
  }

  /// Gets a detailed performance report.
  Map<String, dynamic> getPerformanceReport() {
    return {
      'timing': {
        'average_ms': averageDetectionTime,
        'min_ms': minDetectionTime,
        'max_ms': maxDetectionTime,
        'p95_ms': p95DetectionTime,
        'p99_ms': p99DetectionTime,
        'std_dev_ms': detectionTimeStdDev,
      },
      'throughput': {
        'total_checks': _totalChecks,
        'sample_count': sampleCount,
        'checks_per_second': checksPerSecond,
        'collision_rate': collisionRate,
      },
      'collisions': Map.fromEntries(
        CollisionType.values.map(
          (type) => MapEntry(type.name, _collisionCounts[type] ?? 0),
        ),
      ),
      'performance': {
        'meets_requirements': meetsPerformanceRequirements(),
        'session_duration_seconds': _sessionStartTime != null
            ? DateTime.now().difference(_sessionStartTime!).inMilliseconds /
                  1000.0
            : 0.0,
      },
    };
  }

  /// Resets all profiling data.
  void reset() {
    _detectionTimes.clear();
    _collisionCounts.clear();
    _totalChecks = 0;
    _sessionStartTime = null;
  }

  /// Gets recent detection times (last N samples).
  List<double> getRecentDetectionTimes([int count = 100]) {
    final startIndex = math.max(0, _detectionTimes.length - count);
    return _detectionTimes.sublist(startIndex);
  }

  /// Checks if the profiler has sufficient data for analysis.
  bool get hasSufficientData => _detectionTimes.length >= 10;

  @override
  String toString() {
    return 'CollisionProfiler('
        'avg: ${averageDetectionTime.toStringAsFixed(3)}ms, '
        'checks: $_totalChecks, '
        'rate: ${(collisionRate * 100).toStringAsFixed(1)}%'
        ')';
  }
}
