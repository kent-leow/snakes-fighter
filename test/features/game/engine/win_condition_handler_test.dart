import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/enums.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/engine/multiplayer_types.dart';
import 'package:snakes_fight/features/game/engine/win_condition_handler.dart';

void main() {
  group('WinConditionHandler', () {
    late WinConditionHandler handler;

    setUp(() {
      handler = WinConditionHandler();
    });

    group('basic win condition evaluation', () {
      test('should detect last survivor winner', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 10,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: false,
            score: 5,
            playerId: 'player2',
          ),
          'player3': const MultiplayerSnake(
            positions: [Position(15, 15)],
            direction: Direction.up,
            alive: false,
            score: 8,
            playerId: 'player3',
          ),
        };

        final result = handler.evaluateGameEnd(snakes);

        expect(result.isGameEnded, isTrue);
        expect(result.winner, equals('player1'));
        expect(result.endReason, equals(GameEndReason.lastSurvivor));
        expect(result.finalScores, isNotNull);
        expect(result.finalScores!['player1'], equals(10));
        expect(result.finalScores!['player2'], equals(5));
        expect(result.finalScores!['player3'], equals(8));
      });

      test('should detect all players dead', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: false,
            score: 10,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: false,
            score: 5,
            playerId: 'player2',
          ),
        };

        final result = handler.evaluateGameEnd(snakes);

        expect(result.isGameEnded, isTrue);
        expect(result.winner, isNull);
        expect(result.endReason, equals(GameEndReason.allPlayersDead));
      });

      test('should continue game when multiple players alive', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 10,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: true,
            score: 5,
            playerId: 'player2',
          ),
        };

        final result = handler.evaluateGameEnd(snakes);

        expect(result.isGameEnded, isFalse);
        expect(result.alivePlayers, isNotNull);
        expect(result.alivePlayers!.length, equals(2));
        expect(result.alivePlayers, contains('player1'));
        expect(result.alivePlayers, contains('player2'));
      });
    });

    group('extended win condition evaluation', () {
      test('should detect target score winner', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 25,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: true,
            score: 15,
            playerId: 'player2',
          ),
        };

        final result = handler.evaluateGameEndWithCriteria(
          snakes,
          targetScore: 20,
        );

        expect(result.isGameEnded, isTrue);
        expect(result.winner, equals('player1'));
        expect(result.endReason, equals(GameEndReason.targetScoreReached));
      });

      test('should handle multiple players reaching target score', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 25,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: true,
            score: 30,
            playerId: 'player2',
          ),
        };

        final result = handler.evaluateGameEndWithCriteria(
          snakes,
          targetScore: 20,
        );

        expect(result.isGameEnded, isTrue);
        expect(result.winner, equals('player2')); // Higher score wins
        expect(result.endReason, equals(GameEndReason.targetScoreReached));
      });

      test('should detect timeout', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 10,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: true,
            score: 15,
            playerId: 'player2',
          ),
        };

        final startTime =
            DateTime.now().millisecondsSinceEpoch - 61000; // 61 seconds ago
        final result = handler.evaluateGameEndWithCriteria(
          snakes,
          maxGameDurationMs: 60000, // 60 seconds
          startTimeMs: startTime,
        );

        expect(result.isGameEnded, isTrue);
        expect(
          result.winner,
          equals('player2'),
        ); // Higher score wins on timeout
        expect(result.endReason, equals(GameEndReason.timeout));
      });
    });

    group('player rankings', () {
      test('should rank players correctly when game ends', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5), Position(4, 5)],
            direction: Direction.right,
            alive: true,
            score: 10,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.left,
            alive: false,
            score: 15,
            playerId: 'player2',
          ),
          'player3': const MultiplayerSnake(
            positions: [Position(15, 15), Position(14, 15), Position(13, 15)],
            direction: Direction.up,
            alive: false,
            score: 5,
            playerId: 'player3',
          ),
        };

        final result = handler.evaluateGameEnd(snakes);

        expect(result.isGameEnded, isTrue);
        expect(result.winner, equals('player1')); // Only survivor
        expect(result.playerRankings, isNotNull);
        expect(result.playerRankings!.length, equals(3));

        // Player 1 should be ranked first (alive and winner)
        expect(result.playerRankings![0].playerId, equals('player1'));
        expect(result.playerRankings![0].rank, equals(1));
        expect(result.playerRankings![0].isAlive, isTrue);

        // Player 2 should be ranked second (higher score among dead)
        expect(result.playerRankings![1].playerId, equals('player2'));
        expect(result.playerRankings![1].rank, equals(2));
        expect(result.playerRankings![1].isAlive, isFalse);

        // Player 3 should be ranked last (lower score)
        expect(result.playerRankings![2].playerId, equals('player3'));
        expect(result.playerRankings![2].rank, equals(3));
        expect(result.playerRankings![2].isAlive, isFalse);
      });
    });

    group('utility methods', () {
      test('hasPlayerWon should detect score victory', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 25,
            playerId: 'player1',
          ),
        };

        expect(
          handler.hasPlayerWon('player1', snakes, targetScore: 20),
          isTrue,
        );
        expect(
          handler.hasPlayerWon('player1', snakes, targetScore: 30),
          isFalse,
        );
      });

      test('hasPlayerWon should detect length victory', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [
              Position(5, 5),
              Position(4, 5),
              Position(3, 5),
              Position(2, 5),
              Position(1, 5),
            ],
            direction: Direction.right,
            alive: true,
            score: 10,
            playerId: 'player1',
          ),
        };

        expect(
          handler.hasPlayerWon('player1', snakes, targetLength: 4),
          isTrue,
        );
        expect(
          handler.hasPlayerWon('player1', snakes, targetLength: 6),
          isFalse,
        );
      });

      test('hasPlayerWon should return false for dead players', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: false,
            score: 100,
            playerId: 'player1',
          ),
        };

        expect(
          handler.hasPlayerWon('player1', snakes, targetScore: 50),
          isFalse,
        );
      });
    });
  });
}
