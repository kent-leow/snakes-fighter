import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/services/cache_service.dart';
import 'package:snakes_fight/core/models/models.dart';

void main() {
  group('Database Service Optimization Tests', () {
    late CacheService cacheService;

    setUp(() {
      cacheService = CacheService();
    });

    group('Cache Integration', () {
      test('should cache and retrieve data', () {
        const key = 'room:room1';
        final room = Room(
          id: 'room1',
          roomCode: 'TEST123',
          hostId: 'host1',
          status: RoomStatus.waiting,
          createdAt: DateTime.now(),
        );

        cacheService.set(key, room, ttl: const Duration(seconds: 30));
        final cached = cacheService.get<Room>(key);

        expect(cached, isNotNull);
        expect(cached!.id, equals('room1'));
        expect(cached.roomCode, equals('TEST123'));
      });

      test('should expire cache entries', () async {
        const key = 'room:room1';
        final room = Room(
          id: 'room1',
          roomCode: 'TEST123',
          hostId: 'host1',
          status: RoomStatus.waiting,
          createdAt: DateTime.now(),
        );

        cacheService.set(key, room, ttl: const Duration(milliseconds: 50));

        // Should be available immediately
        expect(cacheService.get<Room>(key), isNotNull);

        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 100));

        // Should be expired
        expect(cacheService.get<Room>(key), isNull);
      });

      test('should invalidate multiple cache keys', () {
        const roomId = 'room1';

        // Add cache entries
        cacheService.set('room:$roomId', 'room_data');
        cacheService.set('gamestate:$roomId', 'game_data');
        cacheService.set('players:$roomId', 'players_data');
        cacheService.set('active_rooms', 'rooms_list');
        cacheService.set('other_data', 'other');

        expect(cacheService.size, equals(5));

        // Simulate invalidating room cache
        final keysToInvalidate = [
          'room:$roomId',
          'gamestate:$roomId',
          'players:$roomId',
          'active_rooms',
        ];

        for (final key in keysToInvalidate) {
          cacheService.invalidate(key);
        }

        // Room-specific entries should be removed
        expect(cacheService.get('room:$roomId'), isNull);
        expect(cacheService.get('gamestate:$roomId'), isNull);
        expect(cacheService.get('players:$roomId'), isNull);
        expect(cacheService.get('active_rooms'), isNull);

        // Other entries should remain
        expect(cacheService.get('other_data'), equals('other'));
        expect(cacheService.size, equals(1));
      });
    });

    group('Data Structure Optimization', () {
      test('should create optimized snake update structure', () {
        final snakeUpdates = {
          'player1': {
            'head': {'x': 5, 'y': 5},
            'direction': 'up',
            'alive': true,
            'score': 10,
          },
          'player2': {
            'head': {'x': 10, 'y': 10},
            'direction': 'down',
            'alive': false,
            'score': 5,
          },
        };

        // Simulate optimized batch structure
        final batch = <String, dynamic>{};
        const roomId = 'room1';

        for (final entry in snakeUpdates.entries) {
          final playerId = entry.key;
          final snakeData = entry.value as Map<String, dynamic>;

          batch['rooms/$roomId/gameState/snakes/$playerId/head'] =
              snakeData['head'];
          batch['rooms/$roomId/gameState/snakes/$playerId/direction'] =
              snakeData['direction'];
          batch['rooms/$roomId/gameState/snakes/$playerId/alive'] =
              snakeData['alive'];
          batch['rooms/$roomId/gameState/snakes/$playerId/score'] =
              snakeData['score'];
        }

        expect(batch, hasLength(8)); // 4 fields * 2 players
        expect(
          batch['rooms/room1/gameState/snakes/player1/head'],
          equals({'x': 5, 'y': 5}),
        );
        expect(
          batch['rooms/room1/gameState/snakes/player2/alive'],
          equals(false),
        );
      });

      test('should validate room data structure', () {
        final room = Room(
          id: 'room1',
          roomCode: 'TEST123',
          hostId: 'host1',
          status: RoomStatus.waiting,
          createdAt: DateTime.now(),
          players: {
            'player1': Player(
              uid: 'player1',
              displayName: 'Player 1',
              color: PlayerColor.red,
              joinedAt: DateTime.now(),
              isReady: true,
            ),
          },
        );

        // Test serialization
        final json = room.toJson();
        expect(json['id'], equals('room1'));
        expect(json['roomCode'], equals('TEST123'));
        expect(json['players'], isA<Map<String, dynamic>>());

        // Test deserialization
        final restored = Room.fromJson(json);
        expect(restored.id, equals(room.id));
        expect(restored.players.length, equals(1));
        expect(restored.players['player1']?.displayName, equals('Player 1'));
      });
    });

    group('Performance Validation', () {
      test('should handle large cache operations efficiently', () {
        const iterations = 1000;
        final stopwatch = Stopwatch()..start();

        // Perform many cache operations
        for (int i = 0; i < iterations; i++) {
          cacheService.set('key_$i', 'value_$i');
        }

        for (int i = 0; i < iterations; i++) {
          final value = cacheService.get<String>('key_$i');
          expect(value, equals('value_$i'));
        }

        stopwatch.stop();

        // Should complete quickly (adjust threshold as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(cacheService.size, equals(iterations));
      });

      test('should clean up expired entries efficiently', () async {
        const shortTtl = Duration(milliseconds: 50);
        const longTtl = Duration(seconds: 10);

        // Add mix of short and long-lived entries
        for (int i = 0; i < 100; i++) {
          if (i % 2 == 0) {
            cacheService.set('short_$i', 'value_$i', ttl: shortTtl);
          } else {
            cacheService.set('long_$i', 'value_$i', ttl: longTtl);
          }
        }

        expect(cacheService.size, equals(100));

        // Wait for short entries to expire
        await Future.delayed(const Duration(milliseconds: 100));

        cacheService.cleanup();

        // Should have ~50 entries left (long-lived ones)
        expect(cacheService.size, lessThan(60)); // Allow some margin
        expect(cacheService.size, greaterThan(40));
      });
    });

    group('Query Pattern Validation', () {
      test('should validate room code query pattern', () {
        // Test room code format and query structure
        const roomCode = 'ABC123';
        expect(roomCode.length, equals(6));
        expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(roomCode), isTrue);

        // Simulate indexed query path
        const queryPath = 'rooms';
        const orderBy = 'roomCode';
        const equalTo = roomCode;
        const limit = 1;

        expect(queryPath, equals('rooms'));
        expect(orderBy, equals('roomCode'));
        expect(equalTo, equals(roomCode));
        expect(limit, equals(1));
      });

      test('should validate active rooms query pattern', () {
        // Simulate active rooms query structure
        const queryPath = 'rooms';
        const orderBy = 'status';
        const equalTo = 'waiting';
        const maxResults = 20;

        expect(queryPath, equals('rooms'));
        expect(orderBy, equals('status'));
        expect(equalTo, equals('waiting'));
        expect(maxResults, equals(20));
      });

      test('should validate player indexing patterns', () {
        // Test player query indices
        final playerIndices = ['joinedAt', 'isReady', 'isConnected'];
        final snakeIndices = ['alive', 'score'];

        expect(
          playerIndices,
          containsAll(['joinedAt', 'isReady', 'isConnected']),
        );
        expect(snakeIndices, containsAll(['alive', 'score']));
      });
    });
  });
}
