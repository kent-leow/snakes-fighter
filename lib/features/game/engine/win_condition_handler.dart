import 'multiplayer_types.dart';

/// Handles win condition evaluation for multiplayer games.
/// 
/// This class determines when a multiplayer game should end and
/// who the winner is based on various game ending scenarios.
class WinConditionHandler {
  /// Evaluates whether the game should end and determines the winner.
  /// 
  /// Checks for various end conditions including last survivor,
  /// all players dead, or other custom win conditions.
  GameEndResult evaluateGameEnd(Map<String, MultiplayerSnake> snakes) {
    final aliveSnakes = snakes.entries
        .where((entry) => entry.value.alive)
        .toList();
    
    // Check if all players are dead
    if (aliveSnakes.isEmpty) {
      return GameEndResult(
        isGameEnded: true,
        winner: null,
        endReason: GameEndReason.allPlayersDead,
        finalScores: _calculateFinalScores(snakes),
        playerRankings: _calculatePlayerRankings(snakes),
        metadata: {
          'total_players': snakes.length,
          'survivors': 0,
        },
      );
    }
    
    // Check if only one player is alive (last survivor wins)
    if (aliveSnakes.length == 1) {
      final winner = aliveSnakes.first;
      return GameEndResult(
        isGameEnded: true,
        winner: winner.key,
        endReason: GameEndReason.lastSurvivor,
        finalScores: _calculateFinalScores(snakes),
        playerRankings: _calculatePlayerRankings(snakes),
        metadata: {
          'total_players': snakes.length,
          'survivors': 1,
          'winner_score': winner.value.score,
          'winner_length': winner.value.length,
        },
      );
    }
    
    // Game continues - multiple players still alive
    return GameEndResult(
      isGameEnded: false,
      alivePlayers: aliveSnakes.map((e) => e.key).toList(),
      metadata: {
        'alive_count': aliveSnakes.length,
        'total_players': snakes.length,
      },
    );
  }
  
  /// Evaluates win conditions with additional criteria.
  /// 
  /// This version supports more complex win conditions like
  /// target score or maximum game duration.
  GameEndResult evaluateGameEndWithCriteria(
    Map<String, MultiplayerSnake> snakes, {
    int? targetScore,
    int? maxGameDurationMs,
    int? startTimeMs,
  }) {
    // First check standard win conditions
    final standardResult = evaluateGameEnd(snakes);
    if (standardResult.isGameEnded) {
      return standardResult;
    }
    
    final aliveSnakes = snakes.entries
        .where((entry) => entry.value.alive)
        .toList();
    
    // Check for target score winner
    if (targetScore != null) {
      final scoreWinners = aliveSnakes
          .where((entry) => entry.value.score >= targetScore)
          .toList();
      
      if (scoreWinners.isNotEmpty) {
        // If multiple players reach target score, highest score wins
        final winner = scoreWinners.reduce((a, b) => 
            a.value.score > b.value.score ? a : b);
        
        return GameEndResult(
          isGameEnded: true,
          winner: winner.key,
          endReason: GameEndReason.targetScoreReached,
          finalScores: _calculateFinalScores(snakes),
          playerRankings: _calculatePlayerRankings(snakes),
          metadata: {
            'target_score': targetScore,
            'winner_score': winner.value.score,
            'score_winners_count': scoreWinners.length,
          },
        );
      }
    }
    
    // Check for timeout
    if (maxGameDurationMs != null && startTimeMs != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final elapsedTime = currentTime - startTimeMs;
      
      if (elapsedTime >= maxGameDurationMs) {
        // Game timed out - determine winner by highest score
        final winner = aliveSnakes.isEmpty ? null : 
            aliveSnakes.reduce((a, b) => 
                a.value.score > b.value.score ? a : b);
        
        return GameEndResult(
          isGameEnded: true,
          winner: winner?.key,
          endReason: GameEndReason.timeout,
          finalScores: _calculateFinalScores(snakes),
          playerRankings: _calculatePlayerRankings(snakes),
          metadata: {
            'max_duration_ms': maxGameDurationMs,
            'elapsed_time_ms': elapsedTime,
            'timeout_winner_score': winner?.value.score,
          },
        );
      }
    }
    
    // Game continues
    return standardResult;
  }
  
  /// Calculates final scores for all players.
  Map<String, int> _calculateFinalScores(Map<String, MultiplayerSnake> snakes) {
    return snakes.map((playerId, snake) => 
        MapEntry(playerId, snake.score));
  }
  
  /// Calculates player rankings based on score and survival.
  List<PlayerRanking> _calculatePlayerRankings(Map<String, MultiplayerSnake> snakes) {
    final rankings = snakes.entries.map((entry) {
      return PlayerRanking(
        playerId: entry.key,
        score: entry.value.score,
        length: entry.value.length,
        isAlive: entry.value.alive,
      );
    }).toList();
    
    // Sort by: alive status (alive first), then by score (highest first), then by length
    rankings.sort((a, b) {
      // Alive players rank higher
      if (a.isAlive != b.isAlive) {
        return b.isAlive ? 1 : -1;
      }
      
      // Higher score ranks higher
      if (a.score != b.score) {
        return b.score.compareTo(a.score);
      }
      
      // Longer snake ranks higher (tie breaker)
      return b.length.compareTo(a.length);
    });
    
    // Assign ranks
    for (int i = 0; i < rankings.length; i++) {
      rankings[i] = rankings[i].copyWith(rank: i + 1);
    }
    
    return rankings;
  }
  
  /// Checks if a specific player has won based on custom criteria.
  bool hasPlayerWon(
    String playerId,
    Map<String, MultiplayerSnake> snakes, {
    int? targetScore,
    int? targetLength,
  }) {
    final snake = snakes[playerId];
    if (snake == null || !snake.alive) return false;
    
    // Check target score
    if (targetScore != null && snake.score >= targetScore) {
      return true;
    }
    
    // Check target length
    if (targetLength != null && snake.length >= targetLength) {
      return true;
    }
    
    return false;
  }
}

/// Represents the result of a game end evaluation.
class GameEndResult {
  /// Whether the game has ended.
  final bool isGameEnded;
  
  /// The ID of the winning player (if any).
  final String? winner;
  
  /// The reason the game ended.
  final GameEndReason? endReason;
  
  /// Final scores of all players.
  final Map<String, int>? finalScores;
  
  /// Player rankings from best to worst.
  final List<PlayerRanking>? playerRankings;
  
  /// List of players still alive (if game hasn't ended).
  final List<String>? alivePlayers;
  
  /// Additional metadata about the game end.
  final Map<String, dynamic> metadata;
  
  const GameEndResult({
    required this.isGameEnded,
    this.winner,
    this.endReason,
    this.finalScores,
    this.playerRankings,
    this.alivePlayers,
    this.metadata = const {},
  });
  
  @override
  String toString() {
    if (isGameEnded) {
      return 'GameEndResult(ended: true, winner: $winner, reason: $endReason)';
    } else {
      return 'GameEndResult(ended: false, alive: ${alivePlayers?.length ?? 0})';
    }
  }
}

/// Possible reasons for game ending.
enum GameEndReason {
  /// Only one player remains alive.
  lastSurvivor,
  
  /// All players have died.
  allPlayersDead,
  
  /// Maximum game time reached.
  timeout,
  
  /// A player reached the target score.
  targetScoreReached,
  
  /// A player reached the target length.
  targetLengthReached,
  
  /// Game was manually ended.
  manualEnd,
}

/// Represents a player's ranking at game end.
class PlayerRanking {
  /// The player's ID.
  final String playerId;
  
  /// The player's final score.
  final int score;
  
  /// The player's final snake length.
  final int length;
  
  /// Whether the player was alive at game end.
  final bool isAlive;
  
  /// The player's rank (1st, 2nd, etc.).
  final int rank;
  
  const PlayerRanking({
    required this.playerId,
    required this.score,
    required this.length,
    required this.isAlive,
    this.rank = 0,
  });
  
  /// Creates a copy with updated rank.
  PlayerRanking copyWith({
    String? playerId,
    int? score,
    int? length,
    bool? isAlive,
    int? rank,
  }) {
    return PlayerRanking(
      playerId: playerId ?? this.playerId,
      score: score ?? this.score,
      length: length ?? this.length,
      isAlive: isAlive ?? this.isAlive,
      rank: rank ?? this.rank,
    );
  }
  
  @override
  String toString() {
    return 'PlayerRanking(rank: $rank, player: $playerId, score: $score, length: $length, alive: $isAlive)';
  }
}
