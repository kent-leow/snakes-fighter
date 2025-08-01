import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../models/direction.dart';
import 'input_controller_interface.dart';

/// Handles touch input and swipe gesture detection for mobile devices.
///
/// This controller processes touch gestures and converts them to direction
/// changes with configurable sensitivity and timing thresholds.
class TouchInputHandler extends BaseInputController {
  /// Minimum distance in pixels for a valid swipe gesture.
  static const double defaultMinSwipeDistance = 50.0;

  /// Maximum time allowed for a swipe gesture in milliseconds.
  static const double defaultMaxSwipeTime = 300.0;

  /// Minimum velocity for a swipe gesture in pixels per millisecond.
  static const double defaultMinSwipeVelocity = 0.2;

  double _minSwipeDistance;
  double _maxSwipeTime;
  double _minSwipeVelocity;

  // Touch tracking variables
  Offset? _panStartPosition;
  DateTime? _panStartTime;
  bool _isPanning = false;

  // Statistics tracking
  int _totalSwipes = 0;
  int _validSwipes = 0;
  int _invalidSwipes = 0;
  Duration _lastSwipeTime = Duration.zero;

  TouchInputHandler({
    double minSwipeDistance = defaultMinSwipeDistance,
    double maxSwipeTime = defaultMaxSwipeTime,
    double minSwipeVelocity = defaultMinSwipeVelocity,
  }) : _minSwipeDistance = minSwipeDistance,
       _maxSwipeTime = maxSwipeTime,
       _minSwipeVelocity = minSwipeVelocity;

  @override
  bool get isSupported => true; // Touch is supported on all platforms

  /// Gets the current swipe sensitivity settings.
  double get minSwipeDistance => _minSwipeDistance;
  double get maxSwipeTime => _maxSwipeTime;
  double get minSwipeVelocity => _minSwipeVelocity;

  /// Updates the swipe sensitivity settings.
  void updateSensitivity({
    double? minSwipeDistance,
    double? maxSwipeTime,
    double? minSwipeVelocity,
  }) {
    if (minSwipeDistance != null && minSwipeDistance > 0) {
      _minSwipeDistance = minSwipeDistance;
    }
    if (maxSwipeTime != null && maxSwipeTime > 0) {
      _maxSwipeTime = maxSwipeTime;
    }
    if (minSwipeVelocity != null && minSwipeVelocity > 0) {
      _minSwipeVelocity = minSwipeVelocity;
    }
  }

  /// Handles the start of a pan gesture.
  void handlePanStart(DragStartDetails details) {
    if (!isActive) return;

    _panStartPosition = details.localPosition;
    _panStartTime = DateTime.now();
    _isPanning = true;
  }

  /// Handles updates during a pan gesture.
  void handlePanUpdate(DragUpdateDetails details) {
    if (!isActive || !_isPanning) return;

    // We could add real-time gesture feedback here if needed
    // For now, we wait for the pan end to process the gesture
  }

  /// Handles the end of a pan gesture.
  void handlePanEnd(DragEndDetails details) {
    if (!isActive ||
        !_isPanning ||
        _panStartPosition == null ||
        _panStartTime == null) {
      _resetPanState();
      return;
    }

    final endTime = DateTime.now();
    final panDuration = endTime.difference(_panStartTime!);
    final panDistance = details.localPosition - _panStartPosition!;

    _totalSwipes++;
    _lastSwipeTime = panDuration;

    // Process the swipe gesture
    final direction = _processSwipeGesture(panDistance, panDuration);

    if (direction != null) {
      _validSwipes++;
      emitDirection(direction);
    } else {
      _invalidSwipes++;
    }

    _resetPanState();
  }

  /// Handles tap gestures (could be used for game control).
  void handleTap(TapUpDetails details) {
    if (!isActive) return;

    // For now, tap doesn't emit direction changes
    // This could be extended to support tap-based controls
  }

  /// Processes a swipe gesture and determines the direction.
  Direction? _processSwipeGesture(Offset displacement, Duration duration) {
    final distance = displacement.distance;
    final durationMs = duration.inMilliseconds.toDouble();

    // Validate swipe distance
    if (distance < _minSwipeDistance) {
      debugPrint(
        'TouchInputHandler: Swipe too short: ${distance.toStringAsFixed(1)}px < ${_minSwipeDistance}px',
      );
      return null;
    }

    // Validate swipe timing
    if (durationMs > _maxSwipeTime) {
      debugPrint(
        'TouchInputHandler: Swipe too slow: ${durationMs.toStringAsFixed(1)}ms > ${_maxSwipeTime}ms',
      );
      return null;
    }

    // Validate swipe velocity
    final velocity = distance / durationMs;
    if (velocity < _minSwipeVelocity) {
      debugPrint(
        'TouchInputHandler: Swipe too slow: ${velocity.toStringAsFixed(3)}px/ms < ${_minSwipeVelocity}px/ms',
      );
      return null;
    }

    // Determine primary direction based on displacement
    final direction = _calculatePrimaryDirection(displacement);

    debugPrint(
      'TouchInputHandler: Valid swipe detected - '
      'distance: ${distance.toStringAsFixed(1)}px, '
      'duration: ${durationMs.toStringAsFixed(1)}ms, '
      'velocity: ${velocity.toStringAsFixed(3)}px/ms, '
      'direction: $direction',
    );

    return direction;
  }

  /// Calculates the primary direction from a displacement vector.
  Direction _calculatePrimaryDirection(Offset displacement) {
    final dx = displacement.dx;
    final dy = displacement.dy;

    // Determine if the swipe is primarily horizontal or vertical
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      return dx > 0 ? Direction.right : Direction.left;
    } else {
      // Vertical swipe
      return dy > 0 ? Direction.down : Direction.up;
    }
  }

  /// Resets the pan gesture state.
  void _resetPanState() {
    _panStartPosition = null;
    _panStartTime = null;
    _isPanning = false;
  }

  @override
  void initializeImpl() {
    debugPrint(
      'TouchInputHandler: Initialized with sensitivity - '
      'minDistance: ${_minSwipeDistance}px, '
      'maxTime: ${_maxSwipeTime}ms, '
      'minVelocity: ${_minSwipeVelocity}px/ms',
    );
  }

  @override
  void disposeImpl() {
    _resetPanState();
    debugPrint('TouchInputHandler: Disposed');
  }

  @override
  void activateImpl() {
    debugPrint('TouchInputHandler: Activated');
  }

  @override
  void deactivateImpl() {
    _resetPanState();
    debugPrint('TouchInputHandler: Deactivated');
  }

  @override
  void resetImpl() {
    _resetPanState();
    _totalSwipes = 0;
    _validSwipes = 0;
    _invalidSwipes = 0;
    _lastSwipeTime = Duration.zero;
    debugPrint('TouchInputHandler: Reset');
  }

  @override
  Map<String, dynamic> getInputStats() {
    final successRate = _totalSwipes > 0
        ? (_validSwipes / _totalSwipes * 100)
        : 0.0;

    return {
      'inputType': 'touch',
      'isActive': isActive,
      'isSupported': isSupported,
      'totalSwipes': _totalSwipes,
      'validSwipes': _validSwipes,
      'invalidSwipes': _invalidSwipes,
      'successRate': '${successRate.toStringAsFixed(1)}%',
      'lastSwipeTime': '${_lastSwipeTime.inMilliseconds}ms',
      'isPanning': _isPanning,
      'settings': {
        'minSwipeDistance': '${_minSwipeDistance}px',
        'maxSwipeTime': '${_maxSwipeTime}ms',
        'minSwipeVelocity': '${_minSwipeVelocity}px/ms',
      },
    };
  }
}
