import '../../../core/models/enums.dart';
import '../../../core/models/player.dart';
import '../../../core/models/position.dart';
import '../models/game_board.dart';
import '../services/game_sync_service.dart';
import 'multiplayer_collision_detector.dart';
import 'multiplayer_types.dart';
import 'win_condition_handler.dart';

/// The main multiplayer game engine that orchestrates all game logic.
///
/// This engine handles initialization, game loop updates, collision detection,
/// win condition evaluation, and state synchronization for multiplayer games.
class MultiplayerGameEngine {
  /// Map of player IDs to their snakes.
  final Map<String, MultiplayerSnake> _snakes = {};

  /// The game board dimensions and constraints.
  final GameBoard _board;

  /// Collision detection system.
  final MultiplayerCollisionDetector _collisionDetector;

  /// Win condition evaluation system.
  final WinConditionHandler _winConditionHandler;

  /// Service for synchronizing game state.
  final GameSyncService _syncService;

  /// Current food position (if any).
  Position? _currentFood;

  /// Game start time for timeout calculations.
  int? _gameStartTime;

  /// Whether the game is currently active.
  bool _isGameActive = false;

  /// Game configuration parameters.
  final GameConfig _config;

  /// Creates a new multiplayer game engine.
  MultiplayerGameEngine({
    required GameBoard board,
    required GameSyncService syncService,
    GameConfig? config,
  }) : _board = board,
       _syncService = syncService,
       _config = config ?? GameConfig.defaultConfig(),
       _collisionDetector = MultiplayerCollisionDetector(board),
       _winConditionHandler = WinConditionHandler();

  /// Initializes the game with the given players.
  ///
  /// Sets up starting positions, directions, and initial game state.
  void initializeGame(Map<String, Player> players) {
    if (players.isEmpty || players.length > 4) {
      throw ArgumentError('Game requires 1-4 players, got ${players.length}');
    }

    _snakes.clear();
    _isGameActive = true;
    _gameStartTime = DateTime.now().millisecondsSinceEpoch;

    final startPositions = _generateStartPositions(players.length);
    final startDirections = _generateStartDirections(players.length);

    int index = 0;
    for (final player in players.values) {
      final snake = MultiplayerSnake(
        positions: [startPositions[index]],
        direction: startDirections[index],
        alive: true,
        score: 0,
        playerId: player.uid,
      );

      _snakes[player.uid] = snake;
      index++;
    }

    // Spawn initial food
    _spawnFood();
  }

  /// Updates the game state for one tick/frame.
  ///
  /// Moves all snakes, checks collisions, evaluates win conditions,
  /// and synchronizes the state across all clients.
  Future<GameUpdateResult> updateGame(String roomId) async {
    if (!_isGameActive) {
      return GameUpdateResult(
        gameEnded: true,
        snakes: Map.from(_snakes),
        metadata: {'error': 'Game not active'},
      );
    }

    final alivePlayers = _snakes.entries
        .where((entry) => entry.value.alive)
        .toList();

    // Quick check: if 0 or 1 players alive, game should end
    if (alivePlayers.length <= 1) {
      final winner = alivePlayers.isNotEmpty ? alivePlayers.first.key : null;
      await _endGame(roomId, winner);

      return GameUpdateResult(
        gameEnded: true,
        winner: winner,
        snakes: Map.from(_snakes),
        metadata: {
          'end_reason': alivePlayers.isEmpty ? 'all_dead' : 'last_survivor',
        },
      );
    }

    // Move all alive snakes and collect move results
    final moveResults = <String, SnakeMoveResult>{};
    for (final entry in alivePlayers) {
      final playerId = entry.key;
      final snake = entry.value;

      final moveResult = _calculateSnakeMove(snake);
      moveResults[playerId] = moveResult;
    }

    // Check for collisions
    final collisionResults = _collisionDetector.checkAllCollisions(
      _snakes,
      moveResults,
    );

    // Apply collision results and move snakes
    final updatedSnakes = <String, MultiplayerSnake>{};
    final collidedPlayers = collisionResults
        .where((result) => result.isDead)
        .map((result) => result.playerId)
        .toSet();

    for (final entry in _snakes.entries) {
      final playerId = entry.key;
      final snake = entry.value;

      if (collidedPlayers.contains(playerId)) {
        // Player died from collision
        updatedSnakes[playerId] = snake.copyWith(alive: false);
      } else if (snake.alive && moveResults.containsKey(playerId)) {
        // Apply successful move
        final moveResult = moveResults[playerId]!;
        if (moveResult.success) {
          var updatedSnake = snake.copyWith(
            positions: moveResult.updatedPositions,
          );

          // Handle food consumption
          if (moveResult.ateFood) {
            updatedSnake = updatedSnake.copyWith(
              score: snake.score + _config.pointsPerFood,
            );
            _spawnFood(); // Spawn new food
          }

          updatedSnakes[playerId] = updatedSnake;
        } else {
          updatedSnakes[playerId] = snake;
        }
      } else {
        updatedSnakes[playerId] = snake;
      }
    }

    _snakes.clear();
    _snakes.addAll(updatedSnakes);

    // Check win conditions
    final winResult = _winConditionHandler.evaluateGameEndWithCriteria(
      _snakes,
      targetScore: _config.targetScore,
      maxGameDurationMs: _config.maxGameDurationMs,
      startTimeMs: _gameStartTime,
    );

    if (winResult.isGameEnded) {
      await _endGame(roomId, winResult.winner);

      return GameUpdateResult(
        gameEnded: true,
        winner: winResult.winner,
        snakes: Map.from(_snakes),
        collisions: collisionResults,
        foodPosition: _currentFood,
        metadata: {
          'end_reason': winResult.endReason?.name,
          'final_scores': winResult.finalScores,
          'player_rankings': winResult.playerRankings
              ?.map((r) => r.toString())
              .toList(),
        },
      );
    }

    // Sync state to all clients
    await _syncGameState(roomId);

    return GameUpdateResult(
      gameEnded: false,
      snakes: Map.from(_snakes),
      collisions: collisionResults,
      foodPosition: _currentFood,
      metadata: {
        'alive_players': winResult.alivePlayers?.length ?? 0,
        'game_duration_ms': _gameStartTime != null
            ? DateTime.now().millisecondsSinceEpoch - _gameStartTime!
            : 0,
      },
    );
  }

  /// Updates a player's direction.
  ///
  /// This is called when a player inputs a direction change.
  bool updatePlayerDirection(String playerId, Direction newDirection) {
    final snake = _snakes[playerId];
    if (snake == null || !snake.alive) return false;

    // Prevent 180-degree turns
    if (!snake.direction.canChangeTo(newDirection)) return false;

    _snakes[playerId] = snake.copyWith(direction: newDirection);
    return true;
  }

  /// Calculates the next move for a snake.
  SnakeMoveResult _calculateSnakeMove(MultiplayerSnake snake) {
    final (dx, dy) = snake.direction.delta;
    final newHeadPosition = Position(snake.head.x + dx, snake.head.y + dy);

    // Create new positions list
    final newPositions = [newHeadPosition, ...snake.positions];

    // Check if food was consumed
    final ateFood = _currentFood != null && newHeadPosition == _currentFood;

    // Remove tail unless food was eaten (snake grows)
    if (!ateFood && newPositions.length > 1) {
      newPositions.removeLast();
    }

    return SnakeMoveResult.success(
      newHeadPosition: newHeadPosition,
      updatedPositions: newPositions,
      ateFood: ateFood,
    );
  }

  /// Generates starting positions for players based on player count.
  List<Position> _generateStartPositions(int playerCount) {
    final positions = <Position>[];
    final boardCenter = _board.center;
    const spacing = 5;

    switch (playerCount) {
      case 1:
        positions.add(boardCenter);
        break;
      case 2:
        positions.addAll([
          Position(boardCenter.x - spacing, boardCenter.y),
          Position(boardCenter.x + spacing, boardCenter.y),
        ]);
        break;
      case 3:
        positions.addAll([
          Position(boardCenter.x, boardCenter.y - spacing),
          Position(boardCenter.x - spacing, boardCenter.y + 3),
          Position(boardCenter.x + spacing, boardCenter.y + 3),
        ]);
        break;
      case 4:
        positions.addAll([
          Position(boardCenter.x - spacing, boardCenter.y - spacing),
          Position(boardCenter.x + spacing, boardCenter.y - spacing),
          Position(boardCenter.x - spacing, boardCenter.y + spacing),
          Position(boardCenter.x + spacing, boardCenter.y + spacing),
        ]);
        break;
      default:
        throw ArgumentError('Unsupported player count: $playerCount');
    }

    // Ensure all positions are within board bounds
    return positions.map((pos) {
      final clampedX = pos.x.clamp(1, _board.width - 2);
      final clampedY = pos.y.clamp(1, _board.height - 2);
      return Position(clampedX, clampedY);
    }).toList();
  }

  /// Generates starting directions for players.
  List<Direction> _generateStartDirections(int playerCount) {
    switch (playerCount) {
      case 1:
        return [Direction.right];
      case 2:
        return [Direction.right, Direction.left];
      case 3:
        return [Direction.down, Direction.up, Direction.up];
      case 4:
        return [Direction.down, Direction.down, Direction.up, Direction.up];
      default:
        return List.filled(playerCount, Direction.right);
    }
  }

  /// Spawns food at a random safe location.
  void _spawnFood() {
    // Get all occupied positions
    final occupiedPositions = <Position>{};
    for (final snake in _snakes.values) {
      occupiedPositions.addAll(snake.positions);
    }

    // Find available positions
    final availablePositions = _board.allPositions
        .where((pos) => !occupiedPositions.contains(pos))
        .toList();

    if (availablePositions.isNotEmpty) {
      availablePositions.shuffle();
      _currentFood = availablePositions.first;
    }
  }

  /// Synchronizes the current game state to all clients.
  Future<void> _syncGameState(String roomId) async {
    // Convert internal state to sync format and send updates
    for (final entry in _snakes.entries) {
      final playerId = entry.key;
      final snake = entry.value;

      await _syncService.syncSnakePositions(
        roomId,
        playerId,
        snake.positions,
        snake.direction,
        snake.alive,
        snake.score,
      );
    }

    // Sync food position if exists
    if (_currentFood != null) {
      // Note: This would need to be implemented in GameSyncService
      // await _syncService.syncFoodPosition(roomId, _currentFood!);
    }
  }

  /// Ends the game and syncs the final state.
  Future<void> _endGame(String roomId, String? winnerId) async {
    _isGameActive = false;
    await _syncService.syncGameEnd(roomId, winnerId);
  }

  /// Gets the current game state snapshot.
  Map<String, dynamic> getGameStateSnapshot() {
    return {
      'snakes': _snakes.map(
        (id, snake) => MapEntry(id, {
          'positions': snake.positions
              .map((p) => {'x': p.x, 'y': p.y})
              .toList(),
          'direction': snake.direction.name,
          'alive': snake.alive,
          'score': snake.score,
        }),
      ),
      'food': _currentFood != null
          ? {'x': _currentFood!.x, 'y': _currentFood!.y}
          : null,
      'isActive': _isGameActive,
      'gameStartTime': _gameStartTime,
    };
  }

  /// Disposes of the engine and cleans up resources.
  void dispose() {
    _snakes.clear();
    _isGameActive = false;
    _currentFood = null;
    _gameStartTime = null;
  }
}

/// Configuration for multiplayer games.
class GameConfig {
  /// Points awarded per food consumed.
  final int pointsPerFood;

  /// Target score to win (null for no score limit).
  final int? targetScore;

  /// Maximum game duration in milliseconds (null for no time limit).
  final int? maxGameDurationMs;

  /// Game tick rate in milliseconds.
  final int tickRateMs;

  const GameConfig({
    required this.pointsPerFood,
    this.targetScore,
    this.maxGameDurationMs,
    required this.tickRateMs,
  });

  /// Creates a default game configuration.
  factory GameConfig.defaultConfig() {
    return const GameConfig(
      pointsPerFood: 1,
      maxGameDurationMs: 300000, // 5 minutes
      tickRateMs: 150, // ~6.7 FPS
    );
  }

  /// Creates a fast-paced game configuration.
  factory GameConfig.fastGame() {
    return const GameConfig(
      pointsPerFood: 2,
      targetScore: 20,
      maxGameDurationMs: 120000, // 2 minutes
      tickRateMs: 100, // 10 FPS
    );
  }
}
