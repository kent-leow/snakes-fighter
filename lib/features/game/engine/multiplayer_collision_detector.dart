import '../../../core/models/position.dart';
import '../models/game_board.dart';
import 'multiplayer_types.dart';

/// Handles collision detection for multiplayer snake games.
/// 
/// This detector checks for all types of collisions that can occur in a
/// multiplayer environment, including wall collisions, self collisions,
/// and collisions between different players' snakes.
class MultiplayerCollisionDetector {
  /// The game board dimensions.
  final GameBoard _board;
  
  /// Creates a new multiplayer collision detector.
  const MultiplayerCollisionDetector(this._board);
  
  /// Checks all possible collisions for all players in a single update cycle.
  /// 
  /// This method processes all player movements simultaneously and detects
  /// collisions including head-to-head collisions between players.
  List<MultiplayerCollisionResult> checkAllCollisions(
    Map<String, MultiplayerSnake> snakes,
    Map<String, SnakeMoveResult> moveResults,
  ) {
    final results = <MultiplayerCollisionResult>[];
    
    // Check each player's potential move for collisions
    for (final entry in moveResults.entries) {
      final playerId = entry.key;
      final moveResult = entry.value;
      final snake = snakes[playerId];
      
      if (snake == null || !snake.alive) continue;
      
      final newHeadPosition = moveResult.newHeadPosition;
      
      // Check wall collision first
      if (_isWallCollision(newHeadPosition)) {
        results.add(MultiplayerCollisionResult(
          playerId: playerId,
          collisionType: MultiplayerCollisionType.wall,
          collisionPoint: newHeadPosition,
          isDead: true,
          metadata: {
            'boundary_type': _getBoundaryType(newHeadPosition),
          },
        ));
        continue;
      }
      
      // Check self collision
      if (_isSelfCollision(snake, newHeadPosition)) {
        results.add(MultiplayerCollisionResult(
          playerId: playerId,
          collisionType: MultiplayerCollisionType.self,
          collisionPoint: newHeadPosition,
          isDead: true,
          metadata: {
            'collision_segment': _findSelfCollisionSegment(snake, newHeadPosition),
          },
        ));
        continue;
      }
      
      // Check collision with other snakes
      final otherSnakeCollision = _checkOtherSnakeCollisions(
        playerId,
        newHeadPosition,
        snakes,
        moveResults,
      );
      
      if (otherSnakeCollision != null) {
        results.add(otherSnakeCollision);
      }
    }
    
    return results;
  }
  
  /// Checks if a position collides with the game boundaries.
  bool _isWallCollision(Position position) {
    return position.x < 0 || 
           position.x >= _board.width || 
           position.y < 0 || 
           position.y >= _board.height;
  }
  
  /// Checks if a snake's new head position collides with its own body.
  bool _isSelfCollision(MultiplayerSnake snake, Position newHeadPosition) {
    // Check against current body positions (excluding the tail if not growing)
    // For simplicity, we'll check against all current body segments
    return snake.positions.contains(newHeadPosition);
  }
  
  /// Checks for collisions with other snakes.
  MultiplayerCollisionResult? _checkOtherSnakeCollisions(
    String playerId,
    Position newHeadPosition,
    Map<String, MultiplayerSnake> snakes,
    Map<String, SnakeMoveResult> moveResults,
  ) {
    for (final entry in snakes.entries) {
      final otherPlayerId = entry.key;
      final otherSnake = entry.value;
      
      // Skip self and dead snakes
      if (otherPlayerId == playerId || !otherSnake.alive) continue;
      
      // Check collision with other snake's body
      for (int i = 0; i < otherSnake.positions.length; i++) {
        if (otherSnake.positions[i] == newHeadPosition) {
          return MultiplayerCollisionResult(
            playerId: playerId,
            collisionType: MultiplayerCollisionType.otherSnake,
            collisionPoint: newHeadPosition,
            isDead: true,
            otherPlayerId: otherPlayerId,
            metadata: {
              'collision_segment_index': i,
              'collision_with_head': i == 0,
            },
          );
        }
      }
      
      // Check head-to-head collision
      final otherMoveResult = moveResults[otherPlayerId];
      if (otherMoveResult != null && 
          otherMoveResult.success &&
          otherMoveResult.newHeadPosition == newHeadPosition) {
        return MultiplayerCollisionResult(
          playerId: playerId,
          collisionType: MultiplayerCollisionType.headToHead,
          collisionPoint: newHeadPosition,
          isDead: true,
          otherPlayerId: otherPlayerId,
          metadata: {
            'collision_type': 'simultaneous_head_collision',
          },
        );
      }
    }
    
    return null;
  }
  
  /// Gets the type of boundary that was hit.
  String _getBoundaryType(Position position) {
    final violations = <String>[];
    
    if (position.x < 0) violations.add('left');
    if (position.x >= _board.width) violations.add('right');
    if (position.y < 0) violations.add('top');
    if (position.y >= _board.height) violations.add('bottom');
    
    return violations.join('+');
  }
  
  /// Finds which segment of the snake's body caused the self collision.
  int _findSelfCollisionSegment(MultiplayerSnake snake, Position collisionPoint) {
    for (int i = 0; i < snake.positions.length; i++) {
      if (snake.positions[i] == collisionPoint) {
        return i;
      }
    }
    return -1; // Should not happen
  }
  
  /// Checks if a position is safe (no collisions would occur).
  bool isPositionSafe(
    Position position,
    Map<String, MultiplayerSnake> snakes,
    {String? excludePlayerId}
  ) {
    // Check wall collision
    if (_isWallCollision(position)) return false;
    
    // Check collision with any snake
    for (final entry in snakes.entries) {
      final playerId = entry.key;
      final snake = entry.value;
      
      // Skip excluded player and dead snakes
      if (playerId == excludePlayerId || !snake.alive) continue;
      
      // Check if position collides with this snake
      if (snake.positions.contains(position)) return false;
    }
    
    return true;
  }
  
  /// Gets all safe positions around a given position.
  List<Position> getSafePositionsAround(
    Position center,
    Map<String, MultiplayerSnake> snakes,
    {String? excludePlayerId}
  ) {
    final safePositions = <Position>[];
    
    // Check all adjacent positions
    for (final neighborPos in center.getNeighbors()) {
      if (isPositionSafe(neighborPos, snakes, excludePlayerId: excludePlayerId)) {
        safePositions.add(neighborPos);
      }
    }
    
    return safePositions;
  }
}
