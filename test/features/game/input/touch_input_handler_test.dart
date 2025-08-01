import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/features/game/input/touch_input_handler.dart';
import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  group('TouchInputHandler', () {
    late TouchInputHandler touchHandler;

    setUp(() {
      touchHandler = TouchInputHandler();
      touchHandler.initialize();
      touchHandler.activate();
    });

    tearDown(() {
      touchHandler.dispose();
    });

    group('initialization', () {
      test('should initialize with default settings', () {
        expect(touchHandler.isSupported, isTrue);
        expect(touchHandler.isActive, isTrue);
        expect(
          touchHandler.minSwipeDistance,
          TouchInputHandler.defaultMinSwipeDistance,
        );
        expect(
          touchHandler.maxSwipeTime,
          TouchInputHandler.defaultMaxSwipeTime,
        );
        expect(
          touchHandler.minSwipeVelocity,
          TouchInputHandler.defaultMinSwipeVelocity,
        );
      });

      test('should initialize with custom settings', () {
        final customHandler = TouchInputHandler(
          minSwipeDistance: 100.0,
          maxSwipeTime: 500.0,
          minSwipeVelocity: 0.5,
        );

        expect(customHandler.minSwipeDistance, 100.0);
        expect(customHandler.maxSwipeTime, 500.0);
        expect(customHandler.minSwipeVelocity, 0.5);

        customHandler.dispose();
      });
    });

    group('swipe gesture detection', () {
      test('should detect horizontal right swipe', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate right swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(
              200,
              105,
            ), // 100px right, minimal vertical
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, Direction.right);
      });

      test('should detect horizontal left swipe', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate left swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(200, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(
              100,
              105,
            ), // 100px left, minimal vertical
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, Direction.left);
      });

      test('should detect vertical up swipe', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate up swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 200)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(
              105,
              100,
            ), // 100px up, minimal horizontal
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, Direction.up);
      });

      test('should detect vertical down swipe', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate down swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(
              105,
              200,
            ), // 100px down, minimal horizontal
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, Direction.down);
      });
    });

    group('swipe validation', () {
      test('should reject swipe that is too short', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate short swipe (less than minimum distance)
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(120, 100), // Only 20px - too short
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, isNull);
      });

      test('should reject swipe that is too slow', () async {
        Direction? detectedDirection;

        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        // Simulate slow swipe (exceeds maximum time)
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 400)); // Too slow

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(200, 100), // Good distance but too slow
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, isNull);
      });
    });

    group('sensitivity adjustment', () {
      test('should update sensitivity settings', () {
        touchHandler.updateSensitivity(
          minSwipeDistance: 80.0,
          maxSwipeTime: 400.0,
          minSwipeVelocity: 0.3,
        );

        expect(touchHandler.minSwipeDistance, 80.0);
        expect(touchHandler.maxSwipeTime, 400.0);
        expect(touchHandler.minSwipeVelocity, 0.3);
      });

      test('should ignore invalid sensitivity values', () {
        final originalDistance = touchHandler.minSwipeDistance;
        final originalTime = touchHandler.maxSwipeTime;
        final originalVelocity = touchHandler.minSwipeVelocity;

        touchHandler.updateSensitivity(
          minSwipeDistance: -10.0, // Invalid
          maxSwipeTime: -50.0, // Invalid
          minSwipeVelocity: -0.1, // Invalid
        );

        expect(touchHandler.minSwipeDistance, originalDistance);
        expect(touchHandler.maxSwipeTime, originalTime);
        expect(touchHandler.minSwipeVelocity, originalVelocity);
      });
    });

    group('statistics tracking', () {
      test('should track swipe statistics', () async {
        // Perform valid swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(localPosition: const Offset(200, 100)),
        );

        // Perform invalid swipe
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 50));

        touchHandler.handlePanEnd(
          DragEndDetails(
            localPosition: const Offset(110, 100), // Too short
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        final stats = touchHandler.getInputStats();
        expect(stats['totalSwipes'], 2);
        expect(stats['validSwipes'], 1);
        expect(stats['invalidSwipes'], 1);
        expect(stats['inputType'], 'touch');
      });
    });

    group('lifecycle management', () {
      test('should not process input when inactive', () async {
        touchHandler.deactivate();

        Direction? detectedDirection;
        touchHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        touchHandler.handlePanEnd(
          DragEndDetails(localPosition: const Offset(200, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, isNull);
      });

      test('should reset statistics when reset', () async {
        // Generate some statistics
        touchHandler.handlePanStart(
          DragStartDetails(localPosition: const Offset(100, 100)),
        );

        touchHandler.handlePanEnd(
          DragEndDetails(localPosition: const Offset(200, 100)),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        var stats = touchHandler.getInputStats();
        expect(stats['totalSwipes'], 1);

        touchHandler.reset();

        stats = touchHandler.getInputStats();
        expect(stats['totalSwipes'], 0);
        expect(stats['validSwipes'], 0);
        expect(stats['invalidSwipes'], 0);
      });
    });
  });
}
