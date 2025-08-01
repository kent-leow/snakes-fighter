import 'package:flutter/foundation.dart';

/// Represents the different states the game can be in.
enum GameState {
  /// Game is in menu/main screen
  menu,

  /// Game is actively running
  playing,

  /// Game is temporarily paused
  paused,

  /// Game has ended due to collision or completion
  gameOver,

  /// Game is in the process of restarting
  restarting,
}

/// Manages game state transitions and lifecycle.
///
/// This class provides centralized state management for the game,
/// ensuring valid state transitions and proper lifecycle handling.
class GameStateManager extends ChangeNotifier {
  /// Current game state.
  GameState _currentState = GameState.menu;

  /// Previous game state (for state change handling).
  GameState? _previousState;

  /// Timestamp when the current state was entered.
  DateTime _stateEnteredAt = DateTime.now();

  /// History of state changes for debugging.
  final List<StateChange> _stateHistory = [];

  /// Maximum history entries to keep.
  static const int _maxHistoryEntries = 50;

  /// Gets the current game state.
  GameState get currentState => _currentState;

  /// Gets the previous game state.
  GameState? get previousState => _previousState;

  /// Gets how long the current state has been active.
  Duration get timeInCurrentState => DateTime.now().difference(_stateEnteredAt);

  /// Gets the state history for debugging.
  List<StateChange> get stateHistory => List.unmodifiable(_stateHistory);

  /// Transitions to a new game state.
  ///
  /// Returns true if the transition was successful, false if it was invalid.
  bool transitionTo(GameState newState) {
    if (!canTransitionTo(newState)) {
      debugPrint('Invalid state transition: $_currentState -> $newState');
      return false;
    }

    final oldState = _currentState;
    _previousState = oldState;
    _currentState = newState;
    _stateEnteredAt = DateTime.now();

    // Add to history
    _addToHistory(oldState, newState);

    // Handle the state change
    handleStateChange(oldState, newState);

    // Notify listeners
    notifyListeners();

    return true;
  }

  /// Checks if a state transition is valid.
  ///
  /// Defines the valid state machine transitions.
  bool canTransitionTo(GameState newState) {
    // Can't transition to the same state
    if (_currentState == newState) return false;

    switch (_currentState) {
      case GameState.menu:
        return newState == GameState.playing;

      case GameState.playing:
        return newState == GameState.paused ||
            newState == GameState.gameOver ||
            newState == GameState.restarting;

      case GameState.paused:
        return newState == GameState.playing ||
            newState == GameState.gameOver ||
            newState == GameState.restarting ||
            newState == GameState.menu;

      case GameState.gameOver:
        return newState == GameState.menu || newState == GameState.restarting;

      case GameState.restarting:
        return newState == GameState.playing || newState == GameState.menu;
    }
  }

  /// Handles state change logic.
  ///
  /// Override this method to add custom behavior for state transitions.
  void handleStateChange(GameState from, GameState to) {
    debugPrint('Game state changed: $from -> $to');

    switch (to) {
      case GameState.menu:
        _onEnterMenu(from);
        break;
      case GameState.playing:
        _onEnterPlaying(from);
        break;
      case GameState.paused:
        _onEnterPaused(from);
        break;
      case GameState.gameOver:
        _onEnterGameOver(from);
        break;
      case GameState.restarting:
        _onEnterRestarting(from);
        break;
    }
  }

  /// Handles entering menu state.
  void _onEnterMenu(GameState from) {
    // Menu-specific logic can be added here
    debugPrint('Entered menu state from $from');
  }

  /// Handles entering playing state.
  void _onEnterPlaying(GameState from) {
    // Playing-specific logic can be added here
    debugPrint('Started playing from $from');
  }

  /// Handles entering paused state.
  void _onEnterPaused(GameState from) {
    // Pause-specific logic can be added here
    debugPrint('Game paused from $from');
  }

  /// Handles entering game over state.
  void _onEnterGameOver(GameState from) {
    // Game over-specific logic can be added here
    debugPrint('Game ended from $from');
  }

  /// Handles entering restarting state.
  void _onEnterRestarting(GameState from) {
    // Restart-specific logic can be added here
    debugPrint('Game restarting from $from');
  }

  /// Convenience methods for common state checks.
  bool get isInMenu => _currentState == GameState.menu;
  bool get isPlaying => _currentState == GameState.playing;
  bool get isPaused => _currentState == GameState.paused;
  bool get isGameOver => _currentState == GameState.gameOver;
  bool get isRestarting => _currentState == GameState.restarting;

  /// Checks if the game is in an active state (playing or paused).
  bool get isActive => isPlaying || isPaused;

  /// Checks if the game is in a terminal state (game over or menu).
  bool get isTerminal => isGameOver || isInMenu;

  /// Adds a state change to the history.
  void _addToHistory(GameState from, GameState to) {
    _stateHistory.add(
      StateChange(from: from, to: to, timestamp: DateTime.now()),
    );

    // Keep history size manageable
    if (_stateHistory.length > _maxHistoryEntries) {
      _stateHistory.removeAt(0);
    }
  }

  /// Gets state statistics for debugging.
  Map<String, dynamic> getStateStatistics() {
    final stateCount = <GameState, int>{};
    for (final entry in _stateHistory) {
      stateCount[entry.to] = (stateCount[entry.to] ?? 0) + 1;
    }

    return {
      'currentState': _currentState.name,
      'previousState': _previousState?.name,
      'timeInCurrentState': timeInCurrentState.inMilliseconds,
      'totalTransitions': _stateHistory.length,
      'stateCounts': stateCount.map(
        (state, count) => MapEntry(state.name, count),
      ),
    };
  }

  /// Resets the state manager to initial state.
  void reset() {
    _currentState = GameState.menu;
    _previousState = null;
    _stateEnteredAt = DateTime.now();
    _stateHistory.clear();
    notifyListeners();
  }

  @override
  String toString() {
    return 'GameStateManager(current: $_currentState, time: ${timeInCurrentState.inSeconds}s)';
  }
}

/// Represents a state change in the history.
class StateChange {
  final GameState from;
  final GameState to;
  final DateTime timestamp;

  StateChange({required this.from, required this.to, required this.timestamp});

  @override
  String toString() {
    return '$from -> $to at ${timestamp.toIso8601String()}';
  }
}
