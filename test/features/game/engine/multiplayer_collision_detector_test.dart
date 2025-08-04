import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/enums.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/engine/multiplayer_collision_detector.dart';
import 'package:snakes_fight/features/game/engine/multiplayer_types.dart';
import 'package:snakes_fight/features/game/models/game_board.dart';

void main() {
  group('MultiplayerCollisionDetector', () {
    late MultiplayerCollisionDetector detector;
    late GameBoard board;

    setUp(() {
      board = const GameBoard(width: 20, height: 20);
      detector = MultiplayerCollisionDetector(board);
    });

    group('wall collision detection', () {
      test('should detect collision with left wall', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(1, 10)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(-1, 10), // Out of bounds
            updatedPositions: const [Position(-1, 10)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        expect(results.length, equals(1));
        expect(results.first.playerId, equals('player1'));
        expect(results.first.collisionType, equals(MultiplayerCollisionType.wall));
        expect(results.first.isDead, isTrue);
      });

      test('should detect collision with right wall', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(18, 10)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(20, 10), // Out of bounds
            updatedPositions: const [Position(20, 10)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        expect(results.length, equals(1));
        expect(results.first.collisionType, equals(MultiplayerCollisionType.wall));
      });
    });

    group('self collision detection', () {
      test('should detect self collision', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [
              Position(5, 5),
              Position(4, 5),
              Position(3, 5),
              Position(3, 6),
              Position(4, 6),
              Position(5, 6),
            ],
            direction: Direction.down,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(5, 6), // Hits own body
            updatedPositions: const [Position(5, 6)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        expect(results.length, equals(1));
        expect(results.first.collisionType, equals(MultiplayerCollisionType.self));
        expect(results.first.isDead, isTrue);
      });

      test('should not detect self collision for valid move', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5), Position(4, 5), Position(3, 5)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(6, 5),
            updatedPositions: const [Position(6, 5), Position(5, 5), Position(4, 5)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        expect(results.length, equals(0));
      });
    });

    group('multi-player collision detection', () {
      test('should detect collision with other snake body', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(6, 6), Position(6, 5), Position(7, 5)],
            direction: Direction.up,
            alive: true,
            score: 0,
            playerId: 'player2',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(6, 5), // Hits player2's body
            updatedPositions: const [Position(6, 5)],
          ),
          'player2': SnakeMoveResult.success(
            newHeadPosition: const Position(6, 7),
            updatedPositions: const [Position(6, 7), Position(6, 6), Position(6, 5)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        expect(results.length, equals(1));
        expect(results.first.playerId, equals('player1'));
        expect(results.first.collisionType, equals(MultiplayerCollisionType.otherSnake));
        expect(results.first.otherPlayerId, equals('player2'));
        expect(results.first.isDead, isTrue);
      });

      test('should detect head-to-head collision', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
          'player2': const MultiplayerSnake(
            positions: [Position(7, 5)],
            direction: Direction.left,
            alive: true,
            score: 0,
            playerId: 'player2',
          ),
        };

        final moveResults = <String, SnakeMoveResult>{
          'player1': SnakeMoveResult.success(
            newHeadPosition: const Position(6, 5),
            updatedPositions: const [Position(6, 5)],
          ),
          'player2': SnakeMoveResult.success(
            newHeadPosition: const Position(6, 5), // Same position
            updatedPositions: const [Position(6, 5)],
          ),
        };

        final results = detector.checkAllCollisions(snakes, moveResults);

        // Both players should have head-to-head collision
        expect(results.length, equals(2));
        expect(results.every((r) => r.collisionType == MultiplayerCollisionType.headToHead), isTrue);
        expect(results.every((r) => r.isDead), isTrue);
      });
    });

    group('utility methods', () {
      test('isPositionSafe should return false for wall positions', () {
        final snakes = <String, MultiplayerSnake>{};

        expect(detector.isPositionSafe(const Position(-1, 5), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(20, 5), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(5, -1), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(5, 20), snakes), isFalse);
      });

      test('isPositionSafe should return false for occupied positions', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(5, 5), Position(4, 5), Position(3, 5)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        expect(detector.isPositionSafe(const Position(5, 5), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(4, 5), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(3, 5), snakes), isFalse);
        expect(detector.isPositionSafe(const Position(6, 5), snakes), isTrue);
      });

      test('getSafePositionsAround should return valid safe positions', () {
        final snakes = <String, MultiplayerSnake>{
          'player1': const MultiplayerSnake(
            positions: [Position(10, 10)],
            direction: Direction.right,
            alive: true,
            score: 0,
            playerId: 'player1',
          ),
        };

        final safePositions = detector.getSafePositionsAround(
          const Position(12, 12),
          snakes,
        );

        expect(safePositions.length, equals(4));
        expect(safePositions, contains(const Position(12, 11))); // up
        expect(safePositions, contains(const Position(13, 12))); // right
        expect(safePositions, contains(const Position(12, 13))); // down
        expect(safePositions, contains(const Position(11, 12))); // left
      });
    });
  });
}
