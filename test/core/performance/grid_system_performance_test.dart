import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/core/constants/grid_constants.dart';

void main() {
  group('Grid System Performance Tests', () {
    test('coordinate conversions should be fast', () {
      final gridSystem = GridSystem(
        gridWidth: 50,
        gridHeight: 50,
        cellSize: 20.0,
        screenWidth: 1200.0,
        screenHeight: 1000.0,
      );

      final stopwatch = Stopwatch()..start();
      const iterations = 10000;

      // Test grid-to-screen conversions
      for (int i = 0; i < iterations; i++) {
        final pos = Position(i % 50, (i ~/ 50) % 50);
        gridSystem.gridToScreen(pos);
      }

      stopwatch.stop();
      final avgTime =
          stopwatch.elapsedMicroseconds /
          iterations /
          1000; // Convert to milliseconds

      expect(avgTime, lessThan(GridConstants.maxCoordinateCalculationTime));
      print(
        'Average coordinate conversion time: ${avgTime.toStringAsFixed(3)}ms',
      );
    });

    test('position distance calculations should be fast', () {
      final positions = List.generate(
        1000,
        (i) => Position(math.Random().nextInt(100), math.Random().nextInt(100)),
      );

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < positions.length - 1; i++) {
        positions[i].distanceTo(positions[i + 1]);
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMicroseconds / positions.length / 1000;

      expect(avgTime, lessThan(GridConstants.maxCoordinateCalculationTime));
      print(
        'Average distance calculation time: ${avgTime.toStringAsFixed(3)}ms',
      );
    });

    test('neighbor calculations should be fast', () {
      final positions = List.generate(
        1000,
        (i) => Position(math.Random().nextInt(100), math.Random().nextInt(100)),
      );

      final stopwatch = Stopwatch()..start();

      for (final position in positions) {
        position.getNeighbors();
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMicroseconds / positions.length / 1000;

      expect(avgTime, lessThan(GridConstants.maxCoordinateCalculationTime));
      print(
        'Average neighbor calculation time: ${avgTime.toStringAsFixed(3)}ms',
      );
    });
  });
}
