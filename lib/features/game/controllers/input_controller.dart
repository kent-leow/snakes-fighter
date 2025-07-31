import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/direction.dart';
import 'game_controller.dart';
import 'game_state_manager.dart';

/// Handles input events and converts them to game actions.
///
/// This controller processes keyboard and touch input, converting them
/// into appropriate game commands like direction changes. It ensures
/// responsive input handling with minimal latency.
class InputController extends ChangeNotifier {
  /// The game controller to send commands to.
  final GameController _gameController;

  /// Set of currently pressed keys.
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  /// Last time a direction change was processed.
  DateTime? _lastDirectionChange;

  /// Minimum time between direction changes (prevents rapid-fire inputs).
  static const Duration _directionChangeThrottle = Duration(milliseconds: 50);

  /// Touch input sensitivity settings.
  double _touchSensitivity = 50.0; // Minimum swipe distance in pixels

  /// Creates a new input controller linked to the given game controller.
  InputController({required GameController gameController})
    : _gameController = gameController;

  /// Gets the current touch sensitivity.
  double get touchSensitivity => _touchSensitivity;

  /// Sets the touch sensitivity for swipe detection.
  void setTouchSensitivity(double sensitivity) {
    if (sensitivity > 0) {
      _touchSensitivity = sensitivity;
      notifyListeners();
    }
  }

  /// Handles keyboard key press events.
  ///
  /// Returns true if the key was handled, false otherwise.
  bool handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      return _handleKeyDown(event.logicalKey);
    } else if (event is KeyUpEvent) {
      return _handleKeyUp(event.logicalKey);
    }
    return false;
  }

  /// Handles key down events.
  bool _handleKeyDown(LogicalKeyboardKey key) {
    // Prevent repeated key events
    if (_pressedKeys.contains(key)) return false;

    _pressedKeys.add(key);

    // Handle direction keys
    final direction = _keyToDirection(key);
    if (direction != null) {
      return _processDirectionChange(direction);
    }

    // Handle game control keys
    switch (key) {
      case LogicalKeyboardKey.space:
        return _handleSpaceKey();
      case LogicalKeyboardKey.escape:
        return _handleEscapeKey();
      case LogicalKeyboardKey.keyR:
        return _handleResetKey();
      default:
        return false;
    }
  }

  /// Handles key up events.
  bool _handleKeyUp(LogicalKeyboardKey key) {
    _pressedKeys.remove(key);
    return false; // Key up events don't trigger game actions
  }

  /// Converts a keyboard key to a direction.
  Direction? _keyToDirection(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
        return Direction.up;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        return Direction.down;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        return Direction.left;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        return Direction.right;
      default:
        return null;
    }
  }

  /// Processes a direction change with throttling.
  bool _processDirectionChange(Direction direction) {
    final now = DateTime.now();

    // Check throttling
    if (_lastDirectionChange != null &&
        now.difference(_lastDirectionChange!) < _directionChangeThrottle) {
      return false;
    }

    // Attempt to change direction
    final success = _gameController.changeSnakeDirection(direction);

    if (success) {
      _lastDirectionChange = now;
      notifyListeners();
    }

    return success;
  }

  /// Handles space key press (pause/resume/start).
  bool _handleSpaceKey() {
    switch (_gameController.currentState) {
      case GameState.menu:
        _gameController.startGame();
        return true;
      case GameState.playing:
        _gameController.pauseGame();
        return true;
      case GameState.paused:
        _gameController.resumeGame();
        return true;
      case GameState.gameOver:
        _gameController.resetGame();
        return true;
      default:
        return false;
    }
  }

  /// Handles escape key press (pause/back).
  bool _handleEscapeKey() {
    switch (_gameController.currentState) {
      case GameState.playing:
        _gameController.pauseGame();
        return true;
      case GameState.paused:
        _gameController.resumeGame();
        return true;
      default:
        return false;
    }
  }

  /// Handles R key press (reset).
  bool _handleResetKey() {
    if (_gameController.currentState == GameState.gameOver ||
        _gameController.currentState == GameState.paused) {
      _gameController.resetGame();
      return true;
    }
    return false;
  }

  /// Handles touch swipe input.
  ///
  /// Converts swipe gestures to direction changes based on the primary
  /// direction of the swipe and minimum distance threshold.
  bool handleSwipe({required double deltaX, required double deltaY}) {
    // Calculate swipe distance
    final distance = (deltaX * deltaX + deltaY * deltaY).abs();

    // Check if swipe meets minimum distance threshold
    if (distance < (_touchSensitivity * _touchSensitivity)) return false;

    // Determine primary direction
    Direction? direction;
    if (deltaX.abs() > deltaY.abs()) {
      // Horizontal swipe
      direction = deltaX > 0 ? Direction.right : Direction.left;
    } else {
      // Vertical swipe
      direction = deltaY > 0 ? Direction.down : Direction.up;
    }

    return _processDirectionChange(direction);
  }

  /// Handles tap input for game control.
  ///
  /// Tap behavior depends on current game state:
  /// - Idle: Start game
  /// - Playing: Pause game
  /// - Paused: Resume game
  /// - Game Over: Reset game
  bool handleTap() {
    return _handleSpaceKey(); // Same logic as space key
  }

  /// Gets the currently pressed keys (for debugging).
  Set<LogicalKeyboardKey> get pressedKeys => Set.unmodifiable(_pressedKeys);

  /// Clears all pressed keys (useful for focus changes).
  void clearPressedKeys() {
    _pressedKeys.clear();
    notifyListeners();
  }

  /// Gets input statistics for debugging.
  Map<String, dynamic> getInputStats() {
    return {
      'pressedKeysCount': _pressedKeys.length,
      'lastDirectionChange': _lastDirectionChange?.toIso8601String(),
      'touchSensitivity': _touchSensitivity,
      'throttleMs': _directionChangeThrottle.inMilliseconds,
    };
  }

  /// Resets input state.
  void reset() {
    _pressedKeys.clear();
    _lastDirectionChange = null;
    notifyListeners();
  }

  @override
  String toString() {
    return 'InputController(pressedKeys: ${_pressedKeys.length}, '
        'sensitivity: $_touchSensitivity)';
  }
}
