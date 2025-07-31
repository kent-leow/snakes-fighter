import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/grid_system.dart';
import '../logic/consumption_system.dart';
import '../logic/food_spawner.dart';
import '../logic/growth_system.dart';
import '../logic/movement_system.dart';
import '../models/direction.dart';
import '../models/food.dart';
import '../models/snake.dart';

/// Game states that the controller can be in.
enum GameState {
  /// Game is not yet started.
  idle,

  /// Game is actively running.
  playing,

  /// Game is temporarily paused.
  paused,

  /// Game has ended due to collision or other termination condition.
  gameOver,

  /// Game is being reset.
  resetting,
}

/// Controls the main game loop, snake movement, and game state.
///
/// This controller manages the core game mechanics including:
/// - Game loop timing and updates
/// - Snake movement processing
/// - Game state management
/// - Performance monitoring
class GameController extends ChangeNotifier {
  /// The grid system for the game world.
  final GridSystem _gridSystem;

  /// The movement system for handling snake movement.
  late final MovementSystem _movementSystem;

  /// The main game snake.
  late Snake _snake;

  /// Current food item on the grid.
  Food? _currentFood;

  /// Current game state.
  GameState _gameState = GameState.idle;

  /// Timer for the game loop.
  Timer? _gameTimer;

  /// Target moves per second (game speed).
  double _gameSpeed = 10.0;

  /// Current score.
  int _score = 0;

  /// Performance tracking.
  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _averageFrameTime = 0.0;

  /// Creates a new game controller with the specified grid system.
  GameController({required GridSystem gridSystem}) : _gridSystem = gridSystem {
    _movementSystem = MovementSystem(_gridSystem);
    _initializeGame();
  }

  /// Gets the current game state.
  GameState get gameState => _gameState;

  /// Gets the current snake.
  Snake get snake => _snake;

  /// Gets the current food (if any).
  Food? get currentFood => _currentFood;

  /// Gets the current score.
  int get score => _score;

  /// Gets the current game speed (moves per second).
  double get gameSpeed => _gameSpeed;

  /// Gets the grid system.
  GridSystem get gridSystem => _gridSystem;

  /// Gets the movement system.
  MovementSystem get movementSystem => _movementSystem;

  /// Gets the average frame time in milliseconds.
  double get averageFrameTime => _averageFrameTime;

  /// Gets whether the game is currently running.
  bool get isPlaying => _gameState == GameState.playing;

  /// Gets whether the game is paused.
  bool get isPaused => _gameState == GameState.paused;

  /// Gets whether the game is over.
  bool get isGameOver => _gameState == GameState.gameOver;

  /// Initializes the game to its default state.
  void _initializeGame() {
    // Create snake at center of grid
    final centerPos = _gridSystem.centerPosition;
    _snake = Snake(
      initialPosition: centerPos,
      initialDirection: Direction.right,
    );

    // Spawn initial food
    _spawnFood();

    _score = 0;
    _gameState = GameState.idle;
    _frameCount = 0;
    _lastFrameTime = null;
    _averageFrameTime = 0.0;
  }

  /// Starts the game.
  void startGame() {
    if (_gameState == GameState.playing) return;

    _gameState = GameState.playing;
    _startGameLoop();
    notifyListeners();
  }

  /// Pauses the game.
  void pauseGame() {
    if (_gameState != GameState.playing) return;

    _gameState = GameState.paused;
    _stopGameLoop();
    notifyListeners();
  }

  /// Resumes the game from pause.
  void resumeGame() {
    if (_gameState != GameState.paused) return;

    _gameState = GameState.playing;
    _startGameLoop();
    notifyListeners();
  }

  /// Stops the game and marks it as game over.
  void stopGame() {
    _gameState = GameState.gameOver;
    _stopGameLoop();
    notifyListeners();
  }

  /// Resets the game to initial state.
  void resetGame() {
    _gameState = GameState.resetting;
    _stopGameLoop();

    _initializeGame();
    notifyListeners();
  }

  /// Changes the snake's direction.
  ///
  /// Returns true if the direction change was successful.
  bool changeSnakeDirection(Direction direction) {
    if (_gameState != GameState.playing) return false;

    return _snake.changeDirection(direction);
  }

  /// Sets the game speed (moves per second).
  void setGameSpeed(double speed) {
    if (speed <= 0) return;

    _gameSpeed = speed;

    // Restart timer with new speed if game is running
    if (_gameState == GameState.playing) {
      _stopGameLoop();
      _startGameLoop();
    }

    notifyListeners();
  }

  /// Starts the game loop timer.
  void _startGameLoop() {
    _stopGameLoop(); // Ensure no existing timer

    final interval = Duration(milliseconds: (1000 / _gameSpeed).round());
    _gameTimer = Timer.periodic(interval, (_) => _gameLoop());
  }

  /// Stops the game loop timer.
  void _stopGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// Main game loop that executes each game tick.
  void _gameLoop() {
    if (_gameState != GameState.playing) return;

    final frameStart = DateTime.now();

    // Update snake position
    final moveSuccessful = _movementSystem.updateSnakePosition(_snake);

    if (!moveSuccessful) {
      // Snake hit boundary
      stopGame();
      return;
    }

    // Check for self collision
    if (_snake.collidesWithSelf()) {
      stopGame();
      return;
    }

    // Check for food consumption
    if (_currentFood != null) {
      final consumed = ConsumptionSystem.handleFoodConsumption(
        _snake,
        _currentFood!,
      );

      if (consumed) {
        _score += 10; // Award points for eating food
        _spawnFood(); // Spawn new food
      }
    }

    // Update performance metrics
    _updatePerformanceMetrics(frameStart);

    // Notify listeners of game state change
    notifyListeners();
  }

  /// Spawns a new food item at a random valid position.
  void _spawnFood() {
    final occupiedPositions = _snake.occupiedPositions.toList();
    _currentFood = FoodSpawner.spawnFood(occupiedPositions, _gridSystem);

    // If no food could be spawned, player has won (filled entire grid)
    if (_currentFood == null) {
      stopGame();
    }
  }

  /// Updates performance tracking metrics.
  void _updatePerformanceMetrics(DateTime frameStart) {
    final frameEnd = DateTime.now();
    final frameTime = frameEnd.difference(frameStart).inMicroseconds / 1000.0;

    _frameCount++;

    if (_lastFrameTime != null) {
      // Calculate running average of frame times
      const alpha = 0.1; // Smoothing factor
      _averageFrameTime =
          (_averageFrameTime * (1 - alpha)) + (frameTime * alpha);
    } else {
      _averageFrameTime = frameTime;
    }

    _lastFrameTime = frameEnd;
  }

  /// Forces a single game update (useful for testing).
  void stepGame() {
    if (_gameState == GameState.playing) {
      _gameLoop();
    }
  }

  /// Gets game statistics for debugging and monitoring.
  Map<String, dynamic> getGameStats() {
    return {
      'gameState': _gameState.toString(),
      'snakeLength': _snake.length,
      'score': _score,
      'gameSpeed': _gameSpeed,
      'frameCount': _frameCount,
      'averageFrameTime': _averageFrameTime,
      'snakePosition': _snake.head.toString(),
      'snakeDirection': _snake.currentDirection.toString(),
      'hasFood': _currentFood != null,
      'foodPosition': _currentFood?.position.toString(),
      'foodActive': _currentFood?.isActive ?? false,
    };
  }

  /// Validates the current game state for consistency.
  bool validateGameState() {
    // Check snake is within bounds
    for (final pos in _snake.body) {
      if (!_gridSystem.isValidPosition(pos)) {
        debugPrint('Invalid snake position: $pos');
        return false;
      }
    }

    // Check for self-intersection (game should have ended)
    if (_snake.collidesWithSelf() && _gameState == GameState.playing) {
      debugPrint('Snake is colliding with self but game is still playing');
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }

  @override
  String toString() {
    return 'GameController(state: $_gameState, speed: $_gameSpeed, score: $_score)';
  }
}
