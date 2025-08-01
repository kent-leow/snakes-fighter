import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/direction.dart';
import 'input_controller_interface.dart';
import 'keyboard_input_handler.dart';
import 'touch_input_handler.dart';

/// Manages multiple input controllers and automatically selects the appropriate
/// input method based on platform capabilities and user preferences.
///
/// This manager coordinates between different input controllers (keyboard, touch, etc.)
/// and provides a unified interface for the game to receive input events.
class AdaptiveInputManager {
  /// List of available input controllers.
  final List<InputController> _controllers = [];

  /// Currently active input controller.
  InputController? _activeController;

  /// Stream controller for merged direction events.
  late final StreamController<Direction> _directionController;

  /// List of input subscriptions to clean up.
  final List<StreamSubscription<Direction>> _subscriptions = [];

  /// Whether the manager is initialized.
  bool _isInitialized = false;

  /// Input priority order based on platform.
  static const Map<TargetPlatform, List<Type>> _platformPriority = {
    TargetPlatform.android: [TouchInputHandler, KeyboardInputHandler],
    TargetPlatform.iOS: [TouchInputHandler, KeyboardInputHandler],
    TargetPlatform.fuchsia: [TouchInputHandler, KeyboardInputHandler],
    TargetPlatform.linux: [KeyboardInputHandler, TouchInputHandler],
    TargetPlatform.macOS: [KeyboardInputHandler, TouchInputHandler],
    TargetPlatform.windows: [KeyboardInputHandler, TouchInputHandler],
  };

  AdaptiveInputManager() {
    _directionController = StreamController<Direction>.broadcast();
  }

  /// Stream of direction changes from the active input controller.
  Stream<Direction> get directionStream => _directionController.stream;

  /// Gets the currently active input controller.
  InputController? get activeController => _activeController;

  /// Gets all available input controllers.
  List<InputController> get availableControllers =>
      List.unmodifiable(_controllers);

  /// Gets supported input controllers for the current platform.
  List<InputController> get supportedControllers =>
      _controllers.where((controller) => controller.isSupported).toList();

  /// Whether the manager is initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the adaptive input manager.
  ///
  /// This method creates and initializes all available input controllers,
  /// then selects the most appropriate one for the current platform.
  void initialize() {
    if (_isInitialized) return;

    debugPrint(
      'AdaptiveInputManager: Initializing for platform: $defaultTargetPlatform',
    );

    // Create input controllers
    _controllers.addAll([KeyboardInputHandler(), TouchInputHandler()]);

    // Initialize all controllers
    for (final controller in _controllers) {
      controller.initialize();
    }

    // Select the best controller for the current platform
    _selectBestController();

    _isInitialized = true;
    debugPrint('AdaptiveInputManager: Initialized successfully');
  }

  /// Disposes of the adaptive input manager.
  void dispose() {
    if (!_isInitialized) return;

    // Clean up subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Dispose all controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();

    _directionController.close();
    _activeController = null;
    _isInitialized = false;

    debugPrint('AdaptiveInputManager: Disposed');
  }

  /// Selects the best input controller for the current platform.
  void _selectBestController() {
    final platformPriority =
        _platformPriority[defaultTargetPlatform] ??
        [KeyboardInputHandler, TouchInputHandler];

    InputController? bestController;

    // Find the highest priority supported controller
    for (final controllerType in platformPriority) {
      final controller = _controllers.firstWhere(
        (c) => c.runtimeType == controllerType && c.isSupported,
        orElse: () => throw StateError('Controller not found'),
      );

      if (controller.isSupported) {
        bestController = controller;
        break;
      }
    }

    // Fallback to first supported controller
    bestController ??= _controllers.firstWhere(
      (c) => c.isSupported,
      orElse: () => throw StateError('No supported input controllers found'),
    );

    _setActiveController(bestController);
  }

  /// Sets the active input controller.
  void _setActiveController(InputController controller) {
    if (_activeController == controller) return;

    // Deactivate previous controller
    if (_activeController != null) {
      _activeController!.deactivate();
      debugPrint(
        'AdaptiveInputManager: Deactivated ${_activeController.runtimeType}',
      );
    }

    // Clear existing subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Set new active controller
    _activeController = controller;
    _activeController!.activate();

    // Subscribe to the new controller's direction stream
    final subscription = _activeController!.directionStream.listen(
      (direction) {
        if (!_directionController.isClosed) {
          _directionController.add(direction);
        }
      },
      onError: (error) {
        debugPrint(
          'AdaptiveInputManager: Error from ${_activeController.runtimeType}: $error',
        );
      },
    );
    _subscriptions.add(subscription);

    debugPrint(
      'AdaptiveInputManager: Activated ${_activeController.runtimeType}',
    );
  }

  /// Manually switches to a specific input controller type.
  ///
  /// Returns true if the switch was successful, false otherwise.
  bool switchToController<T extends InputController>() {
    try {
      final controller = _controllers.firstWhere(
        (c) => c is T && c.isSupported,
      );

      if (controller.isSupported) {
        _setActiveController(controller);
        return true;
      }
    } catch (e) {
      debugPrint(
        'AdaptiveInputManager: Controller type $T not found or not supported',
      );
    }

    return false;
  }

  /// Enables all supported input controllers simultaneously.
  ///
  /// This allows multiple input methods to be active at the same time.
  /// Useful for providing maximum accessibility and user choice.
  void enableAllSupportedControllers() {
    // Clear existing subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    final supportedControllers = _controllers
        .where((c) => c.isSupported)
        .toList();

    // Activate all supported controllers
    for (final controller in supportedControllers) {
      controller.activate();

      // Subscribe to each controller's direction stream
      final subscription = controller.directionStream.listen(
        (direction) {
          if (!_directionController.isClosed) {
            _directionController.add(direction);
          }
        },
        onError: (error) {
          debugPrint(
            'AdaptiveInputManager: Error from ${controller.runtimeType}: $error',
          );
        },
      );
      _subscriptions.add(subscription);
    }

    _activeController = null; // No single active controller
    debugPrint(
      'AdaptiveInputManager: Enabled all supported controllers (${supportedControllers.length})',
    );
  }

  /// Resets all input controllers to their initial state.
  void reset() {
    for (final controller in _controllers) {
      controller.reset();
    }
    debugPrint('AdaptiveInputManager: Reset all controllers');
  }

  /// Gets comprehensive input statistics from all controllers.
  Map<String, dynamic> getInputStats() {
    final stats = <String, dynamic>{
      'isInitialized': _isInitialized,
      'currentPlatform': defaultTargetPlatform.name,
      'activeController': _activeController?.runtimeType.toString(),
      'totalControllers': _controllers.length,
      'supportedControllers': supportedControllers.length,
      'platformPriority': _platformPriority[defaultTargetPlatform]
          ?.map((t) => t.toString())
          .toList(),
      'controllers': {},
    };

    // Add stats from each controller
    for (final controller in _controllers) {
      final controllerName = controller.runtimeType.toString();
      stats['controllers'][controllerName] = controller.getInputStats();
    }

    return stats;
  }

  /// Gets a specific input controller by type.
  T? getController<T extends InputController>() {
    try {
      return _controllers.firstWhere((c) => c is T) as T;
    } catch (e) {
      return null;
    }
  }
}
