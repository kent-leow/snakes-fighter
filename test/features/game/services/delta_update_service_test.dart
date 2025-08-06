import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/features/game/services/delta_update_service.dart';

void main() {
  group('DeltaUpdateService', () {
    late DeltaUpdateService service;

    setUp(() {
      service = DeltaUpdateService();
    });

    tearDown(() {
      service.clearAllStates();
    });

    group('calculateDelta', () {
      test('returns complete state for first update', () {
        // Arrange
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
            ),
          },
        );

        // Act
        final delta = service.calculateDelta('room1', gameState);

        // Assert
        expect(delta, containsPair('food', gameState.food.toJson()));
        expect(delta, containsPair('snakes', anything));
        expect(delta, containsPair('startedAt', gameState.startedAt.toIso8601String()));
      });

      test('returns only changed fields for subsequent updates', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
            ),
          },
        );

        final updatedState = initialState.copyWith(
          food: const Food(position: Position(7, 7)),
        );

        // Act - First update (complete)
        service.calculateDelta('room1', initialState);
        
        // Second update (delta only)
        final delta = service.calculateDelta('room1', updatedState);

        // Assert
        expect(delta, containsPair('food', updatedState.food.toJson()));
        expect(delta, isNot(containsPair('snakes', anything))); // Unchanged
        expect(delta, isNot(containsPair('startedAt', anything))); // Unchanged
      });

      test('detects snake changes', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
              score: 0,
            ),
          },
        );

        final updatedState = initialState.copyWith(
          snakes: {
            'player1': const Snake(
              positions: [Position(2, 1)], // Moved
              direction: Direction.right,
              score: 5, // Score changed
            ),
          },
        );

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateDelta('room1', updatedState);

        // Assert
        expect(delta, containsPair('snakes/player1', anything));
      });

      test('detects winner change', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {},
        );

        final updatedState = initialState.copyWith(winner: 'player1');

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateDelta('room1', updatedState);

        // Assert
        expect(delta, containsPair('winner', 'player1'));
      });

      test('detects game end', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {},
        );

        final endTime = DateTime.now();
        final updatedState = initialState.copyWith(endedAt: endTime);

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateDelta('room1', updatedState);

        // Assert
        expect(delta, containsPair('endedAt', endTime.toIso8601String()));
      });
    });

    group('calculateSnakePositionDelta', () {
      test('returns complete data for new snake', () {
        // Arrange
        const snake = Snake(
          positions: [Position(1, 1)],
          direction: Direction.right,
        );

        // Act
        final delta = service.calculateSnakePositionDelta('room1', 'player1', snake);

        // Assert
        expect(delta, containsPair('snakes/player1', snake.toJson()));
      });

      test('returns minimal data for existing snake movement', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
              score: 0,
            ),
          },
        );

        const updatedSnake = Snake(
          positions: [Position(2, 1)], // Head moved
          direction: Direction.right, // Same direction
          score: 0, // Same score
        );

        // Act
        service.calculateDelta('room1', initialState); // Set initial state
        final delta = service.calculateSnakePositionDelta('room1', 'player1', updatedSnake);

        // Assert
        expect(delta, containsPair('snakes/player1/head', const Position(2, 1).toJson()));
        expect(delta, isNot(containsPair('snakes/player1/direction', anything))); // Unchanged
        expect(delta, isNot(containsPair('snakes/player1/score', anything))); // Unchanged
      });

      test('includes direction when it changes', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
            ),
          },
        );

        const updatedSnake = Snake(
          positions: [Position(1, 0)], // Moved up
          direction: Direction.up, // Direction changed
        );

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateSnakePositionDelta('room1', 'player1', updatedSnake);

        // Assert
        expect(delta, containsPair('snakes/player1/direction', 'up'));
      });

      test('includes score when it changes', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
              score: 0,
            ),
          },
        );

        const updatedSnake = Snake(
          positions: [Position(2, 1)],
          direction: Direction.right,
          score: 5, // Score changed
        );

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateSnakePositionDelta('room1', 'player1', updatedSnake);

        // Assert
        expect(delta, containsPair('snakes/player1/score', 5));
      });

      test('includes full positions when snake grows', () {
        // Arrange
        final initialState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {
            'player1': const Snake(
              positions: [Position(1, 1)],
              direction: Direction.right,
            ),
          },
        );

        const updatedSnake = Snake(
          positions: [Position(2, 1), Position(1, 1)], // Grew by one segment
          direction: Direction.right,
        );

        // Act
        service.calculateDelta('room1', initialState);
        final delta = service.calculateSnakePositionDelta('room1', 'player1', updatedSnake);

        // Assert
        expect(delta, containsPair('snakes/player1/positions', 
          updatedSnake.positions.map((p) => p.toJson()).toList()));
      });
    });

    group('calculateDeltaSize', () {
      test('estimates delta size correctly', () {
        // Arrange
        final delta = {
          'food': {'position': {'x': 5, 'y': 5}, 'value': 1},
          'snakes/player1/score': 10,
          'winner': 'player1',
        };

        // Act
        final size = service.calculateDeltaSize(delta);

        // Assert
        expect(size, greaterThan(0));
        expect(size, isA<int>());
      });

      test('returns reasonable size for empty delta', () {
        // Arrange
        final delta = <String, dynamic>{};

        // Act
        final size = service.calculateDeltaSize(delta);

        // Assert
        expect(size, equals(10)); // Base JSON overhead
      });
    });

    group('clearRoomState', () {
      test('removes cached state for specific room', () {
        // Arrange
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {},
        );

        service.calculateDelta('room1', gameState);
        service.calculateDelta('room2', gameState);

        // Act
        service.clearRoomState('room1');

        // Assert - Next delta for room1 should be complete, room2 should be delta
        final delta1 = service.calculateDelta('room1', gameState);
        final delta2 = service.calculateDelta('room2', gameState);

        expect(delta1, containsPair('startedAt', anything)); // Complete state
        expect(delta2, isEmpty); // No changes (delta)
      });
    });

    group('clearAllStates', () {
      test('removes all cached states', () {
        // Arrange
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {},
        );

        service.calculateDelta('room1', gameState);
        service.calculateDelta('room2', gameState);

        // Act
        service.clearAllStates();

        // Assert - All deltas should be complete
        final delta1 = service.calculateDelta('room1', gameState);
        final delta2 = service.calculateDelta('room2', gameState);

        expect(delta1, containsPair('startedAt', anything));
        expect(delta2, containsPair('startedAt', anything));
      });
    });

    group('getStats', () {
      test('returns correct statistics', () {
        // Arrange
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: {},
        );

        service.calculateDelta('room1', gameState);
        service.calculateDelta('room2', gameState);

        // Act
        final stats = service.getStats();

        // Assert
        expect(stats['cachedRooms'], equals(2));
        expect(stats['roomIds'], containsAll(['room1', 'room2']));
      });
    });
  });
}
