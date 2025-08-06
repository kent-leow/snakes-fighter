import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/performance/performance_monitor.dart';

void main() {
  group('Enhanced PerformanceMonitor', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
    });

    tearDown(() {
      monitor.dispose();
    });

    group('initialization', () {
      test('should start in stopped state', () {
        expect(monitor.isMonitoring, isFalse);
        expect(monitor.monitoringDuration, isNull);
      });

      test('should start monitoring', () {
        monitor.startMonitoring();

        expect(monitor.isMonitoring, isTrue);
        expect(monitor.monitoringDuration, isNotNull);
      });

      test('should stop monitoring', () {
        monitor.startMonitoring();
        monitor.stopMonitoring();

        expect(monitor.isMonitoring, isFalse);
      });
    });

    group('metrics recording', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should record frame times', () {
        const frameTime = Duration(milliseconds: 16);
        monitor.recordFrameTime(frameTime);

        expect(monitor.getCurrentFps(), greaterThan(0));
      });

      test('should record memory usage', () {
        monitor.recordMemoryUsage(50.0);

        expect(monitor.getCurrentMemoryUsage(), equals(50.0));
      });

      test('should record network latency', () {
        monitor.recordNetworkLatency(100.0);

        expect(monitor.getCurrentNetworkLatency(), equals(100.0));
      });

      test('should record custom metrics', () {
        monitor.recordCustomMetric('test_metric', 42.0);

        final metric = monitor.getMetric('test_metric');
        expect(metric, isNotNull);
        expect(metric!.currentValue, equals(42.0));
      });
    });

    group('performance requirements', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should meet requirements with good performance', () {
        // Record good performance metrics
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667)); // 60fps
        }
        monitor.recordMemoryUsage(50.0); // Under 100MB
        monitor.recordNetworkLatency(50.0); // Under 200ms

        expect(monitor.meetsPerformanceRequirements(), isTrue);
      });

      test('should fail requirements with poor FPS', () {
        // Record poor frame times
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 50)); // 20fps
        }
        monitor.recordMemoryUsage(50.0);
        monitor.recordNetworkLatency(50.0);

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });

      test('should fail requirements with high memory usage', () {
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }
        monitor.recordMemoryUsage(150.0); // Over 100MB limit
        monitor.recordNetworkLatency(50.0);

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });

      test('should fail requirements with high network latency', () {
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }
        monitor.recordMemoryUsage(50.0);
        monitor.recordNetworkLatency(300.0); // Over 200ms limit

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });
    });

    group('performance warnings', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should warn about low FPS', () {
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 50));
        }

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('FPS below')), isTrue);
      });

      test('should warn about high memory usage', () {
        monitor.recordMemoryUsage(150.0);

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('Memory usage above')), isTrue);
      });

      test('should warn about frame time spikes', () {
        // Record normal times then a spike
        for (int i = 0; i < 5; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 16));
        }
        monitor.recordFrameTime(const Duration(milliseconds: 100)); // Spike

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('Frame time spike')), isTrue);
      });
    });

    group('performance report', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should provide comprehensive performance report', () {
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50.0);
        monitor.recordNetworkLatency(100.0);
        monitor.recordCustomMetric('testMetric', 42.0);

        final report = monitor.getPerformanceReport();

        expect(report['isMonitoring'], isTrue);
        expect(report['fps'], isA<Map>());
        expect(report['memory'], isA<Map>());
        expect(report['network'], isA<Map>());
        expect(report['overallPerformance'], isA<Map>());
        expect(report['customMetrics'], isA<List>());
      });
    });

    group('data export', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should export performance data', () {
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50.0);
        monitor.recordCustomMetric('testMetric', 42.0);

        final exportData = monitor.exportPerformanceData();

        expect(exportData['timestamp'], isA<String>());
        expect(exportData['frameTimes'], isA<List>());
        expect(exportData['memoryUsage'], isA<List>());
        expect(exportData['customMetrics'], isA<Map>());
        expect(exportData['performanceReport'], isA<Map>());
        expect(exportData['warnings'], isA<List>());
      });
    });

    group('reset and dispose', () {
      test('should reset all data', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50.0);

        monitor.reset();

        expect(monitor.isMonitoring, isFalse);
        expect(monitor.getCurrentFps(), equals(0.0));
        expect(monitor.getCurrentMemoryUsage(), equals(0.0));
        expect(monitor.monitoringDuration, isNull);
      });

      test('should dispose cleanly', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));

        monitor.dispose();

        expect(monitor.isMonitoring, isFalse);
      });
    });
  });
}
