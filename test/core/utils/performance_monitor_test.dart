import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/utils/performance_monitor.dart';

void main() {
  group('PerformanceMonitor', () {
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
        expect(monitor.getCurrentFps(), 0.0);
        expect(monitor.getCurrentMemoryUsage(), 0);
      });

      test('should provide initial performance report', () {
        final report = monitor.getPerformanceReport();

        expect(report['isMonitoring'], isFalse);
        expect(report['fps']['current'], 0.0);
        expect(report['memory']['currentMB'], 0);
        expect(report['overallPerformance']['meetsRequirements'], isFalse);
      });
    });

    group('monitoring lifecycle', () {
      test('should start monitoring', () {
        monitor.startMonitoring();

        expect(monitor.isMonitoring, isTrue);
        expect(monitor.monitoringDuration, isA<Duration>());
      });

      test('should stop monitoring', () {
        monitor.startMonitoring();
        monitor.stopMonitoring();

        expect(monitor.isMonitoring, isFalse);
      });

      test('should not start if already monitoring', () {
        monitor.startMonitoring();
        final wasMonitoring = monitor.isMonitoring;

        monitor.startMonitoring(); // Try to start again

        expect(wasMonitoring, isTrue);
        expect(monitor.isMonitoring, isTrue);
      });

      test('should not stop if already stopped', () {
        monitor.stopMonitoring(); // Already stopped

        expect(monitor.isMonitoring, isFalse);
      });
    });

    group('frame time recording', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should record frame times', () {
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordFrameTime(const Duration(milliseconds: 17));
        monitor.recordFrameTime(const Duration(milliseconds: 15));

        expect(monitor.getCurrentFps(), greaterThan(0.0));
        expect(monitor.getAverageFrameTime(), greaterThan(0.0));
      });

      test('should calculate FPS correctly', () {
        // Record consistent 60fps frame times (16.67ms)
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }

        final fps = monitor.getCurrentFps();
        expect(fps, closeTo(60.0, 5.0)); // Allow some variance
      });

      test('should handle varying frame times', () {
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordFrameTime(const Duration(milliseconds: 33)); // Drop to 30fps
        monitor.recordFrameTime(const Duration(milliseconds: 16));

        final fps = monitor.getCurrentFps();
        expect(fps, greaterThan(0.0));
        expect(fps, lessThan(60.0));
      });

      test('should not record when not monitoring', () {
        monitor.stopMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));

        expect(monitor.getCurrentFps(), 0.0);
      });

      test('should limit frame time samples', () {
        // Record more than max samples
        for (int i = 0; i < 350; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 16));
        }

        // Should still function correctly with limited samples
        expect(monitor.getCurrentFps(), greaterThan(0.0));
      });
    });

    group('memory usage recording', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should record memory usage', () {
        monitor.recordMemoryUsage(50);
        monitor.recordMemoryUsage(60);
        monitor.recordMemoryUsage(55);

        expect(monitor.getCurrentMemoryUsage(), 55);
        expect(monitor.getPeakMemoryUsage(), 60);
      });

      test('should track peak memory usage', () {
        monitor.recordMemoryUsage(30);
        monitor.recordMemoryUsage(80);
        monitor.recordMemoryUsage(45);

        expect(monitor.getPeakMemoryUsage(), 80);
      });

      test('should not record when not monitoring', () {
        monitor.stopMonitoring();
        monitor.recordMemoryUsage(50);

        expect(monitor.getCurrentMemoryUsage(), 0);
      });

      test('should limit memory usage samples', () {
        // Record more than max samples
        for (int i = 0; i < 350; i++) {
          monitor.recordMemoryUsage(i % 100);
        }

        // Should still function correctly
        expect(monitor.getCurrentMemoryUsage(), greaterThanOrEqualTo(0));
      });
    });

    group('custom metrics', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should record custom metrics', () {
        monitor.recordMetric('customMetric', 42.0);
        monitor.recordMetric('customMetric', 45.0);
        monitor.recordMetric('customMetric', 38.0);

        final stats = monitor.getMetricStats('customMetric');
        expect(stats['min'], 38.0);
        expect(stats['max'], 45.0);
        expect(stats['latest'], 38.0);
        expect(stats['count'], 3.0);
        expect(stats['average'], closeTo(41.67, 0.1));
      });

      test('should handle empty metrics', () {
        final stats = monitor.getMetricStats('nonExistentMetric');

        expect(stats['min'], 0.0);
        expect(stats['max'], 0.0);
        expect(stats['average'], 0.0);
        expect(stats['latest'], 0.0);
        expect(stats['count'], 0.0);
      });

      test('should limit custom metric samples', () {
        // Record more than max samples
        for (int i = 0; i < 350; i++) {
          monitor.recordMetric('testMetric', i.toDouble());
        }

        final stats = monitor.getMetricStats('testMetric');
        expect(stats['count'], lessThanOrEqualTo(300.0));
      });

      test('should not record when not monitoring', () {
        monitor.stopMonitoring();
        monitor.recordMetric('testMetric', 42.0);

        final stats = monitor.getMetricStats('testMetric');
        expect(stats['count'], 0.0);
      });
    });

    group('performance requirements', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should meet requirements with good performance', () {
        // Record good frame times (60fps)
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }
        monitor.recordMemoryUsage(50); // Under 100MB limit

        expect(monitor.meetsPerformanceRequirements(), isTrue);
      });

      test('should fail requirements with poor FPS', () {
        // Record poor frame times (30fps)
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 33));
        }
        monitor.recordMemoryUsage(50);

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });

      test('should fail requirements with high memory usage', () {
        // Record good frame times but high memory
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }
        monitor.recordMemoryUsage(150); // Over 100MB limit

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });

      test('should fail requirements with slow frame times', () {
        // Record very slow frame times
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 50));
        }
        monitor.recordMemoryUsage(50);

        expect(monitor.meetsPerformanceRequirements(), isFalse);
      });
    });

    group('performance warnings', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should generate no warnings for good performance', () {
        // Record good performance
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(microseconds: 16667));
        }
        monitor.recordMemoryUsage(50);

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings, isEmpty);
      });

      test('should warn about low FPS', () {
        // Record low FPS
        for (int i = 0; i < 60; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 33));
        }

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('FPS below')), isTrue);
      });

      test('should warn about high memory usage', () {
        monitor.recordMemoryUsage(150);

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('Memory usage above')), isTrue);
      });

      test('should warn about slow frame times', () {
        for (int i = 0; i < 10; i++) {
          monitor.recordFrameTime(const Duration(milliseconds: 50));
        }

        final warnings = monitor.getPerformanceWarnings();
        expect(warnings.any((w) => w.contains('Frame time above')), isTrue);
      });

      test('should warn about frame time spikes', () {
        // Record normal times then a spike
        for (int i = 0; i < 10; i++) {
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
        monitor.recordMemoryUsage(50);
        monitor.recordMetric('testMetric', 42.0);

        final report = monitor.getPerformanceReport();

        expect(report['isMonitoring'], isTrue);
        expect(report['fps'], isA<Map>());
        expect(report['memory'], isA<Map>());
        expect(report['frameTime'], isA<Map>());
        expect(report['overallPerformance'], isA<Map>());
        expect(report['customMetrics'], isA<List>());
      });

      test('should include acceptability flags', () {
        monitor.recordFrameTime(const Duration(microseconds: 16667));
        monitor.recordMemoryUsage(50);

        final report = monitor.getPerformanceReport();

        expect(report['fps']['isAcceptable'], isA<bool>());
        expect(report['memory']['isAcceptable'], isA<bool>());
        expect(report['frameTime']['isAcceptable'], isA<bool>());
      });

      test('should include custom metrics in report', () {
        monitor.recordMetric('metric1', 10.0);
        monitor.recordMetric('metric2', 20.0);

        final report = monitor.getPerformanceReport();
        final customMetrics = report['customMetrics'] as List;

        expect(customMetrics.length, 2);
        expect(customMetrics.any((m) => m['name'] == 'metric1'), isTrue);
        expect(customMetrics.any((m) => m['name'] == 'metric2'), isTrue);
      });
    });

    group('data export', () {
      setUp(() {
        monitor.startMonitoring();
      });

      test('should export performance data', () {
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50);
        monitor.recordMetric('testMetric', 42.0);

        final exportData = monitor.exportPerformanceData();

        expect(exportData['timestamp'], isA<String>());
        expect(exportData['frameTimes'], isA<List>());
        expect(exportData['memoryUsage'], isA<List>());
        expect(exportData['customMetrics'], isA<Map>());
        expect(exportData['performanceReport'], isA<Map>());
        expect(exportData['warnings'], isA<List>());
      });
    });

    group('reset functionality', () {
      test('should reset all data', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50);

        monitor.reset();

        expect(monitor.isMonitoring, isFalse);
        expect(monitor.getCurrentFps(), 0.0);
        expect(monitor.getCurrentMemoryUsage(), 0);
        expect(monitor.monitoringDuration, isNull);
      });
    });

    group('disposal', () {
      test('should dispose cleanly', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));

        monitor.dispose();

        expect(monitor.isMonitoring, isFalse);
      });
    });

    group('string representation', () {
      test('should provide meaningful toString when stopped', () {
        final str = monitor.toString();

        expect(str, contains('PerformanceMonitor'));
        expect(str, contains('stopped'));
      });

      test('should provide meaningful toString when monitoring', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(milliseconds: 16));
        monitor.recordMemoryUsage(50);

        final str = monitor.toString();

        expect(str, contains('PerformanceMonitor'));
        expect(str, contains('fps:'));
        expect(str, contains('memory:'));
      });
    });

    group('edge cases', () {
      test('should handle zero frame times', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(Duration.zero);

        // Should not crash
        final fps = monitor.getCurrentFps();
        expect(fps.isFinite, isTrue);
      });

      test('should handle negative memory values gracefully', () {
        monitor.startMonitoring();
        
        // Negative values shouldn't crash the system
        expect(() => monitor.recordMemoryUsage(-10), returnsNormally);
      });

      test('should handle very large values', () {
        monitor.startMonitoring();
        monitor.recordFrameTime(const Duration(seconds: 1));
        monitor.recordMemoryUsage(10000);

        // Should not crash with extreme values
        final fps = monitor.getCurrentFps();
        expect(fps.isFinite, isTrue);
        expect(monitor.getCurrentMemoryUsage(), 10000);
      });
    });
  });
}
