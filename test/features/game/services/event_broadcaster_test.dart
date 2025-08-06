import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/features/game/services/event_broadcaster.dart';

void main() {
  group('GameEventBroadcaster', () {
    late GameEventBroadcaster broadcaster;

    setUp(() {
      broadcaster = GameEventBroadcaster();
    });

    tearDown(() {
      broadcaster.disposeAll();
    });

    group('getEventStream', () {
      test('creates new stream controller for new room', () {
        // Act
        final stream1 = broadcaster.getEventStream('room1');
        final stream2 = broadcaster.getEventStream('room1');

        // Assert
        expect(stream1, isA<Stream<GameEvent>>());
        expect(stream2, equals(stream1)); // Same stream for same room
      });

      test('creates separate streams for different rooms', () {
        // Act
        final stream1 = broadcaster.getEventStream('room1');
        final stream2 = broadcaster.getEventStream('room2');

        // Assert
        expect(stream1, isA<Stream<GameEvent>>());
        expect(stream2, isA<Stream<GameEvent>>());
        expect(stream1, isNot(equals(stream2)));
      });
    });

    group('broadcastEvent', () {
      test('broadcasts event to all listeners', () async {
        // Arrange
        const roomId = 'room1';
        final event = PlayerMoveEvent(
          playerId: 'player1',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          direction: Direction.up,
          newHeadPosition: const Position(1, 0),
        );

        final stream = broadcaster.getEventStream(roomId);
        final receivedEvents = <GameEvent>[];
        final subscription = stream.listen(receivedEvents.add);

        // Act
        broadcaster.broadcastEvent(roomId, event);
        await Future.delayed(Duration.zero); // Let stream process

        // Assert
        expect(receivedEvents, hasLength(1));
        expect(receivedEvents.first, equals(event));

        // Cleanup
        await subscription.cancel();
      });

      test('does not broadcast to non-existent room', () {
        // This should not throw an error
        expect(
          () => broadcaster.broadcastEvent('nonExistentRoom', 
            PlayerMoveEvent(
              playerId: 'player1',
              timestamp: DateTime.now().millisecondsSinceEpoch,
              direction: Direction.up,
              newHeadPosition: const Position(1, 0),
            ),
          ),
          returnsNormally,
        );
      });
    });

    group('broadcastEvents', () {
      test('broadcasts multiple events in order', () async {
        // Arrange
        const roomId = 'room1';
        final events = [
          PlayerMoveEvent(
            playerId: 'player1',
            timestamp: 1000,
            direction: Direction.up,
            newHeadPosition: const Position(1, 0),
          ),
          FoodConsumedEvent(
            playerId: 'player1',
            timestamp: 2000,
            foodPosition: const Position(5, 5),
            newFoodPosition: const Position(3, 3),
            newScore: 10,
          ),
        ];

        final stream = broadcaster.getEventStream(roomId);
        final receivedEvents = <GameEvent>[];
        final subscription = stream.listen(receivedEvents.add);

        // Act
        broadcaster.broadcastEvents(roomId, events);
        await Future.delayed(Duration.zero); // Let stream process

        // Assert
        expect(receivedEvents, hasLength(2));
        expect(receivedEvents[0], equals(events[0]));
        expect(receivedEvents[1], equals(events[1]));

        // Cleanup
        await subscription.cancel();
      });
    });

    group('getFilteredEventStream', () {
      test('filters events by type', () async {
        // Arrange
        const roomId = 'room1';
        final moveEvent = PlayerMoveEvent(
          playerId: 'player1',
          timestamp: 1000,
          direction: Direction.up,
          newHeadPosition: const Position(1, 0),
        );
        final foodEvent = FoodConsumedEvent(
          playerId: 'player1',
          timestamp: 2000,
          foodPosition: const Position(5, 5),
          newFoodPosition: const Position(3, 3),
          newScore: 10,
        );

        final moveStream = broadcaster.getFilteredEventStream<PlayerMoveEvent>(roomId);
        final receivedMoveEvents = <PlayerMoveEvent>[];
        final subscription = moveStream.listen(receivedMoveEvents.add);

        // Act
        broadcaster.broadcastEvent(roomId, moveEvent);
        broadcaster.broadcastEvent(roomId, foodEvent); // Should be filtered out
        await Future.delayed(Duration.zero); // Let stream process

        // Assert
        expect(receivedMoveEvents, hasLength(1));
        expect(receivedMoveEvents.first, equals(moveEvent));

        // Cleanup
        await subscription.cancel();
      });
    });

    group('hasActiveListeners', () {
      test('returns false for non-existent room', () {
        // Act & Assert
        expect(broadcaster.hasActiveListeners('nonExistentRoom'), isFalse);
      });

      test('returns true when stream has listeners', () async {
        // Arrange
        const roomId = 'room1';
        final stream = broadcaster.getEventStream(roomId);
        final subscription = stream.listen((_) {});

        // Act & Assert
        expect(broadcaster.hasActiveListeners(roomId), isTrue);

        // Cleanup
        await subscription.cancel();
      });
    });

    group('dispose', () {
      test('closes stream controller for specific room', () async {
        // Arrange
        const roomId = 'room1';
        final stream = broadcaster.getEventStream(roomId);
        final events = <GameEvent>[];
        final subscription = stream.listen(events.add);

        // Act
        broadcaster.dispose(roomId);

        // Verify stream is closed by checking if broadcast fails
        expect(broadcaster.hasActiveListeners(roomId), isFalse);

        // Cleanup
        await subscription.cancel();
      });
    });

    group('disposeAll', () {
      test('closes all stream controllers', () {
        // Arrange
        broadcaster.getEventStream('room1');
        broadcaster.getEventStream('room2');

        // Act
        broadcaster.disposeAll();

        // Assert - should not throw errors
        expect(() => broadcaster.broadcastEvent('room1', 
          PlayerMoveEvent(
            playerId: 'player1',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            direction: Direction.up,
            newHeadPosition: const Position(1, 0),
          ),
        ), returnsNormally);
      });
    });
  });

  group('GameEvent', () {
    group('fromJson', () {
      test('creates PlayerMoveEvent from JSON', () {
        // Arrange
        final json = {
          'type': 'playerMove',
          'playerId': 'player1',
          'timestamp': 1000,
          'direction': 'up',
          'newHeadPosition': {'x': 1, 'y': 0},
        };

        // Act
        final event = GameEvent.fromJson(json);

        // Assert
        expect(event, isA<PlayerMoveEvent>());
        final moveEvent = event as PlayerMoveEvent;
        expect(moveEvent.playerId, equals('player1'));
        expect(moveEvent.timestamp, equals(1000));
        expect(moveEvent.direction, equals(Direction.up));
        expect(moveEvent.newHeadPosition, equals(const Position(1, 0)));
      });

      test('creates FoodConsumedEvent from JSON', () {
        // Arrange
        final json = {
          'type': 'foodConsumed',
          'playerId': 'player1',
          'timestamp': 2000,
          'foodPosition': {'x': 5, 'y': 5},
          'newFoodPosition': {'x': 3, 'y': 3},
          'newScore': 10,
        };

        // Act
        final event = GameEvent.fromJson(json);

        // Assert
        expect(event, isA<FoodConsumedEvent>());
        final foodEvent = event as FoodConsumedEvent;
        expect(foodEvent.playerId, equals('player1'));
        expect(foodEvent.timestamp, equals(2000));
        expect(foodEvent.foodPosition, equals(const Position(5, 5)));
        expect(foodEvent.newFoodPosition, equals(const Position(3, 3)));
        expect(foodEvent.newScore, equals(10));
      });

      test('throws error for unknown event type', () {
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

    group('toJson', () {
      test('serializes PlayerMoveEvent correctly', () {
        // Arrange
        final event = PlayerMoveEvent(
          playerId: 'player1',
          timestamp: 1000,
          direction: Direction.up,
          newHeadPosition: const Position(1, 0),
        );

        // Act
        final json = event.toJson();

        // Assert
        expect(json['type'], equals('playerMove'));
        expect(json['playerId'], equals('player1'));
        expect(json['timestamp'], equals(1000));
        expect(json['direction'], equals('up'));
        expect(json['newHeadPosition'], equals({'x': 1, 'y': 0}));
      });

      test('serializes FoodConsumedEvent correctly', () {
        // Arrange
        final event = FoodConsumedEvent(
          playerId: 'player1',
          timestamp: 2000,
          foodPosition: const Position(5, 5),
          newFoodPosition: const Position(3, 3),
          newScore: 10,
        );

        // Act
        final json = event.toJson();

        // Assert
        expect(json['type'], equals('foodConsumed'));
        expect(json['playerId'], equals('player1'));
        expect(json['timestamp'], equals(2000));
        expect(json['foodPosition'], equals({'x': 5, 'y': 5}));
        expect(json['newFoodPosition'], equals({'x': 3, 'y': 3}));
        expect(json['newScore'], equals(10));
      });
    });
  });
}
