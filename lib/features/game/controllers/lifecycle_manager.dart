import 'package:flutter/foundation.dart';

import 'game_state_manager.dart';

/// Manages the complete game lifecycle including initialization, cleanup,
/// and state transitions.
///
/// This class coordinates the lifecycle of game components and ensures
/// proper resource management across game sessions.
class LifecycleManager extends ChangeNotifier {
  /// The game state manager.
  final GameStateManager _stateManager;

  /// Callbacks for lifecycle events.
  final Map<LifecycleEvent, List<VoidCallback>> _eventCallbacks = {};

  /// Whether the lifecycle manager is initialized.
  bool _isInitialized = false;

  /// Whether the lifecycle manager is disposed.
  bool _isDisposed = false;

  /// Session start time.
  DateTime? _sessionStartTime;

  /// Session statistics.
  final Map<String, dynamic> _sessionStats = {};

  /// Creates a new lifecycle manager.
  LifecycleManager({required GameStateManager stateManager})
    : _stateManager = stateManager {
    _setupStateListeners();
  }

  /// Gets whether the lifecycle manager is initialized.
  bool get isInitialized => _isInitialized;

  /// Gets the current session duration.
  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// Gets session statistics.
  Map<String, dynamic> get sessionStats => Map.unmodifiable(_sessionStats);

  /// Initializes the game lifecycle.
  ///
  /// This should be called before starting any game session.
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('Initializing game lifecycle...');

    try {
      // Initialize session tracking
      _sessionStartTime = DateTime.now();
      _sessionStats.clear();
      _sessionStats['gamesPlayed'] = 0;
      _sessionStats['totalScore'] = 0;
      _sessionStats['highScore'] = 0;

      // Trigger initialization callbacks
      _triggerCallbacks(LifecycleEvent.initialize);

      _isInitialized = true;

      debugPrint('Game lifecycle initialized successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to initialize game lifecycle: $error');
      rethrow;
    }
  }

  /// Starts a new game session.
  ///
  /// This transitions the game to playing state and triggers
  /// appropriate lifecycle events.
  Future<void> startGame() async {
    if (!_isInitialized) {
      throw StateError('Lifecycle manager not initialized');
    }

    debugPrint('Starting new game session...');

    try {
      // Trigger pre-start callbacks
      _triggerCallbacks(LifecycleEvent.preStart);

      // Transition to playing state
      final success = _stateManager.transitionTo(GameState.playing);
      if (!success) {
        throw StateError(
          'Cannot start game from current state: ${_stateManager.currentState}',
        );
      }

      // Update session stats
      _sessionStats['gamesPlayed'] = (_sessionStats['gamesPlayed'] ?? 0) + 1;

      // Trigger post-start callbacks
      _triggerCallbacks(LifecycleEvent.postStart);

      debugPrint('Game session started successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to start game session: $error');
      rethrow;
    }
  }

  /// Pauses the current game session.
  Future<void> pauseGame() async {
    if (!_stateManager.isPlaying) return;

    debugPrint('Pausing game session...');

    try {
      // Trigger pre-pause callbacks
      _triggerCallbacks(LifecycleEvent.prePause);

      // Transition to paused state
      final success = _stateManager.transitionTo(GameState.paused);
      if (!success) {
        throw StateError(
          'Cannot pause game from current state: ${_stateManager.currentState}',
        );
      }

      // Trigger post-pause callbacks
      _triggerCallbacks(LifecycleEvent.postPause);

      debugPrint('Game session paused successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to pause game session: $error');
      rethrow;
    }
  }

  /// Resumes a paused game session.
  Future<void> resumeGame() async {
    if (!_stateManager.isPaused) return;

    debugPrint('Resuming game session...');

    try {
      // Trigger pre-resume callbacks
      _triggerCallbacks(LifecycleEvent.preResume);

      // Transition to playing state
      final success = _stateManager.transitionTo(GameState.playing);
      if (!success) {
        throw StateError(
          'Cannot resume game from current state: ${_stateManager.currentState}',
        );
      }

      // Trigger post-resume callbacks
      _triggerCallbacks(LifecycleEvent.postResume);

      debugPrint('Game session resumed successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to resume game session: $error');
      rethrow;
    }
  }

  /// Ends the current game session.
  ///
  /// This handles game over scenarios and cleanup.
  Future<void> endGame({int? finalScore}) async {
    if (_stateManager.isGameOver || _stateManager.isInMenu) return;

    debugPrint('Ending game session... (score: $finalScore)');

    try {
      // Trigger pre-end callbacks
      _triggerCallbacks(LifecycleEvent.preEnd);

      // Update session stats
      if (finalScore != null) {
        _sessionStats['totalScore'] =
            (_sessionStats['totalScore'] ?? 0) + finalScore;
        _sessionStats['highScore'] =
            (finalScore > (_sessionStats['highScore'] ?? 0))
            ? finalScore
            : _sessionStats['highScore'];
      }

      // Transition to game over state
      final success = _stateManager.transitionTo(GameState.gameOver);
      if (!success) {
        throw StateError(
          'Cannot end game from current state: ${_stateManager.currentState}',
        );
      }

      // Trigger post-end callbacks
      _triggerCallbacks(LifecycleEvent.postEnd);

      debugPrint('Game session ended successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to end game session: $error');
      rethrow;
    }
  }

  /// Restarts the game session.
  ///
  /// This handles the complete restart process with cleanup.
  Future<void> restartGame() async {
    debugPrint('Restarting game session...');

    try {
      // Trigger pre-restart callbacks
      _triggerCallbacks(LifecycleEvent.preRestart);

      // Transition to restarting state
      var success = _stateManager.transitionTo(GameState.restarting);
      if (!success) {
        throw StateError(
          'Cannot restart game from current state: ${_stateManager.currentState}',
        );
      }

      // Perform cleanup
      await _performCleanup();

      // Transition to playing state
      success = _stateManager.transitionTo(GameState.playing);
      if (!success) {
        throw StateError('Cannot start game after restart');
      }

      // Update session stats
      _sessionStats['gamesPlayed'] = (_sessionStats['gamesPlayed'] ?? 0) + 1;

      // Trigger post-restart callbacks
      _triggerCallbacks(LifecycleEvent.postRestart);

      debugPrint('Game session restarted successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to restart game session: $error');
      rethrow;
    }
  }

  /// Returns to the main menu.
  Future<void> returnToMenu() async {
    debugPrint('Returning to menu...');

    try {
      // Trigger pre-menu callbacks
      _triggerCallbacks(LifecycleEvent.preMenu);

      // If we're playing, pause first then go to menu
      if (_stateManager.currentState == GameState.playing) {
        final pauseSuccess = _stateManager.transitionTo(GameState.paused);
        if (!pauseSuccess) {
          throw StateError(
            'Cannot pause game from current state: ${_stateManager.currentState}',
          );
        }
      }

      // Perform cleanup
      await _performCleanup();

      // Transition to menu state
      final success = _stateManager.transitionTo(GameState.menu);
      if (!success) {
        throw StateError(
          'Cannot return to menu from current state: ${_stateManager.currentState}',
        );
      }

      // Trigger post-menu callbacks
      _triggerCallbacks(LifecycleEvent.postMenu);

      debugPrint('Returned to menu successfully');
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to return to menu: $error');
      rethrow;
    }
  }

  /// Registers a callback for a lifecycle event.
  void registerCallback(LifecycleEvent event, VoidCallback callback) {
    _eventCallbacks.putIfAbsent(event, () => []).add(callback);
  }

  /// Unregisters a callback for a lifecycle event.
  void unregisterCallback(LifecycleEvent event, VoidCallback callback) {
    _eventCallbacks[event]?.remove(callback);
  }

  /// Clears all callbacks for an event.
  void clearCallbacks(LifecycleEvent event) {
    _eventCallbacks[event]?.clear();
  }

  /// Sets up listeners for state manager changes.
  void _setupStateListeners() {
    _stateManager.addListener(() {
      // React to state changes if needed
      debugPrint('State changed to: ${_stateManager.currentState}');
    });
  }

  /// Triggers callbacks for a lifecycle event.
  void _triggerCallbacks(LifecycleEvent event) {
    final callbacks = _eventCallbacks[event];
    if (callbacks == null) return;

    for (final callback in callbacks) {
      try {
        callback();
      } catch (error) {
        debugPrint('Error in lifecycle callback for $event: $error');
      }
    }
  }

  /// Performs cleanup operations.
  Future<void> _performCleanup() async {
    debugPrint('Performing lifecycle cleanup...');

    // Trigger cleanup callbacks
    _triggerCallbacks(LifecycleEvent.cleanup);

    // Add any additional cleanup logic here
    await Future.delayed(
      const Duration(milliseconds: 50),
    ); // Brief pause for cleanup
  }

  /// Gets comprehensive lifecycle statistics.
  Map<String, dynamic> getLifecycleStats() {
    return {
      'isInitialized': _isInitialized,
      'currentState': _stateManager.currentState.name,
      'sessionDuration': sessionDuration?.inSeconds,
      'sessionStats': Map.from(_sessionStats),
      'stateStats': _stateManager.getStateStatistics(),
    };
  }

  /// Disposes of the lifecycle manager and cleans up resources.
  @override
  void dispose() {
    if (_isDisposed) return; // Prevent multiple dispose calls

    debugPrint('Disposing lifecycle manager...');

    _isDisposed = true;

    // Trigger disposal callbacks
    _triggerCallbacks(LifecycleEvent.dispose);

    // Clear all callbacks
    _eventCallbacks.clear();

    // Reset state
    _isInitialized = false;
    _sessionStartTime = null;
    _sessionStats.clear();

    super.dispose();
  }

  @override
  String toString() {
    return 'LifecycleManager('
        'initialized: $_isInitialized, '
        'state: ${_stateManager.currentState}'
        ')';
  }
}

/// Lifecycle events that can be registered for callbacks.
enum LifecycleEvent {
  /// Game lifecycle is being initialized
  initialize,

  /// Game is about to start
  preStart,

  /// Game has started
  postStart,

  /// Game is about to pause
  prePause,

  /// Game has paused
  postPause,

  /// Game is about to resume
  preResume,

  /// Game has resumed
  postResume,

  /// Game is about to end
  preEnd,

  /// Game has ended
  postEnd,

  /// Game is about to restart
  preRestart,

  /// Game has restarted
  postRestart,

  /// About to return to menu
  preMenu,

  /// Returned to menu
  postMenu,

  /// Cleanup is being performed
  cleanup,

  /// Manager is being disposed
  dispose,
}
