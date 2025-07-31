import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/models/position.dart';
import '../../../core/utils/grid_system.dart';
import '../../../core/utils/performance_monitor.dart';
import '../models/direction.dart';
import '../models/food.dart';
import '../models/snake.dart';
import 'game_loop.dart';
import 'game_state_manager.dart';
import 'lifecycle_manager.dart';

/// Main game controller that coordinates all game systems.
///
/// This controller integrates the snake, food, state management,
/// lifecycle management, and performance monitoring into a cohesive
/// game experience using the new architecture.
class GameController extends ChangeNotifier {
  // Core dependencies
  final GridSystem _gridSystem;
  final Random _random = Random();
  
  // New architecture components
  late final GameStateManager _stateManager;
  late final LifecycleManager _lifecycleManager;
  late final GameLoop _gameLoop;
  late final PerformanceMonitor _performanceMonitor;
  
  // Game objects
  late Snake _snake;
  Food? _currentFood;
  
  // Game state
  int _score = 0;
  bool _isDisposed = false;

  /// Creates a new game controller.
  GameController({required GridSystem gridSystem}) : _gridSystem = gridSystem {
    _initializeComponents();
    _setupCallbacks();
  }

  /// Initializes all game components.
  void _initializeComponents() {
    // Initialize game objects
    _snake = Snake(
      initialPosition: _gridSystem.centerPosition,
      initialDirection: Direction.right,
    );
    
    // Initialize architecture components
    _stateManager = GameStateManager();
    _lifecycleManager = LifecycleManager(stateManager: _stateManager);
    _performanceMonitor = PerformanceMonitor();
    
    // Initialize game loop with tick callback
    _gameLoop = GameLoop(onTick: _gameTick);
  }

  /// Sets up callbacks between components.
  void _setupCallbacks() {
    // Listen to state changes
    _stateManager.addListener(_onStateChanged);
  }

  // Public API - Game State
  
  /// Gets the current game state.
  GameState get currentState => _stateManager.currentState;
  
  /// Gets whether the game is currently playing.
  bool get isPlaying => currentState == GameState.playing;
  
  /// Gets whether the game is paused.
  bool get isPaused => currentState == GameState.paused;
  
  /// Gets whether the game is over.
  bool get isGameOver => currentState == GameState.gameOver;

  // Public API - Game Objects
  
  /// Gets the snake.
  Snake get snake => _snake;
  
  /// Gets the current food.
  Food? get currentFood => _currentFood;
  
  /// Gets the current score.
  int get score => _score;
  
  /// Gets the grid system.
  GridSystem get gridSystem => _gridSystem;

  // Public API - Performance
  
  /// Gets the current FPS.
  double get currentFps => _performanceMonitor.getCurrentFps();
  
  /// Gets the average frame time in milliseconds.
  double get averageFrameTime => _performanceMonitor.getAverageFrameTime();

  // Public API - Game Control
  
  /// Starts a new game.
  Future<void> startGame() async {
    if (_isDisposed) return;
    
    try {
      await _lifecycleManager.initialize();
      await _lifecycleManager.startGame();
      _gameLoop.start();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to start game: $error');
    }
  }
  
  /// Pauses the current game.
  Future<void> pauseGame() async {
    if (_isDisposed || !isPlaying) return;
    
    try {
      _gameLoop.pause();
      await _lifecycleManager.pauseGame();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to pause game: $error');
    }
  }
  
  /// Resumes the paused game.
  Future<void> resumeGame() async {
    if (_isDisposed || !isPaused) return;
    
    try {
      await _lifecycleManager.resumeGame();
      _gameLoop.resume();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to resume game: $error');
    }
  }
  
  /// Stops the current game.
  Future<void> stopGame() async {
    if (_isDisposed) return;
    
    try {
      _gameLoop.stop();
      await _lifecycleManager.endGame(finalScore: _score);
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to stop game: $error');
    }
  }
  
  /// Resets the game to start a new session.
  Future<void> resetGame() async {
    if (_isDisposed) return;
    
    try {
      _gameLoop.stop();
      await _lifecycleManager.restartGame();
      _resetGameState();
      _gameLoop.start();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to reset game: $error');
    }
  }

  // Public API - Snake Control
  
  /// Changes the snake's direction.
  bool changeSnakeDirection(Direction direction) {
    if (!isPlaying) return false;
    return _snake.changeDirection(direction);
  }

  // Public API - Validation & Stats
  
  /// Validates the current game state.
  bool validateGameState() {
    // Check if snake is within bounds
    if (!_gridSystem.isValidPosition(_snake.head)) {
      return false;
    }
    
    // Check if food is within bounds (if present)
    if (_currentFood != null && !_gridSystem.isValidPosition(_currentFood!.position)) {
      return false;
    }
    
    return true;
  }
  
  /// Gets comprehensive game statistics.
  Map<String, dynamic> getGameStats() {
    return {
      'gameState': currentState.toString(),
      'snakeLength': _snake.length,
      'score': _score,
      'currentFps': currentFps,
      'averageFrameTime': averageFrameTime,
      'isPerformant': _performanceMonitor.meetsPerformanceRequirements(),
      'sessionDuration': _lifecycleManager.sessionDuration?.inSeconds ?? 0,
    };
  }

  // Private - Game Loop
  
  /// Main game tick callback.
  void _gameTick(Duration elapsed) {
    if (!isPlaying) return;
    
    try {
      // Record performance
      _performanceMonitor.recordFrameTime(elapsed);
      
      // Update snake
      _snake.move();
      
      // Check collisions and spawn food as needed
      _checkCollisions();
      _updateFood();
      
      // Validate game state
      if (!validateGameState()) {
        debugPrint('Invalid game state detected');
        stopGame();
      }
      
    } catch (error) {
      debugPrint('Error in game tick: $error');
    }
  }

  // Private - Game Logic
  
  void _checkCollisions() {
    // Check boundary collision
    if (!_gridSystem.isValidPosition(_snake.head)) {
      stopGame();
      return;
    }
    
    // Check self collision
    if (_snake.collidesWithSelf()) {
      stopGame();
      return;
    }
    
    // Check food collision
    if (_currentFood != null && _snake.head == _currentFood!.position) {
      _onFoodEaten(_currentFood!);
    }
  }
  
  void _updateFood() {
    if (_currentFood == null) {
      _spawnFood();
    }
  }
  
  void _spawnFood() {
    // Simple food spawning - find random empty position
    Position? foodPosition;
    int attempts = 0;
    while (attempts < 100) {
      final position = Position(
        _random.nextInt(_gridSystem.gridWidth),
        _random.nextInt(_gridSystem.gridHeight),
      );
      
      if (!_snake.isBodyAt(position)) {
        foodPosition = position;
        break;
      }
      attempts++;
    }
    
    if (foodPosition != null) {
      _currentFood = Food(position: foodPosition);
    }
  }

  // Private - State Management
  
  void _onStateChanged() {
    debugPrint('Game state changed to: ${currentState}');
    notifyListeners();
  }
  
  void _resetGameState() {
    _score = 0;
    _snake = Snake(
      initialPosition: _gridSystem.centerPosition,
      initialDirection: Direction.right,
    );
    _currentFood = null;
    _performanceMonitor.reset();
  }

  // Private - Game Events
  
  void _onFoodEaten(Food food) {
    _score += 10; // Fixed score per food
    _snake.grow();
    _currentFood = null;
    
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    // Stop game loop
    _gameLoop.dispose();
    
    // Dispose managers
    _lifecycleManager.dispose();
    _performanceMonitor.dispose();
    _stateManager.dispose();
    
    super.dispose();
  }
}
