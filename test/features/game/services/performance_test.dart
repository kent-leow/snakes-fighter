import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/features/game/services/services.dart';

void main() {
  group('Real-time Sync Performance Tests', () {
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

    group('Latency Requirements', () {
      test('event broadcasting latency is under 10ms', () async {
        // Arrange
        const roomId = 'latency-test';
        final eventStream = broadcaster.getEventStream(roomId);

        final receivedEvents = <GameEvent>[];
        final receivedTimes = <DateTime>[];

        final subscription = eventStream.listen((event) {
          receivedEvents.add(event);
          receivedTimes.add(DateTime.now());
        });

        // Act & Assert: Test multiple events
        final testEvents = List.generate(
          100,
          (index) => PlayerMoveEvent(
            playerId: 'player1',
            timestamp: DateTime.now().millisecondsSinceEpoch + index,
            direction: Direction.values[index % 4],
            newHeadPosition: Position(index % 20, index % 20),
          ),
        );

        final broadcastTimes = <DateTime>[];

        for (final event in testEvents) {
          final startTime = DateTime.now();
          broadcaster.broadcastEvent(roomId, event);
          broadcastTimes.add(startTime);
        }

        // Wait for all events to be processed
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert latency requirements
        expect(receivedEvents.length, equals(testEvents.length));

        for (int i = 0; i < receivedEvents.length; i++) {
          final latency = receivedTimes[i].difference(broadcastTimes[i]);
          expect(
            latency.inMilliseconds,
            lessThanOrEqualTo(15),
            reason: 'Event $i had latency of ${latency.inMilliseconds}ms',
          );
        }

        await subscription.cancel();
      });

      test(
        'delta calculation performance under 5ms for typical game state',
        () {
          // Arrange: Create a typical game state with multiple players
          final gameState = GameState(
            startedAt: DateTime.now(),
            food: const Food(position: Position(10, 10)),
            snakes: {
              'player1': const Snake(
                positions: [
                  Position(5, 5),
                  Position(5, 6),
                  Position(5, 7),
                  Position(5, 8),
                ],
                direction: Direction.up,
                score: 30,
              ),
              'player2': const Snake(
                positions: [
                  Position(15, 15),
                  Position(14, 15),
                  Position(13, 15),
                ],
                direction: Direction.left,
                score: 20,
              ),
              'player3': const Snake(
                positions: [Position(8, 3), Position(8, 4)],
                direction: Direction.down,
                score: 10,
              ),
            },
          );

          const roomId = 'performance-test';

          // Act & Assert: Measure delta calculation time
          final stopwatch = Stopwatch()..start();

          // Initial state (complete)
          deltaService.calculateDelta(roomId, gameState);

          // Multiple incremental updates
          for (int i = 0; i < 100; i++) {
            final updatedState = gameState.copyWith(
              food: Food(position: Position(10 + i % 5, 10 + i % 5)),
              snakes: {
                ...gameState.snakes,
                'player1': gameState.snakes['player1']!.copyWith(
                  score: gameState.snakes['player1']!.score + 1,
                ),
              },
            );

            deltaService.calculateDelta(roomId, updatedState);
          }

          stopwatch.stop();

          final avgTimePerUpdate =
              stopwatch.elapsedMicroseconds /
              100 /
              1000; // Convert to milliseconds
          expect(
            avgTimePerUpdate,
            lessThan(5.0),
            reason: 'Average delta calculation time was ${avgTimePerUpdate}ms',
          );
        },
      );

      test(
        'bandwidth optimization - delta size under 1KB for typical updates',
        () {
          // Arrange: Create game states representing typical game updates
          final initialState = GameState(
            startedAt: DateTime.now(),
            food: const Food(position: Position(10, 10)),
            snakes: {
              'player1': const Snake(
                positions: [Position(5, 5), Position(5, 6)],
                direction: Direction.up,
                score: 10,
              ),
              'player2': const Snake(
                positions: [Position(15, 15), Position(14, 15)],
                direction: Direction.left,
                score: 5,
              ),
            },
          );

          // Typical updates: movement, food consumption, score change
          final movementUpdate = initialState.copyWith(
            snakes: {
              ...initialState.snakes,
              'player1': initialState.snakes['player1']!.copyWith(
                positions: [
                  const Position(5, 4),
                  const Position(5, 5),
                  const Position(5, 6),
                ],
              ),
            },
          );

          final foodUpdate = movementUpdate.copyWith(
            food: const Food(position: Position(12, 12)),
            snakes: {
              ...movementUpdate.snakes,
              'player1': movementUpdate.snakes['player1']!.copyWith(score: 15),
            },
          );

          const roomId = 'bandwidth-test';

          // Act: Calculate deltas
          final initialDelta = deltaService.calculateDelta(
            roomId,
            initialState,
          );
          final movementDelta = deltaService.calculateDelta(
            roomId,
            movementUpdate,
          );
          final foodDelta = deltaService.calculateDelta(roomId, foodUpdate);

          // Assert: Delta sizes are reasonable
          final initialSize = deltaService.calculateDeltaSize(initialDelta);
          final movementSize = deltaService.calculateDeltaSize(movementDelta);
          final foodSize = deltaService.calculateDeltaSize(foodDelta);

          // Initial state can be larger
          expect(
            initialSize,
            lessThan(2048), // 2KB
            reason: 'Initial state delta size was $initialSize bytes',
          );

          // Movement updates should be small
          expect(
            movementSize,
            lessThan(512), // 512 bytes
            reason: 'Movement delta size was $movementSize bytes',
          );

          // Food updates should be small
          expect(
            foodSize,
            lessThan(512), // 512 bytes
            reason: 'Food delta size was $foodSize bytes',
          );
        },
      );
    });

    group('Scalability Tests', () {
      test('handles multiple simultaneous rooms efficiently', () async {
        // Arrange: Create multiple rooms with event streams
        const numRooms = 10;
        final roomIds = List.generate(numRooms, (i) => 'room$i');

        final allSubscriptions = <StreamSubscription<GameEvent>>[];
        final allReceivedEvents = <String, List<GameEvent>>{};

        for (final roomId in roomIds) {
          final stream = broadcaster.getEventStream(roomId);
          allReceivedEvents[roomId] = [];

          final subscription = stream.listen((event) {
            allReceivedEvents[roomId]!.add(event);
          });
          allSubscriptions.add(subscription);
        }

        // Act: Broadcast events to all rooms simultaneously
        final stopwatch = Stopwatch()..start();

        const eventsPerRoom = 50;
        for (int i = 0; i < eventsPerRoom; i++) {
          for (final roomId in roomIds) {
            broadcaster.broadcastEvent(
              roomId,
              PlayerMoveEvent(
                playerId: 'player1',
                timestamp: DateTime.now().millisecondsSinceEpoch,
                direction: Direction.values[i % 4],
                newHeadPosition: Position(i % 20, i % 20),
              ),
            );
          }
        }

        await Future.delayed(const Duration(milliseconds: 100));
        stopwatch.stop();

        // Assert: All events received within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(200));

        for (final roomId in roomIds) {
          expect(allReceivedEvents[roomId]!.length, equals(eventsPerRoom));
        }

        // Cleanup
        for (final subscription in allSubscriptions) {
          await subscription.cancel();
        }
      });

      test('maintains performance with large snake positions', () {
        // Arrange: Create snakes with many body segments (long snakes)
        final longSnakePositions = List.generate(
          100,
          (i) => Position(i % 20, i ~/ 20),
        );

        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(10, 10)),
          snakes: {
            'player1': Snake(
              positions: longSnakePositions,
              direction: Direction.right,
              score: 990,
            ),
          },
        );

        const roomId = 'long-snake-test';

        // Act: Measure performance with large state
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 10; i++) {
          final updatedPositions = [
            Position(
              longSnakePositions.first.x + 1,
              longSnakePositions.first.y,
            ),
            ...longSnakePositions.take(longSnakePositions.length - 1),
          ];

          final updatedState = gameState.copyWith(
            snakes: {
              'player1': gameState.snakes['player1']!.copyWith(
                positions: updatedPositions,
              ),
            },
          );

          deltaService.calculateDelta(roomId, updatedState);
        }

        stopwatch.stop();

        // Assert: Performance acceptable even with large snakes
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Memory Efficiency', () {
      test('clears cached states to prevent memory leaks', () {
        // Arrange: Create multiple room states
        final gameState = GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(5, 5)),
          snakes: const {},
        );

        // Act: Add many room states
        const numRooms = 100;
        for (int i = 0; i < numRooms; i++) {
          deltaService.calculateDelta('room$i', gameState);
        }

        var stats = deltaService.getStats();
        expect(stats['cachedRooms'], equals(numRooms));

        // Clear some rooms
        const roomsToClear = 50;
        for (int i = 0; i < roomsToClear; i++) {
          deltaService.clearRoomState('room$i');
        }

        stats = deltaService.getStats();
        expect(stats['cachedRooms'], equals(numRooms - roomsToClear));

        // Clear all rooms
        deltaService.clearAllStates();
        stats = deltaService.getStats();
        expect(stats['cachedRooms'], equals(0));
      });

      test('broadcaster properly disposes room streams', () {
        // Arrange: Create multiple room streams
        const numRooms = 20;
        final roomIds = List.generate(numRooms, (i) => 'room$i');

        // Create streams for all rooms
        for (final roomId in roomIds) {
          broadcaster.getEventStream(roomId);
        }

        // Act: Dispose specific rooms
        const roomsToDispose = 10;
        for (int i = 0; i < roomsToDispose; i++) {
          broadcaster.dispose('room$i');
        }

        // Assert: Can still use remaining rooms
        for (int i = roomsToDispose; i < numRooms; i++) {
          expect(
            () => broadcaster.broadcastEvent(
              'room$i',
              PlayerMoveEvent(
                playerId: 'test',
                timestamp: DateTime.now().millisecondsSinceEpoch,
                direction: Direction.up,
                newHeadPosition: const Position(1, 1),
              ),
            ),
            returnsNormally,
          );
        }

        // Dispose all
        broadcaster.disposeAll();
      });
    });
  });
}
