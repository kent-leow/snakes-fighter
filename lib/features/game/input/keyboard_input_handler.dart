import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/direction.dart';
import 'input_controller_interface.dart';

/// Handles keyboard input for web and desktop platforms.
///
/// This controller processes keyboard events and converts them to direction
/// changes with support for both arrow keys and WASD controls.
class KeyboardInputHandler extends BaseInputController {
  /// Set of currently pressed keys.
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  /// Last time a direction change was processed.
  DateTime? _lastDirectionChange;

  /// Minimum time between direction changes to prevent rapid-fire inputs.
  static const Duration directionChangeThrottle = Duration(milliseconds: 50);

  /// Statistics tracking
  int _totalKeyPresses = 0;
  int _validDirectionKeys = 0;
  int _invalidDirectionKeys = 0;
  Duration _lastKeyPressTime = Duration.zero;

  @override
  bool get isSupported {
    // Keyboard input is supported on web and desktop platforms
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        // Mobile platforms may have keyboards but are primarily touch-based
        return false;
    }
  }

  /// Gets the currently pressed keys (for debugging).
  Set<LogicalKeyboardKey> get pressedKeys => Set.unmodifiable(_pressedKeys);

  /// Handles keyboard key events.
  ///
  /// Returns true if the key was handled, false otherwise.
  bool handleKeyEvent(KeyEvent event) {
    if (!isActive) return false;

    if (event is KeyDownEvent) {
      return _handleKeyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      return _handleKeyUp(event.logicalKey);
    } else if (event is KeyRepeatEvent) {
      return _handleKeyRepeat(event.logicalKey);
    }

    return false;
  }

  /// Handles key down events.
  bool _handleKeyDown(LogicalKeyboardKey key) {
    final pressTime = DateTime.now();

    // Prevent repeated key events
    if (_pressedKeys.contains(key)) return false;

    _pressedKeys.add(key);
    _totalKeyPresses++;
    _lastKeyPressTime = pressTime.difference(DateTime.now());

    // Handle direction keys
    final direction = _keyToDirection(key);
    if (direction != null) {
      return _processDirectionChange(direction, pressTime);
    }

    return false;
  }

  /// Handles key up events.
  bool _handleKeyUp(LogicalKeyboardKey key) {
    _pressedKeys.remove(key);
    return false; // Key up events don't trigger direction changes
  }

  /// Handles key repeat events (when key is held down).
  bool _handleKeyRepeat(LogicalKeyboardKey key) {
    // For direction keys, we ignore repeat events to prevent
    // multiple direction changes from holding a key
    final direction = _keyToDirection(key);
    return direction != null;
  }

  /// Converts a keyboard key to a direction.
  Direction? _keyToDirection(LogicalKeyboardKey key) {
    switch (key) {
      // Arrow keys
      case LogicalKeyboardKey.arrowUp:
        return Direction.up;
      case LogicalKeyboardKey.arrowDown:
        return Direction.down;
      case LogicalKeyboardKey.arrowLeft:
        return Direction.left;
      case LogicalKeyboardKey.arrowRight:
        return Direction.right;

      // WASD keys
      case LogicalKeyboardKey.keyW:
        return Direction.up;
      case LogicalKeyboardKey.keyS:
        return Direction.down;
      case LogicalKeyboardKey.keyA:
        return Direction.left;
      case LogicalKeyboardKey.keyD:
        return Direction.right;

      default:
        return null;
    }
  }

  /// Processes a direction change with throttling.
  bool _processDirectionChange(Direction direction, DateTime pressTime) {
    // Check throttling
    if (_lastDirectionChange != null &&
        pressTime.difference(_lastDirectionChange!) < directionChangeThrottle) {
      _invalidDirectionKeys++;
      debugPrint(
        'KeyboardInputHandler: Direction change throttled for $direction',
      );
      return false;
    }

    _validDirectionKeys++;
    _lastDirectionChange = pressTime;

    debugPrint(
      'KeyboardInputHandler: Valid direction change detected - direction: $direction',
    );
    emitDirection(direction);

    return true;
  }

  /// Clears all pressed keys (useful for focus changes).
  void clearPressedKeys() {
    _pressedKeys.clear();
  }

  @override
  void initializeImpl() {
    debugPrint(
      'KeyboardInputHandler: Initialized with support for platform: $defaultTargetPlatform',
    );
  }

  @override
  void disposeImpl() {
    _pressedKeys.clear();
    debugPrint('KeyboardInputHandler: Disposed');
  }

  @override
  void activateImpl() {
    debugPrint('KeyboardInputHandler: Activated');
  }

  @override
  void deactivateImpl() {
    _pressedKeys.clear();
    debugPrint('KeyboardInputHandler: Deactivated');
  }

  @override
  void resetImpl() {
    _pressedKeys.clear();
    _lastDirectionChange = null;
    _totalKeyPresses = 0;
    _validDirectionKeys = 0;
    _invalidDirectionKeys = 0;
    _lastKeyPressTime = Duration.zero;
    debugPrint('KeyboardInputHandler: Reset');
  }

  @override
  Map<String, dynamic> getInputStats() {
    final successRate = _totalKeyPresses > 0
        ? (_validDirectionKeys / _totalKeyPresses * 100)
        : 0.0;

    return {
      'inputType': 'keyboard',
      'isActive': isActive,
      'isSupported': isSupported,
      'platform': defaultTargetPlatform.name,
      'pressedKeysCount': _pressedKeys.length,
      'totalKeyPresses': _totalKeyPresses,
      'validDirectionKeys': _validDirectionKeys,
      'invalidDirectionKeys': _invalidDirectionKeys,
      'successRate': '${successRate.toStringAsFixed(1)}%',
      'lastDirectionChange': _lastDirectionChange?.toIso8601String(),
      'lastKeyPressTime': '${_lastKeyPressTime.inMilliseconds}ms',
      'throttleMs': directionChangeThrottle.inMilliseconds,
      'supportedKeys': ['Arrow Keys (↑ ↓ ← →)', 'WASD Keys (W A S D)'],
    };
  }
}
