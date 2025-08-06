
import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/features/game/services/services.dart';

void main() {
  group('Real-time Game State Synchronization Integration', () {
    late GameEventBroadcaster broadcaster;
    late DeltaUpdateService deltaService;

    setUp(() {
      broadcaster = GameEventBroadcaster();
      deltaService = DeltaUpdateService();
    });

    tearDown(() {
      broadcaster.disposeAll();
      deltaService.clearAllStates();
    });

    group('Event Broadcasting System', () {
      test('broadcasts and filters events correctly', () async {
        // Arrange
        const roomId = 'test-room';
        final eventStream = broadcaster.getEventStream(roomId);
        final receivedEvents = <GameEvent>[];
        final subscription = eventStream.listen(receivedEvents.add);

        // Act: Broadcast different types of events
        final moveEvent = PlayerMoveEvent(
          playerId: 'player1',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          direction: Direction.up,
          newHeadPosition: const Position(5, 4),
        );

        final foodEvent = FoodConsumedEvent(
          playerId: 'player1',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          foodPosition: const Position(5, 3),
          newFoodPosition: const Position(8, 8),
          newScore: 5,
        );

        broadcaster.broadcastEvent(roomId, moveEvent);
        broadcaster.broadcastEvent(roomId, foodEvent);

        await Future.delayed(Duration.zero);

        // Assert
        expect(receivedEvents, hasLength(2));
        expect(receivedEvents[0], equals(moveEvent));
        expect(receivedEvents[1], equals(foodEvent));

        // Cleanup
        await subscription.cancel();
      });

      test('filters events by type', () async {
        // Arrange
        const roomId = 'filter-test';

        final moveEventStream = broadcaster
            .getFilteredEventStream<PlayerMoveEvent>(roomId);
        final foodEventStream = broadcaster
            .getFilteredEventStream<FoodConsumedEvent>(roomId);

        final moveEvents = <PlayerMoveEvent>[];
        final foodEvents = <FoodConsumedEvent>[];

        final moveSubscription = moveEventStream.listen(moveEvents.add);
        final foodSubscription = foodEventStream.listen(foodEvents.add);

        // Act: Broadcast mixed events
        broadcaster.broadcastEvent(
          roomId,
          PlayerMoveEvent(
            playerId: 'player1',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            direction: Direction.up,
            newHeadPosition: const Position(5, 4),
          ),
        );

        broadcaster.broadcastEvent(
          roomId,
          FoodConsumedEvent(
            playerId: 'player1',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            foodPosition: const Position(5, 3),
            newFoodPosition: const Position(8, 8),
            newScore: 5,
          ),
        );

        broadcaster.broadcastEvent(
          roomId,
          PlayerDeathEvent(
            playerId: 'player2',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            cause: 'collision',
            finalScore: 0,
          ),
        );

        await Future.delayed(Duration.zero);

        // Assert: Filtered streams only receive relevant events
        expect(moveEvents, hasLength(1));
        expect(foodEvents, hasLength(1));
        expect(moveEvents.first, isA<PlayerMoveEvent>());
        expect(foodEvents.first, isA<FoodConsumedEvent>());

        // Cleanup
        await moveSubscription.cancel();
        await foodSubscription.cancel();
      });

      test('handles concurrent events with proper ordering', () async {
        // Arrange
        const roomId = 'concurrent-test';
        final eventStream = broadcaster.getEventStream(roomId);
        final receivedEvents = <GameEvent>[];
        final subscription = eventStream.listen(receivedEvents.add);

        final baseTime = DateTime.now().millisecondsSinceEpoch;

        // Act: Broadcast events in non-chronological order
        final events = [
          PlayerMoveEvent(
            playerId: 'player1',
            timestamp: baseTime + 100,
            direction: Direction.up,
            newHeadPosition: const Position(5, 4),
          ),
          PlayerMoveEvent(
            playerId: 'player2',
            timestamp: baseTime + 50,
            direction: Direction.right,
            newHeadPosition: const Position(11, 5),
          ),
          FoodConsumedEvent(
            playerId: 'player1',
            timestamp: baseTime + 200,
            foodPosition: const Position(5, 3),
            newFoodPosition: const Position(8, 8),
            newScore: 5,
          ),
        ];

        // Broadcast in non-chronological order
        broadcaster.broadcastEvent(
          roomId,
          events[0],
        ); // timestamp: baseTime + 100
        broadcaster.broadcastEvent(
          roomId,
          events[1],
        ); // timestamp: baseTime + 50
        broadcaster.broadcastEvent(
          roomId,
          events[2],
        ); // timestamp: baseTime + 200

        await Future.delayed(Duration.zero);

        // Assert: Events received in broadcast order (can be sorted by timestamp if needed)
        expect(receivedEvents, hasLength(3));
        expect(receivedEvents[0].timestamp, equals(baseTime + 100));
        expect(receivedEvents[1].timestamp, equals(baseTime + 50));
        expect(receivedEvents[2].timestamp, equals(baseTime + 200));

        // Verify events can be sorted by timestamp for proper ordering
        receivedEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        expect(receivedEvents[0].timestamp, equals(baseTime + 50));
        expect(receivedEvents[1].timestamp, equals(baseTime + 100));
        expect(receivedEvents[2].timestamp, equals(baseTime + 200));

        // Cleanup
        await subscription.cancel();
      });
    });

    group('Delta Update Optimization', () {
      test('optimizes updates using delta calculations', () async {
        // Arrange
        const roomId = 'delta-test-room';

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
          snakes: {
            'player1': const Snake(
              positions: [Position(2, 1)],
              direction: Direction.right,
              score: 5,
            ),
          },
        );

        // Act: Calculate deltas
        final firstDelta = deltaService.calculateDelta(roomId, initialState);
        final secondDelta = deltaService.calculateDelta(roomId, updatedState);

        // Assert: First delta should be complete, second should be minimal
        expect(firstDelta.keys.length, greaterThan(3)); // Complete state
        expect(
          secondDelta.keys.length,
          lessThan(firstDelta.keys.length),
        ); // Delta only

        expect(secondDelta, containsPair('food', anything));
        expect(secondDelta, containsPair('snakes/player1', anything));
      });

      test('calculates snake position deltas efficiently', () {
        // Arrange
        const roomId = 'snake-delta-test';
        const playerId = 'player1';

        const initialSnake = Snake(
          positions: [Position(1, 1)],
          direction: Direction.right,
        );

        const movedSnake = Snake(
          positions: [Position(2, 1)], // Head moved
          direction: Direction.right, // Same direction
        );

        const grownSnake = Snake(
          positions: [Position(3, 1), Position(2, 1)], // Grew by one segment
          direction: Direction.right,
          score: 5, // Score increased
        );

        // Act: Calculate position deltas
        final initialDelta = deltaService.calculateSnakePositionDelta(
          roomId,
          playerId,
          initialSnake,
        );

        // Mock the initial state for comparison
        deltaService.calculateDelta(
          roomId,
          GameState(
            startedAt: DateTime.now(),
            food: const Food(position: Position(5, 5)),
            snakes: {playerId: initialSnake},
          ),
        );

        final moveDelta = deltaService.calculateSnakePositionDelta(
          roomId,
          playerId,
          movedSnake,
        );
        final growthDelta = deltaService.calculateSnakePositionDelta(
          roomId,
          playerId,
          grownSnake,
        );

        // Assert
        expect(
          initialDelta,
          containsPair('snakes/$playerId', anything),
        ); // Complete snake data
        expect(
          moveDelta,
          containsPair('snakes/$playerId/head', anything),
        ); // Just head position
        expect(
          growthDelta,
          containsPair('snakes/$playerId/positions', anything),
        ); // Full positions due to growth
        expect(
          growthDelta,
          containsPair('snakes/$playerId/score', anything),
        ); // Score change
      });

      test('calculates reasonable delta sizes', () {
        // Arrange
        final smallDelta = {
          'snakes/player1/direction': 'up',
          'snakes/player1/score': 5,
        };

        final largeDelta = {
          'food': {
            'position': {'x': 5, 'y': 5},
            'value': 1,
          },
          'snakes': {
            'player1': {
              'positions': [
                {'x': 1, 'y': 1},
                {'x': 1, 'y': 2},
              ],
              'direction': 'right',
              'alive': true,
              'score': 10,
            },
            'player2': {
              'positions': [
                {'x': 5, 'y': 5},
              ],
              'direction': 'up',
              'alive': false,
              'score': 0,
            },
          },
        };

        // Act
        final smallSize = deltaService.calculateDeltaSize(smallDelta);
        final largeSize = deltaService.calculateDeltaSize(largeDelta);

        // Assert
        expect(smallSize, greaterThan(0));
        expect(largeSize, greaterThan(smallSize));
        expect(smallSize, lessThan(100)); // Reasonable small delta size
        expect(largeSize, lessThan(1000)); // Reasonable large delta size
      });

      test('provides useful statistics', () {
        // Arrange
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: const {},
        );

        deltaService.calculateDelta('room1', gameState);
        deltaService.calculateDelta('room2', gameState);

        // Act
        final stats = deltaService.getStats();

        // Assert
        expect(stats['cachedRooms'], equals(2));
        expect(stats['roomIds'], containsAll(['room1', 'room2']));
      });
    });

    group('Event Serialization', () {
      test('serializes and deserializes events correctly', () {
        // Arrange & Act: Test different event types
        const moveEvent = PlayerMoveEvent(
          playerId: 'player1',
          timestamp: 1000,
          direction: Direction.up,
          newHeadPosition: Position(1, 0),
        );

        const foodEvent = FoodConsumedEvent(
          playerId: 'player1',
          timestamp: 2000,
          foodPosition: Position(5, 5),
          newFoodPosition: Position(3, 3),
          newScore: 10,
        );

        const deathEvent = PlayerDeathEvent(
          playerId: 'player2',
          timestamp: 3000,
          cause: 'collision',
          finalScore: 5,
        );

        const startEvent = GameStartEvent(
          playerId: 'host',
          timestamp: 4000,
          roomId: 'room1',
        );

        const endEvent = GameEndEvent(
          playerId: 'host',
          timestamp: 5000,
          roomId: 'room1',
          winnerId: 'player1',
        );

        // Test serialization and deserialization
        final events = [moveEvent, foodEvent, deathEvent, startEvent, endEvent];

        for (final event in events) {
          final json = event.toJson();
          final deserializedEvent = GameEvent.fromJson(json);

          expect(deserializedEvent.runtimeType, equals(event.runtimeType));
          expect(deserializedEvent.playerId, equals(event.playerId));
          expect(deserializedEvent.timestamp, equals(event.timestamp));
        }
      });

      test('handles unknown event types gracefully', () {
        // Arrange
        final json = {
          'type': 'unknownEvent',
          'playerId': 'player1',
          'timestamp': 1000,
        };

        // Act & Assert
        expect(() => GameEvent.fromJson(json), throwsArgumentError);
      });
    });
  });
}
