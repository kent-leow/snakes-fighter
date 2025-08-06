import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Network optimizer for efficient multiplayer game synchronization.
///
/// Provides batching, compression, and latency optimization for game data
/// transmission while maintaining real-time performance requirements.
class NetworkOptimizer {
  static final NetworkOptimizer _instance = NetworkOptimizer._internal();
  factory NetworkOptimizer() => _instance;
  NetworkOptimizer._internal();

  // Batching configuration
  static const Duration _batchInterval = Duration(
    milliseconds: 50,
  ); // 20fps batch rate
  static const int _maxBatchSize = 100;
  static const int _maxQueueSize = 1000;

  // Performance tracking
  final List<Duration> _latencyHistory = [];
  final List<int> _payloadSizeHistory = [];
  Timer? _batchTimer;
  Timer? _metricsTimer;

  // Batching queues
  final Queue<NetworkMessage> _outgoingQueue = Queue<NetworkMessage>();
  final Map<String, List<NetworkMessage>> _roomBatches = {};

  // Compression settings
  bool _compressionEnabled = true;
  int _compressionThreshold = 100; // bytes

  // Network metrics
  double _averageLatency = 0.0;
  double _averagePayloadSize = 0.0;
  int _totalMessagesSent = 0;
  int _totalBytesTransmitted = 0;

  /// Initializes the network optimizer.
  void initialize() {
    _startBatchTimer();
    _startMetricsCollection();
    debugPrint('NetworkOptimizer initialized');
  }

  /// Queues a message for optimized transmission.
  void queueMessage(NetworkMessage message) {
    if (_outgoingQueue.length >= _maxQueueSize) {
      // Drop oldest messages if queue is full
      _outgoingQueue.removeFirst();
      debugPrint('Network queue full, dropping oldest message');
    }

    _outgoingQueue.add(message);
  }

  /// Sends a message immediately (bypasses batching).
  Future<void> sendImmediate(NetworkMessage message) async {
    final payload = await _preparePayload([message]);
    await _transmitPayload(payload, message.roomId);
  }

  /// Records network latency for performance tracking.
  void recordLatency(Duration latency) {
    _latencyHistory.add(latency);

    // Keep only recent samples
    if (_latencyHistory.length > 100) {
      _latencyHistory.removeAt(0);
    }

    _updateAverageLatency();
  }

  /// Gets current network performance metrics.
  Map<String, dynamic> getNetworkMetrics() {
    return {
      'averageLatency': _averageLatency,
      'averagePayloadSize': _averagePayloadSize,
      'totalMessagesSent': _totalMessagesSent,
      'totalBytesTransmitted': _totalBytesTransmitted,
      'queueSize': _outgoingQueue.length,
      'compressionEnabled': _compressionEnabled,
      'batchingEnabled': _batchTimer?.isActive ?? false,
      'latencyHistory': List.from(_latencyHistory.map((d) => d.inMilliseconds)),
      'payloadSizeHistory': List.from(_payloadSizeHistory),
    };
  }

  /// Optimizes network settings based on performance data.
  void optimizeSettings() {
    // Adjust compression threshold based on payload sizes
    if (_payloadSizeHistory.isNotEmpty) {
      final avgSize =
          _payloadSizeHistory.reduce((a, b) => a + b) /
          _payloadSizeHistory.length;

      if (avgSize < 50) {
        // Small payloads, disable compression
        _compressionEnabled = false;
      } else if (avgSize > 200) {
        // Large payloads, enable compression with lower threshold
        _compressionEnabled = true;
        _compressionThreshold = 50;
      }
    }

    // Adjust batch interval based on latency
    if (_averageLatency > 100) {
      // High latency, reduce batch frequency to avoid timeout issues
      _restartBatchTimer(const Duration(milliseconds: 100));
    } else if (_averageLatency < 20) {
      // Low latency, increase batch frequency for better responsiveness
      _restartBatchTimer(const Duration(milliseconds: 25));
    }
  }

  /// Enables or disables message compression.
  void setCompressionEnabled(bool enabled) {
    _compressionEnabled = enabled;
    debugPrint('Network compression ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Sets the compression threshold in bytes.
  void setCompressionThreshold(int threshold) {
    _compressionThreshold = threshold;
    debugPrint('Network compression threshold set to $threshold bytes');
  }

  /// Disposes of the network optimizer.
  void dispose() {
    _batchTimer?.cancel();
    _metricsTimer?.cancel();
    _outgoingQueue.clear();
    _roomBatches.clear();
    _latencyHistory.clear();
    _payloadSizeHistory.clear();
    debugPrint('NetworkOptimizer disposed');
  }

  // Private methods

  void _startBatchTimer() {
    _batchTimer = Timer.periodic(_batchInterval, (_) {
      _processBatches();
    });
  }

  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _collectMetrics();
    });
  }

  void _restartBatchTimer(Duration interval) {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(interval, (_) {
      _processBatches();
    });
  }

  void _processBatches() {
    if (_outgoingQueue.isEmpty) return;

    // Group messages by room
    _roomBatches.clear();
    final messagesToProcess = <NetworkMessage>[];

    while (_outgoingQueue.isNotEmpty &&
        messagesToProcess.length < _maxBatchSize) {
      messagesToProcess.add(_outgoingQueue.removeFirst());
    }

    for (final message in messagesToProcess) {
      _roomBatches.putIfAbsent(message.roomId, () => []).add(message);
    }

    // Process each room's batch
    for (final entry in _roomBatches.entries) {
      final roomId = entry.key;
      final messages = entry.value;

      _processBatchForRoom(roomId, messages);
    }
  }

  Future<void> _processBatchForRoom(
    String roomId,
    List<NetworkMessage> messages,
  ) async {
    try {
      final payload = await _preparePayload(messages);
      await _transmitPayload(payload, roomId);

      _totalMessagesSent += messages.length;
      _totalBytesTransmitted += payload.length;
    } catch (error) {
      debugPrint('Error processing batch for room $roomId: $error');

      // Re-queue messages on failure
      for (final message in messages) {
        if (_outgoingQueue.length < _maxQueueSize) {
          _outgoingQueue.add(message);
        }
      }
    }
  }

  Future<List<int>> _preparePayload(List<NetworkMessage> messages) async {
    // Serialize messages to JSON
    final jsonData = messages.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(jsonData);

    List<int> payload = utf8.encode(jsonString);

    // Apply compression if enabled and payload is large enough
    if (_compressionEnabled && payload.length > _compressionThreshold) {
      try {
        // Note: In a real implementation, you would use actual compression
        // For this example, we'll simulate compression
        payload = _simulateCompression(payload);
      } catch (error) {
        debugPrint('Compression failed: $error');
        // Fall back to uncompressed
      }
    }

    _payloadSizeHistory.add(payload.length);
    if (_payloadSizeHistory.length > 100) {
      _payloadSizeHistory.removeAt(0);
    }

    return payload;
  }

  List<int> _simulateCompression(List<int> data) {
    // Simulate compression by reducing size by ~30%
    final compressedSize = (data.length * 0.7).round();
    return data.take(compressedSize).toList();
  }

  Future<void> _transmitPayload(List<int> payload, String roomId) async {
    // Simulate network transmission
    final startTime = DateTime.now();

    // In a real implementation, this would send to Firebase or other backend
    await Future.delayed(
      Duration(milliseconds: (10 + (payload.length / 100)).round()),
    );

    final endTime = DateTime.now();
    final latency = endTime.difference(startTime);
    recordLatency(latency);
  }

  void _updateAverageLatency() {
    if (_latencyHistory.isNotEmpty) {
      final totalMs = _latencyHistory
          .map((d) => d.inMicroseconds)
          .reduce((a, b) => a + b);
      _averageLatency =
          totalMs / _latencyHistory.length / 1000.0; // Convert to milliseconds
    }
  }

  void _collectMetrics() {
    if (_payloadSizeHistory.isNotEmpty) {
      _averagePayloadSize =
          _payloadSizeHistory.reduce((a, b) => a + b) /
          _payloadSizeHistory.length;
    }

    if (kDebugMode) {
      final metrics = getNetworkMetrics();
      debugPrint(
        'Network metrics: ${metrics['averageLatency']}ms latency, '
        '${metrics['averagePayloadSize']} bytes avg payload',
      );
    }

    // Auto-optimize settings periodically
    optimizeSettings();
  }
}

/// Represents a network message for game synchronization.
class NetworkMessage {
  final String roomId;
  final String messageType;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int priority;

  const NetworkMessage({
    required this.roomId,
    required this.messageType,
    required this.data,
    required this.timestamp,
    this.priority = 0,
  });

  /// Converts the message to JSON for transmission.
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'messageType': messageType,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'priority': priority,
    };
  }

  /// Creates a message from JSON data.
  factory NetworkMessage.fromJson(Map<String, dynamic> json) {
    return NetworkMessage(
      roomId: json['roomId'] as String,
      messageType: json['messageType'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      priority: json['priority'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'NetworkMessage(roomId: $roomId, type: $messageType, priority: $priority)';
  }
}

/// Network performance profiler for detailed analysis.
class NetworkProfiler {
  final Map<String, List<Duration>> _operationLatencies = {};
  final Map<String, int> _operationCounts = {};

  /// Records latency for a specific operation type.
  void recordOperation(String operationType, Duration latency) {
    _operationLatencies.putIfAbsent(operationType, () => []).add(latency);
    _operationCounts[operationType] =
        (_operationCounts[operationType] ?? 0) + 1;

    // Keep only recent samples
    final latencies = _operationLatencies[operationType]!;
    if (latencies.length > 50) {
      latencies.removeAt(0);
    }
  }

  /// Gets performance profile for all operations.
  Map<String, dynamic> getProfile() {
    final profile = <String, dynamic>{};

    for (final operationType in _operationLatencies.keys) {
      final latencies = _operationLatencies[operationType]!;
      final count = _operationCounts[operationType] ?? 0;

      if (latencies.isNotEmpty) {
        final avgLatency =
            latencies.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
            latencies.length /
            1000.0;
        final minLatency =
            latencies
                .map((d) => d.inMicroseconds)
                .reduce((a, b) => a < b ? a : b) /
            1000.0;
        final maxLatency =
            latencies
                .map((d) => d.inMicroseconds)
                .reduce((a, b) => a > b ? a : b) /
            1000.0;

        profile[operationType] = {
          'count': count,
          'averageLatency': avgLatency,
          'minLatency': minLatency,
          'maxLatency': maxLatency,
        };
      }
    }

    return profile;
  }

  /// Clears all profiling data.
  void clear() {
    _operationLatencies.clear();
    _operationCounts.clear();
  }
}
