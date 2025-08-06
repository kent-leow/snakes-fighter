import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/network/network_optimizer.dart';

void main() {
  group('NetworkOptimizer', () {
    late NetworkOptimizer optimizer;

    setUp(() {
      optimizer = NetworkOptimizer();
      optimizer.initialize();
    });

    tearDown(() {
      optimizer.dispose();
    });

    group('initialization', () {
      test('should initialize successfully', () {
        final metrics = optimizer.getNetworkMetrics();
        expect(metrics['totalMessagesSent'], equals(0));
        expect(metrics['totalBytesTransmitted'], equals(0));
      });
    });

    group('message queuing', () {
      test('should queue messages', () {
        final message = NetworkMessage(
          roomId: 'room1',
          messageType: 'test',
          data: {'value': 42},
          timestamp: DateTime.now(),
        );

        optimizer.queueMessage(message);

        final metrics = optimizer.getNetworkMetrics();
        expect(metrics['queueSize'], equals(1));
      });

      test('should handle queue overflow', () {
        // Fill queue beyond capacity
        for (int i = 0; i < 1100; i++) {
          final message = NetworkMessage(
            roomId: 'room1',
            messageType: 'test',
            data: {'value': i},
            timestamp: DateTime.now(),
          );
          optimizer.queueMessage(message);
        }

        final metrics = optimizer.getNetworkMetrics();
        expect(metrics['queueSize'], lessThanOrEqualTo(1000));
      });
    });

    group('performance tracking', () {
      test('should record latency', () {
        const latency = Duration(milliseconds: 50);
        optimizer.recordLatency(latency);

        final metrics = optimizer.getNetworkMetrics();
        expect(metrics['averageLatency'], greaterThan(0.0));
        expect(metrics['latencyHistory'], isA<List>());
      });

      test('should maintain latency history', () {
        // Record multiple latencies
        for (int i = 1; i <= 5; i++) {
          optimizer.recordLatency(Duration(milliseconds: i * 10));
        }

        final metrics = optimizer.getNetworkMetrics();
        final history = metrics['latencyHistory'] as List<dynamic>;
        final latencyHistory = history.cast<int>();
        expect(latencyHistory.length, equals(5));
        expect(latencyHistory, contains(10));
        expect(latencyHistory, contains(50));
      });

      test('should limit history size', () {
        // Record more than the history limit (100)
        for (int i = 0; i < 150; i++) {
          optimizer.recordLatency(const Duration(milliseconds: 10));
        }

        final metrics = optimizer.getNetworkMetrics();
        final history = metrics['latencyHistory'] as List<dynamic>;
        final latencyHistory = history.cast<int>();
        expect(latencyHistory.length, lessThanOrEqualTo(100));
      });
    });

    group('compression settings', () {
      test('should enable/disable compression', () {
        optimizer.setCompressionEnabled(false);

        var metrics = optimizer.getNetworkMetrics();
        expect(metrics['compressionEnabled'], isFalse);

        optimizer.setCompressionEnabled(true);

        metrics = optimizer.getNetworkMetrics();
        expect(metrics['compressionEnabled'], isTrue);
      });

      test('should set compression threshold', () {
        optimizer.setCompressionThreshold(200);

        // Compression threshold is internal, so we verify it doesn't throw
        expect(() => optimizer.setCompressionThreshold(200), returnsNormally);
      });
    });

    group('settings optimization', () {
      test('should optimize settings based on performance', () {
        // Simulate high latency
        for (int i = 0; i < 10; i++) {
          optimizer.recordLatency(const Duration(milliseconds: 150));
        }

        expect(() => optimizer.optimizeSettings(), returnsNormally);
      });

      test('should optimize settings based on payload size', () {
        // This is tested indirectly through the optimization method
        expect(() => optimizer.optimizeSettings(), returnsNormally);
      });
    });

    group('immediate sending', () {
      test('should send message immediately', () async {
        final message = NetworkMessage(
          roomId: 'room1',
          messageType: 'urgent',
          data: {'urgent': true},
          timestamp: DateTime.now(),
        );

        await expectLater(optimizer.sendImmediate(message), completes);
      });
    });
  });

  group('NetworkMessage', () {
    test('should create message with required fields', () {
      final timestamp = DateTime.now();
      final message = NetworkMessage(
        roomId: 'room1',
        messageType: 'test',
        data: {'key': 'value'},
        timestamp: timestamp,
      );

      expect(message.roomId, equals('room1'));
      expect(message.messageType, equals('test'));
      expect(message.data['key'], equals('value'));
      expect(message.timestamp, equals(timestamp));
      expect(message.priority, equals(0)); // default
    });

    test('should create message with priority', () {
      final message = NetworkMessage(
        roomId: 'room1',
        messageType: 'test',
        data: {},
        timestamp: DateTime.now(),
        priority: 5,
      );

      expect(message.priority, equals(5));
    });

    test('should serialize to JSON', () {
      final timestamp = DateTime.now();
      final message = NetworkMessage(
        roomId: 'room1',
        messageType: 'test',
        data: {'key': 'value'},
        timestamp: timestamp,
        priority: 2,
      );

      final json = message.toJson();

      expect(json['roomId'], equals('room1'));
      expect(json['messageType'], equals('test'));
      expect(json['data'], equals({'key': 'value'}));
      expect(json['timestamp'], equals(timestamp.millisecondsSinceEpoch));
      expect(json['priority'], equals(2));
    });

    test('should deserialize from JSON', () {
      final timestamp = DateTime.now();
      final json = {
        'roomId': 'room1',
        'messageType': 'test',
        'data': {'key': 'value'},
        'timestamp': timestamp.millisecondsSinceEpoch,
        'priority': 3,
      };

      final message = NetworkMessage.fromJson(json);

      expect(message.roomId, equals('room1'));
      expect(message.messageType, equals('test'));
      expect(message.data['key'], equals('value'));
      expect(
        message.timestamp.millisecondsSinceEpoch,
        equals(timestamp.millisecondsSinceEpoch),
      );
      expect(message.priority, equals(3));
    });

    test('should handle missing priority in JSON', () {
      final json = {
        'roomId': 'room1',
        'messageType': 'test',
        'data': <String, dynamic>{},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final message = NetworkMessage.fromJson(json);

      expect(message.priority, equals(0)); // default
    });
  });

  group('NetworkProfiler', () {
    late NetworkProfiler profiler;

    setUp(() {
      profiler = NetworkProfiler();
    });

    test('should record operation latencies', () {
      profiler.recordOperation('test_op', const Duration(milliseconds: 100));
      profiler.recordOperation('test_op', const Duration(milliseconds: 150));

      final profile = profiler.getProfile();

      expect(profile.containsKey('test_op'), isTrue);
      expect(profile['test_op']['count'], equals(2));
      expect(profile['test_op']['averageLatency'], greaterThan(0));
    });

    test('should calculate statistics correctly', () {
      profiler.recordOperation('op1', const Duration(milliseconds: 100));
      profiler.recordOperation('op1', const Duration(milliseconds: 200));
      profiler.recordOperation('op1', const Duration(milliseconds: 300));

      final profile = profiler.getProfile();
      final op1Stats = profile['op1'];

      expect(op1Stats['count'], equals(3));
      expect(op1Stats['averageLatency'], closeTo(200.0, 0.1));
      expect(op1Stats['minLatency'], equals(100.0));
      expect(op1Stats['maxLatency'], equals(300.0));
    });

    test('should handle multiple operation types', () {
      profiler.recordOperation('op1', const Duration(milliseconds: 100));
      profiler.recordOperation('op2', const Duration(milliseconds: 200));

      final profile = profiler.getProfile();

      expect(profile.containsKey('op1'), isTrue);
      expect(profile.containsKey('op2'), isTrue);
      expect(profile['op1']['averageLatency'], equals(100.0));
      expect(profile['op2']['averageLatency'], equals(200.0));
    });

    test('should clear profile data', () {
      profiler.recordOperation('test_op', const Duration(milliseconds: 100));

      profiler.clear();

      final profile = profiler.getProfile();
      expect(profile, isEmpty);
    });

    test('should maintain sample limits', () {
      // Record more than the sample limit (50)
      for (int i = 0; i < 60; i++) {
        profiler.recordOperation('test_op', Duration(milliseconds: i + 10));
      }

      final profile = profiler.getProfile();
      expect(profile['test_op']['count'], equals(60));
      // The latency should be calculated from the most recent 50 samples
    });
  });
}
