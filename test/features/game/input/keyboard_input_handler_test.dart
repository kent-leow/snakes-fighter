import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/game/input/keyboard_input_handler.dart';
import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  group('KeyboardInputHandler', () {
    late KeyboardInputHandler keyboardHandler;

    setUp(() {
      keyboardHandler = KeyboardInputHandler();
      keyboardHandler.initialize();
      keyboardHandler.activate();
    });

    tearDown(() {
      keyboardHandler.dispose();
    });

    group('initialization', () {
      test('should initialize correctly', () {
        expect(keyboardHandler.isActive, isTrue);
        expect(keyboardHandler.pressedKeys, isEmpty);
      });
    });

    group('arrow key input', () {
      test('should detect arrow up key', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.up);
      });

      test('should detect arrow down key', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowDown,
            physicalKey: PhysicalKeyboardKey.arrowDown,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.down);
      });

      test('should detect arrow left key', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowLeft,
            physicalKey: PhysicalKeyboardKey.arrowLeft,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.left);
      });

      test('should detect arrow right key', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowRight,
            physicalKey: PhysicalKeyboardKey.arrowRight,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.right);
      });
    });

    group('WASD key input', () {
      test('should detect W key as up', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.keyW,
            physicalKey: PhysicalKeyboardKey.keyW,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.up);
      });

      test('should detect S key as down', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.keyS,
            physicalKey: PhysicalKeyboardKey.keyS,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.down);
      });

      test('should detect A key as left', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.keyA,
            physicalKey: PhysicalKeyboardKey.keyA,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.left);
      });

      test('should detect D key as right', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.keyD,
            physicalKey: PhysicalKeyboardKey.keyD,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue);
        expect(detectedDirection, Direction.right);
      });
    });

    group('key state management', () {
      test('should track pressed keys', () {
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        expect(
          keyboardHandler.pressedKeys,
          contains(LogicalKeyboardKey.arrowUp),
        );

        keyboardHandler.handleKeyEvent(
          const KeyUpEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        expect(
          keyboardHandler.pressedKeys,
          isNot(contains(LogicalKeyboardKey.arrowUp)),
        );
      });

      test('should prevent repeated key events', () async {
        int directionCount = 0;

        keyboardHandler.directionStream.listen((direction) {
          directionCount++;
        });

        // First key down should work
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Second key down for same key should be ignored
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(directionCount, 1);
      });

      test('should ignore key repeat events', () async {
        int directionCount = 0;

        keyboardHandler.directionStream.listen((direction) {
          directionCount++;
        });

        // Key down should work
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Key repeat should be handled but not emit direction
        final handled = keyboardHandler.handleKeyEvent(
          const KeyRepeatEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isTrue); // Repeat is handled
        expect(directionCount, 1); // But no additional direction emitted
      });
    });

    group('input throttling', () {
      test('should throttle rapid direction changes', () async {
        int directionCount = 0;

        keyboardHandler.directionStream.listen((direction) {
          directionCount++;
        });

        // First direction change
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Release first key
        keyboardHandler.handleKeyEvent(
          const KeyUpEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Immediate second direction change (should be throttled)
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowRight,
            physicalKey: PhysicalKeyboardKey.arrowRight,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(directionCount, 1); // Only first direction should be processed
      });

      test('should allow direction changes after throttle period', () async {
        int directionCount = 0;

        keyboardHandler.directionStream.listen((direction) {
          directionCount++;
        });

        // First direction change
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Wait for throttle period to pass
        await Future.delayed(const Duration(milliseconds: 60));

        // Release first key
        keyboardHandler.handleKeyEvent(
          const KeyUpEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Second direction change after throttle period
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowRight,
            physicalKey: PhysicalKeyboardKey.arrowRight,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(directionCount, 2); // Both directions should be processed
      });
    });

    group('non-direction keys', () {
      test('should ignore non-direction keys', () async {
        Direction? detectedDirection;

        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        final handled = keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.space,
            physicalKey: PhysicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        expect(handled, isFalse);
        expect(detectedDirection, isNull);
      });
    });

    group('lifecycle management', () {
      test('should not process input when inactive', () async {
        keyboardHandler.deactivate();

        Direction? detectedDirection;
        keyboardHandler.directionStream.listen((direction) {
          detectedDirection = direction;
        });

        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));
        expect(detectedDirection, isNull);
      });

      test('should clear pressed keys when reset', () {
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        expect(keyboardHandler.pressedKeys, isNotEmpty);

        keyboardHandler.reset();

        expect(keyboardHandler.pressedKeys, isEmpty);
      });
    });

    group('statistics', () {
      test('should track input statistics', () async {
        // Valid key press
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.arrowUp,
            physicalKey: PhysicalKeyboardKey.arrowUp,
            timeStamp: Duration.zero,
          ),
        );

        // Invalid key press (non-direction)
        keyboardHandler.handleKeyEvent(
          const KeyDownEvent(
            logicalKey: LogicalKeyboardKey.space,
            physicalKey: PhysicalKeyboardKey.space,
            timeStamp: Duration.zero,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 10));

        final stats = keyboardHandler.getInputStats();
        expect(stats['inputType'], 'keyboard');
        expect(stats['totalKeyPresses'], 2);
        expect(stats['validDirectionKeys'], 1);
        expect(stats['invalidDirectionKeys'], 0);
      });
    });
  });
}
