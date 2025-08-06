import 'dart:async';

import '../../../core/models/player.dart';
import '../../../core/models/enums.dart';
import '../models/game_board.dart';
import '../services/game_sync_service.dart';
import '../engine/multiplayer_game_engine.dart';
import '../engine/multiplayer_types.dart';

/// Manages the overall flow and lifecycle of multiplayer games.
///
/// This manager coordinates game initialization, the main game loop,
/// state transitions, and cleanup for multiplayer snake games.
class GameFlowManager {
  /// The core game engine.
  MultiplayerGameEngine? _gameEngine;

  /// Service for synchronizing game state.
  final GameSyncService _syncService;

  /// The current game board.
  final GameBoard _gameBoard;

  /// Timer for the main game loop.
  Timer? _gameLoopTimer;

  /// Current game state.
  GameFlowState _currentState = GameFlowState.idle;

  /// Room ID for the current game.
  String? _currentRoomId;

  /// Players in the current game.
  Map<String, Player> _currentPlayers = {};

  /// Stream controller for game state changes.
  final StreamController<GameFlowEvent> _eventController =
      StreamController<GameFlowEvent>.broadcast();

  /// Game configuration.
  final GameConfig _gameConfig;

  /// Creates a new game flow manager.
  GameFlowManager({
    required GameSyncService syncService,
    GameBoard? gameBoard,
    GameConfig? gameConfig,
  }) : _syncService = syncService,
       _gameBoard = gameBoard ?? GameBoard.defaultBoard,
       _gameConfig = gameConfig ?? GameConfig.defaultConfig();

  /// Stream of game flow events.
  Stream<GameFlowEvent> get events => _eventController.stream;

  /// Current game state.
  GameFlowState get currentState => _currentState;

  /// Whether a game is currently active.
  bool get isGameActive => _currentState == GameFlowState.playing;

  /// Whether the manager is ready to start a new game.
  bool get canStartGame => _currentState == GameFlowState.ready;

  /// Current players in the game.
  Map<String, Player> get currentPlayers => Map.unmodifiable(_currentPlayers);

  /// Prepares the manager for a new game with the given players.
  ///
  /// This sets up the game engine and transitions to ready state.
  Future<void> prepareGame(String roomId, Map<String, Player> players) async {
    if (_currentState != GameFlowState.idle) {
      throw StateError('Cannot prepare game in state: $_currentState');
    }

    if (players.isEmpty || players.length > 4) {
      throw ArgumentError('Game requires 1-4 players, got ${players.length}');
    }

    _currentRoomId = roomId;
    _currentPlayers = Map.from(players);

    // Create and initialize game engine
    _gameEngine = MultiplayerGameEngine(
      board: _gameBoard,
      syncService: _syncService,
      config: _gameConfig,
    );

    _transitionToState(GameFlowState.ready);

    _eventController.add(
      GameFlowEvent.gameReady(roomId: roomId, players: _currentPlayers),
    );
  }

  /// Starts the game with the prepared players.
  ///
  /// Initializes the game engine, starts the game loop, and begins gameplay.
  Future<void> startGame() async {
    if (_currentState != GameFlowState.ready) {
      throw StateError('Cannot start game in state: $_currentState');
    }

    if (_gameEngine == null || _currentRoomId == null) {
      throw StateError('Game not properly prepared');
    }

    try {
      // Initialize the game
      _gameEngine!.initializeGame(_currentPlayers);

      // Sync game start
      await _syncService.syncGameStart(_currentRoomId!);

      // Transition to playing state
      _transitionToState(GameFlowState.playing);

      // Start the game loop
      _startGameLoop();

      _eventController.add(
        GameFlowEvent.gameStarted(
          roomId: _currentRoomId!,
          players: _currentPlayers,
        ),
      );
    } catch (e) {
      _eventController.add(
        GameFlowEvent.error(
          message: 'Failed to start game: $e',
          roomId: _currentRoomId,
        ),
      );
      await _cleanup();
    }
  }

  /// Updates a player's movement direction.
  ///
  /// This is called when a player provides input to change direction.
  bool updatePlayerDirection(String playerId, String directionName) {
    if (_gameEngine == null || !isGameActive) return false;

    try {
      final direction = Direction.values.firstWhere(
        (d) => d.name == directionName,
        orElse: () => throw ArgumentError('Invalid direction: $directionName'),
      );

      return _gameEngine!.updatePlayerDirection(playerId, direction);
    } catch (e) {
      _eventController.add(
        GameFlowEvent.error(
          message: 'Failed to update player direction: $e',
          roomId: _currentRoomId,
        ),
      );
      return false;
    }
  }

  /// Pauses the game.
  Future<void> pauseGame() async {
    if (_currentState != GameFlowState.playing) return;

    _stopGameLoop();
    _transitionToState(GameFlowState.paused);

    _eventController.add(GameFlowEvent.gamePaused(roomId: _currentRoomId!));
  }

  /// Resumes a paused game.
  Future<void> resumeGame() async {
    if (_currentState != GameFlowState.paused) return;

    _transitionToState(GameFlowState.playing);
    _startGameLoop();

    _eventController.add(GameFlowEvent.gameResumed(roomId: _currentRoomId!));
  }

  /// Ends the current game.
  Future<void> endGame({String? reason}) async {
    if (!isGameActive && _currentState != GameFlowState.paused) return;

    _stopGameLoop();

    final gameState = _gameEngine?.getGameStateSnapshot();

    _transitionToState(GameFlowState.ended);

    _eventController.add(
      GameFlowEvent.gameEnded(
        roomId: _currentRoomId!,
        reason: reason ?? 'Manual end',
        finalState: gameState,
      ),
    );

    await _cleanup();
  }

  /// Starts the main game loop timer.
  void _startGameLoop() {
    _stopGameLoop(); // Ensure no existing timer

    _gameLoopTimer = Timer.periodic(
      Duration(milliseconds: _gameConfig.tickRateMs),
      _gameLoopTick,
    );
  }

  /// Stops the game loop timer.
  void _stopGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
  }

  /// Executes one tick of the game loop.
  Future<void> _gameLoopTick(Timer timer) async {
    if (_gameEngine == null || _currentRoomId == null) {
      timer.cancel();
      return;
    }

    try {
      final result = await _gameEngine!.updateGame(_currentRoomId!);

      // Broadcast game update event
      _eventController.add(
        GameFlowEvent.gameUpdate(roomId: _currentRoomId!, updateResult: result),
      );

      // Check if game ended
      if (result.gameEnded) {
        _stopGameLoop();
        _transitionToState(GameFlowState.ended);

        _eventController.add(
          GameFlowEvent.gameEnded(
            roomId: _currentRoomId!,
            reason: result.winner != null
                ? 'Player ${result.winner} won'
                : 'Game ended',
            finalState: _gameEngine!.getGameStateSnapshot(),
            winner: result.winner,
          ),
        );

        await _cleanup();
      }
    } catch (e) {
      _eventController.add(
        GameFlowEvent.error(
          message: 'Game loop error: $e',
          roomId: _currentRoomId,
        ),
      );

      await endGame(reason: 'Game loop error');
    }
  }

  /// Transitions to a new game state.
  void _transitionToState(GameFlowState newState) {
    final oldState = _currentState;
    _currentState = newState;

    _eventController.add(
      GameFlowEvent.stateChanged(
        fromState: oldState,
        toState: newState,
        roomId: _currentRoomId,
      ),
    );
  }

  /// Cleans up resources after game ends.
  Future<void> _cleanup() async {
    _stopGameLoop();
    _gameEngine?.dispose();
    _gameEngine = null;
    _currentRoomId = null;
    _currentPlayers.clear();
    _transitionToState(GameFlowState.idle);
  }

  /// Gets the current game state snapshot.
  Map<String, dynamic>? getGameStateSnapshot() {
    return _gameEngine?.getGameStateSnapshot();
  }

  /// Disposes of the manager and cleans up all resources.
  void dispose() {
    _stopGameLoop();
    _gameEngine?.dispose();
    _eventController.close();
  }
}

/// Possible states for the game flow.
enum GameFlowState {
  /// No game is active or prepared.
  idle,

  /// Game is prepared and ready to start.
  ready,

  /// Game is actively running.
  playing,

  /// Game is paused.
  paused,

  /// Game has ended.
  ended,
}

/// Events that can occur during game flow.
abstract class GameFlowEvent {
  /// The room ID associated with this event.
  final String? roomId;

  /// Timestamp when the event occurred.
  final DateTime timestamp;

  GameFlowEvent({required this.roomId, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  /// Game is ready to start.
  factory GameFlowEvent.gameReady({
    required String roomId,
    required Map<String, Player> players,
  }) = _GameReadyEvent;

  /// Game has started.
  factory GameFlowEvent.gameStarted({
    required String roomId,
    required Map<String, Player> players,
  }) = _GameStartedEvent;

  /// Game state updated.
  factory GameFlowEvent.gameUpdate({
    required String roomId,
    required GameUpdateResult updateResult,
  }) = _GameUpdateEvent;

  /// Game was paused.
  factory GameFlowEvent.gamePaused({required String roomId}) = _GamePausedEvent;

  /// Game was resumed.
  factory GameFlowEvent.gameResumed({required String roomId}) =
      _GameResumedEvent;

  /// Game has ended.
  factory GameFlowEvent.gameEnded({
    required String roomId,
    required String reason,
    Map<String, dynamic>? finalState,
    String? winner,
  }) = _GameEndedEvent;

  /// Game state changed.
  factory GameFlowEvent.stateChanged({
    required GameFlowState fromState,
    required GameFlowState toState,
    String? roomId,
  }) = _StateChangedEvent;

  /// An error occurred.
  factory GameFlowEvent.error({required String message, String? roomId}) =
      _ErrorEvent;
}

class _GameReadyEvent extends GameFlowEvent {
  final Map<String, Player> players;

  _GameReadyEvent({required String roomId, required this.players})
    : super(roomId: roomId);

  @override
  String toString() =>
      'GameReadyEvent(roomId: $roomId, players: ${players.length})';
}

class _GameStartedEvent extends GameFlowEvent {
  final Map<String, Player> players;

  _GameStartedEvent({required String roomId, required this.players})
    : super(roomId: roomId);

  @override
  String toString() =>
      'GameStartedEvent(roomId: $roomId, players: ${players.length})';
}

class _GameUpdateEvent extends GameFlowEvent {
  final GameUpdateResult updateResult;

  _GameUpdateEvent({required String roomId, required this.updateResult})
    : super(roomId: roomId);

  @override
  String toString() =>
      'GameUpdateEvent(roomId: $roomId, gameEnded: ${updateResult.gameEnded})';
}

class _GamePausedEvent extends GameFlowEvent {
  _GamePausedEvent({required String roomId}) : super(roomId: roomId);

  @override
  String toString() => 'GamePausedEvent(roomId: $roomId)';
}

class _GameResumedEvent extends GameFlowEvent {
  _GameResumedEvent({required String roomId}) : super(roomId: roomId);

  @override
  String toString() => 'GameResumedEvent(roomId: $roomId)';
}

class _GameEndedEvent extends GameFlowEvent {
  final String reason;
  final Map<String, dynamic>? finalState;
  final String? winner;

  _GameEndedEvent({
    required String roomId,
    required this.reason,
    this.finalState,
    this.winner,
  }) : super(roomId: roomId);

  @override
  String toString() =>
      'GameEndedEvent(roomId: $roomId, reason: $reason, winner: $winner)';
}

class _StateChangedEvent extends GameFlowEvent {
  final GameFlowState fromState;
  final GameFlowState toState;

  _StateChangedEvent({
    required this.fromState,
    required this.toState,
    super.roomId,
  });

  @override
  String toString() =>
      'StateChangedEvent(from: $fromState, to: $toState, roomId: $roomId)';
}

class _ErrorEvent extends GameFlowEvent {
  final String message;

  _ErrorEvent({required this.message, super.roomId});

  @override
  String toString() => 'ErrorEvent(message: $message, roomId: $roomId)';
}
