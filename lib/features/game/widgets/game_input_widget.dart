import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/game_controller.dart';
import '../input/adaptive_input_manager.dart';
import '../input/keyboard_input_handler.dart';
import '../input/touch_input_handler.dart';
import '../input/input_controller_interface.dart';
import '../models/direction.dart';
import 'input_feedback_widget.dart';

/// A cross-platform input widget that handles both touch and keyboard input.
///
/// This widget wraps the game canvas and provides unified input handling
/// across different platforms, automatically selecting the best input method
/// and providing visual feedback for user interactions.
class GameInputWidget extends StatefulWidget {
  /// The child widget (typically the game canvas).
  final Widget child;

  /// The game controller to send input commands to.
  final GameController gameController;

  /// Whether to enable visual feedback for input actions.
  final bool enableVisualFeedback;

  /// Whether to enable all supported input methods simultaneously.
  final bool enableAllInputMethods;

  const GameInputWidget({
    super.key,
    required this.child,
    required this.gameController,
    this.enableVisualFeedback = true,
    this.enableAllInputMethods = false,
  });

  @override
  State<GameInputWidget> createState() => _GameInputWidgetState();
}

class _GameInputWidgetState extends State<GameInputWidget> {
  late AdaptiveInputManager _inputManager;
  late FocusNode _focusNode;
  final GlobalKey<InputFeedbackWidgetState> _feedbackKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _inputManager = AdaptiveInputManager();

    _initializeInputManager();
  }

  @override
  void dispose() {
    _inputManager.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initializeInputManager() {
    _inputManager.initialize();

    // Configure input methods based on settings
    if (widget.enableAllInputMethods) {
      _inputManager.enableAllSupportedControllers();
    }

    // Listen to direction changes from the input manager
    _inputManager.directionStream.listen((direction) {
      _handleDirectionInput(direction);
    });
  }

  void _handleDirectionInput(Direction direction) {
    // Send direction to game controller
    final success = widget.gameController.changeSnakeDirection(direction);

    // Show visual feedback if enabled and direction change was accepted
    if (widget.enableVisualFeedback && success) {
      _feedbackKey.currentState?.showDirectionFeedback(direction);
    }
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    final keyboardHandler = _inputManager.getController<KeyboardInputHandler>();
    if (keyboardHandler != null && keyboardHandler.isActive) {
      // Convert RawKeyEvent to KeyEvent for the handler
      if (event is RawKeyDownEvent) {
        keyboardHandler.handleKeyEvent(
          KeyDownEvent(
            logicalKey: event.logicalKey,
            physicalKey: event.physicalKey,
            timeStamp: Duration.zero,
          ),
        );
      } else if (event is RawKeyUpEvent) {
        keyboardHandler.handleKeyEvent(
          KeyUpEvent(
            logicalKey: event.logicalKey,
            physicalKey: event.physicalKey,
            timeStamp: Duration.zero,
          ),
        );
      }
    }
  }

  void _handlePanStart(DragStartDetails details) {
    final touchHandler = _inputManager.getController<TouchInputHandler>();
    if (touchHandler != null && touchHandler.isActive) {
      touchHandler.handlePanStart(details);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final touchHandler = _inputManager.getController<TouchInputHandler>();
    if (touchHandler != null && touchHandler.isActive) {
      touchHandler.handlePanUpdate(details);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final touchHandler = _inputManager.getController<TouchInputHandler>();
    if (touchHandler != null && touchHandler.isActive) {
      touchHandler.handlePanEnd(details);
    }
  }

  void _handleTap(TapUpDetails details) {
    final touchHandler = _inputManager.getController<TouchInputHandler>();
    if (touchHandler != null && touchHandler.isActive) {
      touchHandler.handleTap(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget = widget.child;

    // Wrap with input feedback if enabled
    if (widget.enableVisualFeedback) {
      gameWidget = InputFeedbackWidget(key: _feedbackKey, child: gameWidget);
    }

    // Wrap with gesture detection for touch input
    gameWidget = GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: gameWidget,
    );

    // Wrap with keyboard listener for keyboard input
    gameWidget = RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleRawKeyEvent,
      autofocus: true,
      child: gameWidget,
    );

    return gameWidget;
  }

  /// Gets comprehensive input statistics for debugging.
  Map<String, dynamic> getInputStats() {
    return _inputManager.getInputStats();
  }

  /// Switches to a specific input controller type manually.
  bool switchToInputType<T extends InputController>() {
    return _inputManager.switchToController<T>();
  }

  /// Resets all input controllers.
  void resetInput() {
    _inputManager.reset();
  }

  /// Gets the current active input controller type.
  String? get activeInputType {
    return _inputManager.activeController?.runtimeType.toString();
  }

  /// Gets all supported input controller types.
  List<String> get supportedInputTypes {
    return _inputManager.supportedControllers
        .map((c) => c.runtimeType.toString())
        .toList();
  }
}
