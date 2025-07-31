import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Monitors game performance including FPS, memory usage, and system metrics.
///
/// This class provides comprehensive performance tracking to ensure
/// the game meets performance requirements and identifies bottlenecks.
class PerformanceMonitor {
  /// Performance metrics tracking.
  final Map<String, List<double>> _metrics = {};
  
  /// Current frame time samples.
  final List<Duration> _frameTimes = [];
  
  /// Memory usage samples.
  final List<int> _memoryUsage = [];
  
  /// Whether monitoring is currently active.
  bool _isMonitoring = false;
  
  /// Timer for periodic metrics collection.
  Timer? _metricsTimer;
  
  /// Start time for current monitoring session.
  DateTime? _monitoringStartTime;
  
  /// Maximum samples to keep in memory.
  static const int _maxSamples = 300; // 5 minutes at 1Hz
  
  /// Performance thresholds.
  static const double _targetFps = 60.0;
  static const double _minAcceptableFps = 55.0;
  static const int _maxMemoryUsageMB = 100;
  static const double _maxFrameTimeMs = 20.0; // ~50fps

  /// Gets whether monitoring is currently active.
  bool get isMonitoring => _isMonitoring;
  
  /// Gets the monitoring duration.
  Duration? get monitoringDuration {
    if (_monitoringStartTime == null) return null;
    return DateTime.now().difference(_monitoringStartTime!);
  }

  /// Starts performance monitoring.
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringStartTime = DateTime.now();
    
    // Clear previous data
    _clearMetrics();
    
    // Start periodic metrics collection
    _metricsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _collectSystemMetrics(),
    );
    
    debugPrint('Performance monitoring started');
  }

  /// Stops performance monitoring.
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _metricsTimer?.cancel();
    _metricsTimer = null;
    
    debugPrint('Performance monitoring stopped');
  }

  /// Records a frame time for FPS calculation.
  void recordFrameTime(Duration frameTime) {
    if (!_isMonitoring) return;
    
    _frameTimes.add(frameTime);
    
    // Keep only recent frame times
    if (_frameTimes.length > _maxSamples) {
      _frameTimes.removeAt(0);
    }
  }

  /// Records memory usage.
  void recordMemoryUsage(int memoryMB) {
    if (!_isMonitoring) return;
    
    _memoryUsage.add(memoryMB);
    
    // Keep only recent memory samples
    if (_memoryUsage.length > _maxSamples) {
      _memoryUsage.removeAt(0);
    }
  }

  /// Records a custom metric value.
  void recordMetric(String name, double value) {
    if (!_isMonitoring) return;
    
    _metrics.putIfAbsent(name, () => []).add(value);
    
    // Keep metrics size manageable
    final metricList = _metrics[name]!;
    if (metricList.length > _maxSamples) {
      metricList.removeAt(0);
    }
  }

  /// Gets the current FPS based on recent frame times.
  double getCurrentFps() {
    if (_frameTimes.isEmpty) return 0.0;
    
    // Calculate average frame time from recent samples
    final recentSamples = _frameTimes.length > 60
        ? _frameTimes.sublist(_frameTimes.length - 60)
        : _frameTimes;
    
    final totalMicroseconds = recentSamples
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    final averageMicroseconds = totalMicroseconds / recentSamples.length;
    
    // Handle zero frame time to avoid division by zero
    if (averageMicroseconds <= 0) return 0.0;
    
    return 1000000.0 / averageMicroseconds;
  }

  /// Gets the current memory usage in MB.
  int getCurrentMemoryUsage() {
    if (_memoryUsage.isEmpty) return 0;
    return _memoryUsage.last;
  }

  /// Gets the average frame time in milliseconds.
  double getAverageFrameTime() {
    if (_frameTimes.isEmpty) return 0.0;
    
    final totalMicroseconds = _frameTimes
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    return (totalMicroseconds / _frameTimes.length) / 1000.0;
  }

  /// Gets the peak memory usage in MB.
  int getPeakMemoryUsage() {
    if (_memoryUsage.isEmpty) return 0;
    return _memoryUsage.reduce((a, b) => a > b ? a : b);
  }

  /// Gets statistics for a custom metric.
  Map<String, double> getMetricStats(String name) {
    final values = _metrics[name];
    if (values == null || values.isEmpty) {
      return {
        'min': 0.0,
        'max': 0.0,
        'average': 0.0,
        'latest': 0.0,
        'count': 0.0,
      };
    }
    
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final average = values.reduce((a, b) => a + b) / values.length;
    final latest = values.last;
    
    return {
      'min': min,
      'max': max,
      'average': average,
      'latest': latest,
      'count': values.length.toDouble(),
    };
  }

  /// Checks if the game is meeting performance requirements.
  bool meetsPerformanceRequirements() {
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    final avgFrameTime = getAverageFrameTime();
    
    return fps >= _minAcceptableFps &&
           memoryMB <= _maxMemoryUsageMB &&
           avgFrameTime <= _maxFrameTimeMs;
  }

  /// Gets a comprehensive performance report.
  Map<String, dynamic> getPerformanceReport() {
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    final peakMemoryMB = getPeakMemoryUsage();
    final avgFrameTime = getAverageFrameTime();
    
    return {
      'isMonitoring': _isMonitoring,
      'monitoringDuration': monitoringDuration?.inSeconds,
      'fps': {
        'current': fps,
        'target': _targetFps,
        'minimum': _minAcceptableFps,
        'isAcceptable': fps >= _minAcceptableFps,
      },
      'memory': {
        'currentMB': memoryMB,
        'peakMB': peakMemoryMB,
        'limitMB': _maxMemoryUsageMB,
        'isAcceptable': memoryMB <= _maxMemoryUsageMB,
      },
      'frameTime': {
        'averageMs': avgFrameTime,
        'maxAcceptableMs': _maxFrameTimeMs,
        'isAcceptable': avgFrameTime <= _maxFrameTimeMs,
      },
      'overallPerformance': {
        'meetsRequirements': meetsPerformanceRequirements(),
        'sampleCount': _frameTimes.length,
      },
      'customMetrics': _metrics.keys.map((name) => {
        'name': name,
        'stats': getMetricStats(name),
      }).toList(),
    };
  }

  /// Gets performance warnings based on current metrics.
  List<String> getPerformanceWarnings() {
    final warnings = <String>[];
    
    final fps = getCurrentFps();
    if (fps < _minAcceptableFps && fps > 0) {
      warnings.add('FPS below acceptable threshold: ${fps.toStringAsFixed(1)} < $_minAcceptableFps');
    }
    
    final memoryMB = getCurrentMemoryUsage();
    if (memoryMB > _maxMemoryUsageMB) {
      warnings.add('Memory usage above limit: ${memoryMB}MB > ${_maxMemoryUsageMB}MB');
    }
    
    final avgFrameTime = getAverageFrameTime();
    if (avgFrameTime > _maxFrameTimeMs) {
      warnings.add('Frame time above limit: ${avgFrameTime.toStringAsFixed(1)}ms > ${_maxFrameTimeMs}ms');
    }
    
    // Check for frame time spikes
    if (_frameTimes.isNotEmpty) {
      final maxFrameTime = _frameTimes
          .map((d) => d.inMicroseconds / 1000.0)
          .reduce((a, b) => a > b ? a : b);
      
      if (maxFrameTime > _maxFrameTimeMs * 3) {
        warnings.add('Frame time spike detected: ${maxFrameTime.toStringAsFixed(1)}ms');
      }
    }
    
    return warnings;
  }

  /// Collects system-level performance metrics.
  void _collectSystemMetrics() {
    try {
      // Collect memory usage (platform-specific)
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile platforms, we would use platform channels to get memory info
        // For now, we'll simulate with process memory
        final processInfo = ProcessInfo.currentRss;
        recordMemoryUsage((processInfo / (1024 * 1024)).round());
      }
    } catch (error) {
      debugPrint('Error collecting system metrics: $error');
    }
  }

  /// Clears all performance metrics.
  void _clearMetrics() {
    _frameTimes.clear();
    _memoryUsage.clear();
    _metrics.clear();
  }

  /// Exports performance data for analysis.
  Map<String, dynamic> exportPerformanceData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'monitoringDuration': monitoringDuration?.inSeconds,
      'frameTimes': _frameTimes.map((d) => d.inMicroseconds).toList(),
      'memoryUsage': List.from(_memoryUsage),
      'customMetrics': Map.from(_metrics),
      'performanceReport': getPerformanceReport(),
      'warnings': getPerformanceWarnings(),
    };
  }

  /// Resets all performance data.
  void reset() {
    stopMonitoring();
    _clearMetrics();
    _monitoringStartTime = null;
    
    debugPrint('Performance monitor reset');
  }

  /// Disposes of the performance monitor.
  void dispose() {
    stopMonitoring();
    _clearMetrics();
    
    debugPrint('Performance monitor disposed');
  }

  @override
  String toString() {
    if (!_isMonitoring) return 'PerformanceMonitor(stopped)';
    
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    
    return 'PerformanceMonitor('
        'fps: ${fps.toStringAsFixed(1)}, '
        'memory: ${memoryMB}MB, '
        'samples: ${_frameTimes.length}'
        ')';
  }
}
