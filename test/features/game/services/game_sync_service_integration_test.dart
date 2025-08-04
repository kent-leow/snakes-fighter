import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/core/models/models.dart';
import '../../../../lib/core/services/database_service.dart';
import '../../../../lib/features/game/services/game_sync_service.dart';

// Simple test implementation of DatabaseService
class TestDatabaseService implements DatabaseService {
  final Map<String, dynamic> _data = {};
  final Map<String, StreamController<GameState?>> _gameStateControllers = {};

  @override
  Future<void> batchUpdate(Map<String, dynamic> updates) async {
    for (final entry in updates.entries) {
      _data[entry.key] = entry.value;
    }
    
    // Notify game state listeners
    for (final roomId in _gameStateControllers.keys) {
      if (updates.keys.any((key) => key.contains('rooms/$roomId/gameState'))) {
        _gameStateControllers[roomId]?.add(_buildGameStateFromData(roomId));
      }
    }
  }

  @override
  Stream<GameState?> watchGameState(String roomId) {
    _gameStateControllers[roomId] ??= StreamController<GameState?>.broadcast();
    return _gameStateControllers[roomId]!.stream;
  }

  @override
  Future<T> runAtomicOperation<T>(Future<T> Function() operation) async {
    return await operation();
  }

  GameState? _buildGameStateFromData(String roomId) {
    // Simple mock implementation - return a basic game state
    return GameState(
      startedAt: DateTime.now(),
      food: const Food(position: Position(5, 5)),
      snakes: const {},
    );
  }

  void dispose() {
    for (final controller in _gameStateControllers.values) {
      controller.close();
    }
    _gameStateControllers.clear();
  }

  // Stub implementations for required interface methods
  @override
  Future<Room> createRoom(Room room) => throw UnimplementedError();
  
  @override
  Future<Room?> getRoomById(String roomId) => throw UnimplementedError();
  
  @override
  Future<Room?> getRoomByCode(String roomCode) => throw UnimplementedError();
  
  @override
  Future<void> updateRoom(Room room) => throw UnimplementedError();
  
  @override
  Future<void> deleteRoom(String roomId) => throw UnimplementedError();
  
  @override
  Stream<Room?> watchRoom(String roomId) => throw UnimplementedError();
  
  @override
  Future<void> addPlayerToRoom(String roomId, Player player) => throw UnimplementedError();
  
  @override
  Future<void> removePlayerFromRoom(String roomId, String playerId) => throw UnimplementedError();
  
  @override
  Future<void> updatePlayer(String roomId, Player player) => throw UnimplementedError();
  
  @override
  Stream<Map<String, Player>> watchRoomPlayers(String roomId) => throw UnimplementedError();
  
  @override
  Future<void> updateGameState(String roomId, GameState gameState) => throw UnimplementedError();
}

void main() {
  group('GameSyncService', () {
    late GameSyncService service;
    late TestDatabaseService testDatabaseService;

    setUp(() {
      testDatabaseService = TestDatabaseService();
      service = GameSyncService(testDatabaseService);
    });

    tearDown(() {
      service.dispose();
      testDatabaseService.dispose();
    });

    group('syncPlayerMove', () {
      test('updates player direction and timestamp', () async {
        // Arrange
        const roomId = 'room1';
        const playerId = 'player1';
        const direction = Direction.up;

        // Act
        await service.syncPlayerMove(roomId, playerId, direction);

        // Assert
        final expectedKey1 = 'rooms/$roomId/gameState/snakes/$playerId/direction';
        final expectedKey2 = 'rooms/$roomId/gameState/snakes/$playerId/lastUpdate';
        
        expect(testDatabaseService._data[expectedKey1], equals('up'));
        expect(testDatabaseService._data[expectedKey2], isA<int>());
      });
    });

    group('syncFoodConsumption', () {
      test('updates food position and player score', () async {
        // Arrange
        const roomId = 'room1';
        const playerId = 'player1';
        const foodPosition = Position(3, 3);
        const newFoodPosition = Position(7, 7);
        const newScore = 10;

        // Act
        await service.syncFoodConsumption(
          roomId,
          playerId,
          foodPosition,
          newFoodPosition,
          newScore,
        );

        // Assert
        final expectedFoodKey = 'rooms/$roomId/gameState/food/position';
        final expectedScoreKey = 'rooms/$roomId/gameState/snakes/$playerId/score';
        
        expect(testDatabaseService._data[expectedFoodKey], equals(newFoodPosition.toJson()));
        expect(testDatabaseService._data[expectedScoreKey], equals(newScore));
      });
    });

    group('syncPlayerDeath', () {
      test('marks player as not alive and records death time', () async {
        // Arrange
        const roomId = 'room1';
        const playerId = 'player1';

        // Act
        await service.syncPlayerDeath(roomId, playerId);

        // Assert
        final expectedAliveKey = 'rooms/$roomId/gameState/snakes/$playerId/alive';
        final expectedDeathTimeKey = 'rooms/$roomId/gameState/snakes/$playerId/deathTime';
        
        expect(testDatabaseService._data[expectedAliveKey], equals(false));
        expect(testDatabaseService._data[expectedDeathTimeKey], isA<int>());
      });
    });

    group('syncSnakePositions', () {
      test('updates complete snake data', () async {
        // Arrange
        const roomId = 'room1';
        const playerId = 'player1';
        const positions = [Position(1, 1), Position(1, 2)];
        const direction = Direction.down;
        const alive = true;
        const score = 5;

        // Act
        await service.syncSnakePositions(
          roomId,
          playerId,
          positions,
          direction,
          alive,
          score,
        );

        // Assert
        final expectedPositionsKey = 'rooms/$roomId/gameState/snakes/$playerId/positions';
        final expectedDirectionKey = 'rooms/$roomId/gameState/snakes/$playerId/direction';
        final expectedAliveKey = 'rooms/$roomId/gameState/snakes/$playerId/alive';
        final expectedScoreKey = 'rooms/$roomId/gameState/snakes/$playerId/score';
        
        expect(testDatabaseService._data[expectedPositionsKey],
               equals(positions.map((p) => p.toJson()).toList()));
        expect(testDatabaseService._data[expectedDirectionKey], equals('down'));
        expect(testDatabaseService._data[expectedAliveKey], equals(alive));
        expect(testDatabaseService._data[expectedScoreKey], equals(score));
      });
    });

    group('syncGameEnd', () {
      test('marks game as ended with winner', () async {
        // Arrange
        const roomId = 'room1';
        const winnerId = 'player1';

        // Act
        await service.syncGameEnd(roomId, winnerId);

        // Assert
        final expectedEndedAtKey = 'rooms/$roomId/gameState/endedAt';
        final expectedWinnerKey = 'rooms/$roomId/gameState/winner';
        final expectedStatusKey = 'rooms/$roomId/status';
        
        expect(testDatabaseService._data[expectedEndedAtKey], isA<String>());
        expect(testDatabaseService._data[expectedWinnerKey], equals(winnerId));
        expect(testDatabaseService._data[expectedStatusKey], equals('ended'));
      });

      test('handles null winner (draw)', () async {
        // Arrange
        const roomId = 'room1';

        // Act
        await service.syncGameEnd(roomId, null);

        // Assert
        final expectedWinnerKey = 'rooms/$roomId/gameState/winner';
        expect(testDatabaseService._data[expectedWinnerKey], isNull);
      });
    });

    group('syncGameStart', () {
      test('marks game as active and sets start time', () async {
        // Arrange
        const roomId = 'room1';

        // Act
        await service.syncGameStart(roomId);

        // Assert
        final expectedStartedAtKey = 'rooms/$roomId/gameState/startedAt';
        final expectedStatusKey = 'rooms/$roomId/status';
        
        expect(testDatabaseService._data[expectedStartedAtKey], isA<String>());
        expect(testDatabaseService._data[expectedStatusKey], equals('active'));
      });
    });

    group('watchGameState', () {
      test('filters out null values from database stream', () async {
        // Arrange
        const roomId = 'room1';
        final events = <GameState>[];
        
        // Act
        final stream = service.watchGameState(roomId);
        final subscription = stream.listen(events.add);

        // Trigger some updates
        await service.syncGameStart(roomId);
        await Future.delayed(Duration(milliseconds: 10));

        // Assert
        expect(events, hasLength(1));
        expect(events.first, isA<GameState>());

        // Cleanup
        await subscription.cancel();
      });
    });

    group('atomicUpdate', () {
      test('executes operation within atomic transaction', () async {
        // Arrange
        const roomId = 'room1';
        var operationExecuted = false;

        // Act
        await service.atomicUpdate(roomId, () async {
          operationExecuted = true;
        });

        // Assert
        expect(operationExecuted, isTrue);
      });
    });

    test('dispose does not throw errors', () {
      expect(() => service.dispose(), returnsNormally);
    });
  });
}
