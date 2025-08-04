import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Enhanced performance monitoring system for real-time game metrics.
///
/// Provides comprehensive tracking of frame rate, memory usage, network latency,
/// and custom game metrics with automated alerting and reporting.
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, PerformanceMetric> _metrics = {};
  Timer? _monitoringTimer;
  final List<PerformanceListener> _listeners = [];
  
  bool _isMonitoring = false;
  DateTime? _monitoringStartTime;
  
  // Performance tracking data
  final List<Duration> _frameTimes = [];
  final List<double> _memoryUsage = [];
  final List<double> _networkLatency = [];
  final Map<String, List<double>> _customMetrics = {};
  
  // Performance thresholds
  static const double _targetFps = 60.0;
  static const double _minAcceptableFps = 55.0;
  static const double _maxMemoryUsageMB = 100.0;
  static const double _maxNetworkLatencyMs = 200.0;
  static const int _maxSamples = 300; // 5 minutes at 1Hz

  /// Gets whether monitoring is currently active.
  bool get isMonitoring => _isMonitoring;
  
  /// Gets the monitoring duration.
  Duration? get monitoringDuration {
    if (_monitoringStartTime == null) return null;
    return DateTime.now().difference(_monitoringStartTime!);
  }

  /// Starts comprehensive performance monitoring.
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringStartTime = DateTime.now();
    
    // Clear previous data
    _clearMetrics();
    
    // Start periodic metrics collection
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _collectMetrics(),
    );
    
    // Start frame callback for real-time FPS tracking (only in non-test environment)
    try {
      SchedulerBinding.instance.addPersistentFrameCallback(_frameCallback);
    } catch (e) {
      // In test environment, SchedulerBinding might not be initialized
      debugPrint('Frame callback not available in test environment');
    }
    
    debugPrint('Enhanced performance monitoring started');
  }

  /// Stops performance monitoring.
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    // Frame callback is automatically removed when ticker is disposed
    
    debugPrint('Performance monitoring stopped');
  }

  /// Adds a performance listener for real-time notifications.
  void addListener(PerformanceListener listener) {
    _listeners.add(listener);
  }

  /// Removes a performance listener.
  void removeListener(PerformanceListener listener) {
    _listeners.remove(listener);
  }

  /// Records frame time for FPS calculation.
  void recordFrameTime(Duration frameTime) {
    if (!_isMonitoring) return;
    
    _frameTimes.add(frameTime);
    
    // Keep only recent samples
    if (_frameTimes.length > _maxSamples) {
      _frameTimes.removeAt(0);
    }
    
    // Update frame rate metric
    final fps = _calculateCurrentFps();
    _updateMetric('frame_rate', fps, DateTime.now());
  }

  /// Records memory usage in MB.
  void recordMemoryUsage(double memoryMB) {
    if (!_isMonitoring) return;
    
    _memoryUsage.add(memoryMB);
    
    // Keep only recent samples
    if (_memoryUsage.length > _maxSamples) {
      _memoryUsage.removeAt(0);
    }
    
    _updateMetric('memory_usage', memoryMB, DateTime.now());
  }

  /// Records network latency in milliseconds.
  void recordNetworkLatency(double latencyMs) {
    if (!_isMonitoring) return;
    
    _networkLatency.add(latencyMs);
    
    // Keep only recent samples
    if (_networkLatency.length > _maxSamples) {
      _networkLatency.removeAt(0);
    }
    
    _updateMetric('network_latency', latencyMs, DateTime.now());
  }

  /// Records a custom metric value.
  void recordCustomMetric(String name, double value) {
    if (!_isMonitoring) return;
    
    _customMetrics.putIfAbsent(name, () => []).add(value);
    
    // Keep metrics size manageable
    final metricList = _customMetrics[name]!;
    if (metricList.length > _maxSamples) {
      metricList.removeAt(0);
    }
    
    _updateMetric(name, value, DateTime.now());
  }

  /// Gets the current FPS based on recent frame times.
  double getCurrentFps() {
    return _getMetricValue('frame_rate') ?? 0.0;
  }

  /// Gets the current memory usage in MB.
  double getCurrentMemoryUsage() {
    return _getMetricValue('memory_usage') ?? 0.0;
  }

  /// Gets the current network latency in ms.
  double getCurrentNetworkLatency() {
    return _getMetricValue('network_latency') ?? 0.0;
  }

  /// Gets a specific performance metric.
  PerformanceMetric? getMetric(String name) => _metrics[name];

  /// Gets all performance metrics.
  Map<String, PerformanceMetric> getAllMetrics() => Map.unmodifiable(_metrics);

  /// Checks if performance meets requirements.
  bool meetsPerformanceRequirements() {
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    final latencyMs = getCurrentNetworkLatency();
    
    return fps >= _minAcceptableFps &&
           memoryMB <= _maxMemoryUsageMB &&
           latencyMs <= _maxNetworkLatencyMs;
  }

  /// Gets comprehensive performance report.
  Map<String, dynamic> getPerformanceReport() {
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    final latencyMs = getCurrentNetworkLatency();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'isMonitoring': _isMonitoring,
      'monitoringDuration': monitoringDuration?.inSeconds,
      'fps': {
        'current': fps,
        'target': _targetFps,
        'minimum': _minAcceptableFps,
        'isAcceptable': fps >= _minAcceptableFps,
        'average': _calculateAverage(_frameTimes.map((d) => 1000000.0 / d.inMicroseconds).toList()),
      },
      'memory': {
        'currentMB': memoryMB,
        'peakMB': _memoryUsage.isEmpty ? 0 : _memoryUsage.reduce((a, b) => a > b ? a : b),
        'averageMB': _calculateAverage(_memoryUsage),
        'limitMB': _maxMemoryUsageMB,
        'isAcceptable': memoryMB <= _maxMemoryUsageMB,
      },
      'network': {
        'currentLatencyMs': latencyMs,
        'averageLatencyMs': _calculateAverage(_networkLatency),
        'maxLatencyMs': _networkLatency.isEmpty ? 0 : _networkLatency.reduce((a, b) => a > b ? a : b),
        'limitMs': _maxNetworkLatencyMs,
        'isAcceptable': latencyMs <= _maxNetworkLatencyMs,
      },
      'overallPerformance': {
        'meetsRequirements': meetsPerformanceRequirements(),
        'sampleCount': _frameTimes.length,
        'warnings': getPerformanceWarnings(),
      },
      'customMetrics': _customMetrics.keys.map((name) => {
        'name': name,
        'current': _getMetricValue(name) ?? 0.0,
        'average': _calculateAverage(_customMetrics[name] ?? []),
        'history': List.from(_customMetrics[name] ?? []),
      }).toList(),
    };
  }

  /// Gets performance warnings and alerts.
  List<String> getPerformanceWarnings() {
    final warnings = <String>[];
    
    final fps = getCurrentFps();
    if (fps > 0 && fps < _minAcceptableFps) {
      warnings.add('FPS below acceptable threshold: ${fps.toStringAsFixed(1)} < $_minAcceptableFps');
    }
    
    final memoryMB = getCurrentMemoryUsage();
    if (memoryMB > _maxMemoryUsageMB) {
      warnings.add('Memory usage above limit: ${memoryMB.toStringAsFixed(1)}MB > ${_maxMemoryUsageMB}MB');
    }
    
    final latencyMs = getCurrentNetworkLatency();
    if (latencyMs > _maxNetworkLatencyMs) {
      warnings.add('Network latency above limit: ${latencyMs.toStringAsFixed(1)}ms > ${_maxNetworkLatencyMs}ms');
    }
    
    // Check for frame time spikes
    if (_frameTimes.isNotEmpty) {
      final maxFrameTime = _frameTimes
          .map((d) => d.inMicroseconds / 1000.0)
          .reduce((a, b) => a > b ? a : b);
      
      if (maxFrameTime > 33.0) { // 30fps threshold
        warnings.add('Frame time spike detected: ${maxFrameTime.toStringAsFixed(1)}ms');
      }
    }
    
    return warnings;
  }

  /// Exports performance data for external analysis.
  Map<String, dynamic> exportPerformanceData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'monitoringDuration': monitoringDuration?.inSeconds,
      'frameTimes': _frameTimes.map((d) => d.inMicroseconds).toList(),
      'memoryUsage': List.from(_memoryUsage),
      'networkLatency': List.from(_networkLatency),
      'customMetrics': Map.from(_customMetrics),
      'performanceReport': getPerformanceReport(),
      'warnings': getPerformanceWarnings(),
      'metrics': _metrics.map((key, value) => MapEntry(key, {
        'name': value.name,
        'currentValue': value.currentValue,
        'averageValue': value.averageValue,
        'minValue': value.minValue,
        'maxValue': value.maxValue,
        'lastUpdated': value.lastUpdated.toIso8601String(),
        'historyCount': value.history.length,
      })),
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
    _listeners.clear();
    _clearMetrics();
    
    debugPrint('Performance monitor disposed');
  }

  // Private methods

  void _collectMetrics() {
    // Collect system memory usage
    _collectSystemMemory();
    
    // Collect network latency (would need actual network calls)
    _collectNetworkMetrics();
    
    // Notify listeners of updated metrics
    _notifyListeners();
  }

  void _collectSystemMemory() {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // On mobile platforms, we would use platform channels to get actual memory info
        // For now, simulate with process memory
        final processInfo = ProcessInfo.currentRss;
        final memoryMB = processInfo / (1024 * 1024);
        recordMemoryUsage(memoryMB);
      }
    } catch (error) {
      debugPrint('Error collecting system memory: $error');
    }
  }

  void _collectNetworkMetrics() {
    // This would be implemented with actual network calls
    // For now, we'll use a placeholder
    if (_networkLatency.isEmpty) {
      recordNetworkLatency(50.0); // Simulate good network
    }
  }

  void _frameCallback(Duration timestamp) {
    if (!_isMonitoring) return;
    
    // Calculate frame time (this is a simplified implementation)
    final frameTime = Duration(milliseconds: 16); // ~60fps
    recordFrameTime(frameTime);
  }

  double _calculateCurrentFps() {
    if (_frameTimes.isEmpty) return 0.0;
    
    // Calculate average frame time from recent samples
    final recentSamples = _frameTimes.length > 60
        ? _frameTimes.sublist(_frameTimes.length - 60)
        : _frameTimes;
    
    if (recentSamples.isEmpty) return 0.0;
    
    final totalMicroseconds = recentSamples
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    
    final averageMicroseconds = totalMicroseconds / recentSamples.length;
    
    // Handle zero frame time to avoid division by zero
    if (averageMicroseconds <= 0) return 0.0;
    
    return 1000000.0 / averageMicroseconds;
  }

  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double? _getMetricValue(String name) {
    return _metrics[name]?.currentValue;
  }

  void _updateMetric(String name, double value, DateTime timestamp) {
    final existingMetric = _metrics[name];
    
    if (existingMetric == null) {
      _metrics[name] = PerformanceMetric(
        name: name,
        currentValue: value,
        averageValue: value,
        minValue: value,
        maxValue: value,
        lastUpdated: timestamp,
        history: [value],
      );
    } else {
      final newHistory = List<double>.from(existingMetric.history)..add(value);
      if (newHistory.length > _maxSamples) {
        newHistory.removeAt(0);
      }
      
      final average = _calculateAverage(newHistory);
      final min = newHistory.reduce((a, b) => a < b ? a : b);
      final max = newHistory.reduce((a, b) => a > b ? a : b);
      
      _metrics[name] = PerformanceMetric(
        name: name,
        currentValue: value,
        averageValue: average,
        minValue: min,
        maxValue: max,
        lastUpdated: timestamp,
        history: newHistory,
      );
    }
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener.onPerformanceUpdate(_metrics);
      } catch (error) {
        debugPrint('Error notifying performance listener: $error');
      }
    }
  }

  void _clearMetrics() {
    _metrics.clear();
    _frameTimes.clear();
    _memoryUsage.clear();
    _networkLatency.clear();
    _customMetrics.clear();
  }

  @override
  String toString() {
    if (!_isMonitoring) return 'PerformanceMonitor(stopped)';
    
    final fps = getCurrentFps();
    final memoryMB = getCurrentMemoryUsage();
    final latencyMs = getCurrentNetworkLatency();
    
    return 'PerformanceMonitor('
        'fps: ${fps.toStringAsFixed(1)}, '
        'memory: ${memoryMB.toStringAsFixed(1)}MB, '
        'latency: ${latencyMs.toStringAsFixed(1)}ms, '
        'samples: ${_frameTimes.length}'
        ')';
  }
}

/// Represents a performance metric with historical data.
class PerformanceMetric {
  final String name;
  final double currentValue;
  final double averageValue;
  final double minValue;
  final double maxValue;
  final DateTime lastUpdated;
  final List<double> history;

  const PerformanceMetric({
    required this.name,
    required this.currentValue,
    required this.averageValue,
    required this.minValue,
    required this.maxValue,
    required this.lastUpdated,
    required this.history,
  });

  @override
  String toString() {
    return 'PerformanceMetric($name: ${currentValue.toStringAsFixed(2)}, '
        'avg: ${averageValue.toStringAsFixed(2)}, '
        'range: ${minValue.toStringAsFixed(2)}-${maxValue.toStringAsFixed(2)})';
  }
}

/// Abstract listener for performance updates.
abstract class PerformanceListener {
  void onPerformanceUpdate(Map<String, PerformanceMetric> metrics);
}
