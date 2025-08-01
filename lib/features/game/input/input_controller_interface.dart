import 'dart:async';

import '../models/direction.dart';

/// Abstract interface for input controllers that handle different input types.
///
/// This interface provides a unified way to handle input from different sources
/// like keyboard, touch, gamepad, etc. Each implementation handles platform-specific
/// input methods while providing a consistent direction stream.
abstract class InputController {
  /// Stream of direction changes from user input.
  ///
  /// Emits a new Direction whenever the user provides input that should
  /// change the snake's movement direction.
  Stream<Direction> get directionStream;

  /// Stream controller for direction changes.
  StreamController<Direction> get directionController;

  /// Whether this input controller is currently active.
  bool get isActive;

  /// Whether this input controller supports the current platform.
  bool get isSupported;

  /// Initializes the input controller.
  ///
  /// This method should set up any necessary listeners, bindings,
  /// or platform-specific initialization.
  void initialize();

  /// Disposes of the input controller.
  ///
  /// This method should clean up any resources, remove listeners,
  /// and prepare the controller for garbage collection.
  void dispose();

  /// Activates the input controller.
  ///
  /// When activated, the controller should start processing input
  /// and emitting direction changes.
  void activate();

  /// Deactivates the input controller.
  ///
  /// When deactivated, the controller should stop processing input
  /// but remain initialized for potential reactivation.
  void deactivate();

  /// Resets the input controller to its initial state.
  ///
  /// This method should clear any stored input state while keeping
  /// the controller initialized and ready for new input.
  void reset();

  /// Gets input statistics for debugging and monitoring.
  ///
  /// Returns a map containing relevant statistics about input processing,
  /// performance metrics, and current state.
  Map<String, dynamic> getInputStats();
}

/// Base implementation of InputController with common functionality.
///
/// This class provides a foundation for specific input controller implementations
/// with shared functionality like direction stream management and lifecycle handling.
abstract class BaseInputController implements InputController {
  late final StreamController<Direction> _directionController;
  bool _isActive = false;
  bool _isInitialized = false;

  BaseInputController() {
    _directionController = StreamController<Direction>.broadcast();
  }

  @override
  Stream<Direction> get directionStream => _directionController.stream;

  @override
  StreamController<Direction> get directionController => _directionController;

  @override
  bool get isActive => _isActive;

  @override
  void initialize() {
    if (_isInitialized) return;

    _isInitialized = true;
    initializeImpl();
  }

  @override
  void dispose() {
    if (!_isInitialized) return;

    deactivate();
    disposeImpl();
    _directionController.close();
    _isInitialized = false;
  }

  @override
  void activate() {
    if (!_isInitialized) {
      throw StateError('InputController must be initialized before activation');
    }

    if (_isActive) return;

    _isActive = true;
    activateImpl();
  }

  @override
  void deactivate() {
    if (!_isActive) return;

    _isActive = false;
    deactivateImpl();
  }

  @override
  void reset() {
    resetImpl();
  }

  /// Emits a direction change to the stream.
  ///
  /// This method should be called by implementing classes when they
  /// detect a valid direction change from user input.
  void emitDirection(Direction direction) {
    if (_isActive && !_directionController.isClosed) {
      _directionController.add(direction);
    }
  }

  /// Platform-specific initialization implementation.
  ///
  /// Implementing classes should override this method to perform
  /// platform-specific setup tasks.
  void initializeImpl();

  /// Platform-specific disposal implementation.
  ///
  /// Implementing classes should override this method to perform
  /// platform-specific cleanup tasks.
  void disposeImpl();

  /// Platform-specific activation implementation.
  ///
  /// Implementing classes should override this method to start
  /// processing input when the controller is activated.
  void activateImpl();

  /// Platform-specific deactivation implementation.
  ///
  /// Implementing classes should override this method to stop
  /// processing input when the controller is deactivated.
  void deactivateImpl();

  /// Platform-specific reset implementation.
  ///
  /// Implementing classes should override this method to clear
  /// any stored input state.
  void resetImpl();
}
