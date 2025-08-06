import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/utils/model_utils.dart';

void main() {
  group('Data Models Integration Tests', () {
    late Room testRoom;
    late Player testPlayer1;
    late Player testPlayer2;
    late GameState testGameState;
    late User testUser;

    setUp(() {
      testPlayer1 = Player(
        uid: 'player1',
        displayName: 'Alice',
        color: PlayerColor.red,
        joinedAt: DateTime.now(),
        isReady: true,
      );

      testPlayer2 = Player(
        uid: 'player2',
        displayName: 'Bob',
        color: PlayerColor.blue,
        joinedAt: DateTime.now(),
        isReady: true,
      );

      testRoom = Room(
        id: 'room123',
        roomCode: 'ABCD12',
        hostId: 'player1',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        players: {'player1': testPlayer1, 'player2': testPlayer2},
      );

      testGameState = GameState(
        startedAt: DateTime.now(),
        food: const Food(position: Position(10, 10)),
        snakes: {
          'player1': const Snake(
            positions: [Position(5, 5), Position(4, 5)],
            direction: Direction.right,
          ),
          'player2': const Snake(
            positions: [Position(15, 15), Position(14, 15)],
            direction: Direction.left,
          ),
        },
      );

      testUser = User(
        uid: 'user123',
        displayName: 'TestUser',
        stats: UserStats(
          gamesPlayed: 10,
          gamesWon: 7,
          lastActive: DateTime.now(),
        ),
      );
    });

    test('should create a complete game scenario', () {
      // Verify room setup
      expect(testRoom.canStartGame, isTrue);
      expect(testRoom.players.length, equals(2));
      expect(testRoom.isHost('player1'), isTrue);
      expect(testRoom.isHost('player2'), isFalse);

      // Verify game state
      expect(testGameState.isActive, isTrue);
      expect(testGameState.snakes.length, equals(2));
      expect(testGameState.aliveSnakes.length, equals(2));

      // Verify user stats
      expect(testUser.winRate, equals(0.7));
      expect(testUser.isNewPlayer, isFalse);
    });

    test('should serialize and deserialize complete room with game state', () {
      final roomWithGame = testRoom.copyWith(
        status: RoomStatus.active,
        gameState: testGameState,
      );

      final json = roomWithGame.toJson();
      final restored = Room.fromJson(json);

      expect(restored.id, equals(roomWithGame.id));
      expect(restored.status, equals(RoomStatus.active));
      expect(restored.gameState, isNotNull);
      expect(restored.gameState!.snakes.length, equals(2));
      expect(restored.players.length, equals(2));
    });

    test('should handle game progression correctly', () {
      // Start with waiting room
      expect(testRoom.status, equals(RoomStatus.waiting));
      expect(testRoom.canStartGame, isTrue);

      // Move to active game
      final activeRoom = testRoom.copyWith(
        status: RoomStatus.active,
        gameState: testGameState,
      );

      expect(activeRoom.isActive, isTrue);
      expect(activeRoom.gameState, isNotNull);

      // Update snake positions
      final updatedSnake = testGameState.snakes['player1']!.copyWith(
        positions: [const Position(6, 5), const Position(5, 5)],
        score: 1,
      );

      final updatedGameState = testGameState.copyWith(
        snakes: {...testGameState.snakes, 'player1': updatedSnake},
      );

      expect(updatedGameState.snakes['player1']!.score, equals(1));
      expect(
        updatedGameState.snakes['player1']!.head,
        equals(const Position(6, 5)),
      );
    });

    test('should handle player disconnection', () {
      final disconnectedPlayer = testPlayer2.updateConnection(false);
      final updatedRoom = testRoom.copyWith(
        players: {'player1': testPlayer1, 'player2': disconnectedPlayer},
      );

      expect(updatedRoom.connectedPlayerCount, equals(1));
      expect(
        updatedRoom.canStartGame,
        isFalse,
      ); // Not all players ready and connected
    });

    test('should manage available colors correctly', () {
      expect(testRoom.availableColors.length, equals(2));
      expect(testRoom.availableColors, contains(PlayerColor.green));
      expect(testRoom.availableColors, contains(PlayerColor.yellow));
      expect(testRoom.availableColors, isNot(contains(PlayerColor.red)));
      expect(testRoom.availableColors, isNot(contains(PlayerColor.blue)));
    });

    test('should handle game end scenario', () {
      final endedGameState = testGameState.copyWith(
        winner: 'player1',
        endedAt: DateTime.now(),
        snakes: {
          'player1': testGameState.snakes['player1']!,
          'player2': testGameState.snakes['player2']!.copyWith(alive: false),
        },
      );

      final endedRoom = testRoom.copyWith(
        status: RoomStatus.ended,
        gameState: endedGameState,
      );

      expect(endedRoom.hasEnded, isTrue);
      expect(endedGameState.hasEnded, isTrue);
      expect(endedGameState.winner, equals('player1'));
      expect(endedGameState.aliveSnakeCount, equals(1));
    });

    test('should update user stats after game', () {
      final updatedStats = testUser.stats.afterGame(won: true);
      final updatedUser = testUser.copyWith(stats: updatedStats);

      expect(updatedUser.stats.gamesPlayed, equals(11));
      expect(updatedUser.stats.gamesWon, equals(8));
      expect(updatedUser.winRatePercentage, closeTo(72.7, 0.1));
    });

    test('should validate model utilities integration', () {
      // Generate positions for snakes
      final positions = ModelUtils.generateInitialSnakePositions(
        playerCount: 2,
        gridWidth: 20,
        gridHeight: 20,
      );

      expect(positions.length, equals(2));

      // Check all positions are in bounds
      for (final position in positions) {
        expect(
          ModelUtils.isPositionInBounds(position, width: 20, height: 20),
          isTrue,
        );
      }

      // Check room code generation and validation
      final roomCode = ModelUtils.generateRoomCode();
      expect(ModelUtils.isValidRoomCode(roomCode), isTrue);

      // Test player color utilities
      final usedColors = testRoom.players.values.map((p) => p.color).toList();
      final nextColor = ModelUtils.getNextAvailableColor(usedColors);
      expect(nextColor, isNotNull);
      expect(usedColors, isNot(contains(nextColor)));
    });

    test('should handle complex serialization scenarios', () {
      // Create a complex scenario with all models
      final complexRoom = Room(
        id: 'complex_room',
        roomCode: ModelUtils.generateRoomCode(),
        hostId: 'host_user',
        status: RoomStatus.active,
        createdAt: DateTime.now(),
        players: {
          'host_user': Player(
            uid: 'host_user',
            displayName: 'Host Player',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
            isReady: true,
          ),
          'guest_user': Player(
            uid: 'guest_user',
            displayName: 'Guest Player',
            color: PlayerColor.blue,
            joinedAt: DateTime.now(),
            isReady: true,
          ),
        },
        gameState: GameState(
          startedAt: DateTime.now(),
          food: const Food(position: Position(12, 8), value: 2),
          snakes: {
            'host_user': const Snake(
              positions: [
                Position(5, 5),
                Position(4, 5),
                Position(3, 5),
                Position(2, 5),
              ],
              direction: Direction.right,
              score: 3,
            ),
            'guest_user': const Snake(
              positions: [Position(15, 15), Position(15, 14), Position(15, 13)],
              direction: Direction.down,
              score: 1,
              alive: false,
            ),
          },
          winner: 'host_user',
          endedAt: DateTime.now(),
        ),
      );

      // Serialize to JSON
      final json = complexRoom.toJson();
      expect(json, isA<Map<String, dynamic>>());

      // Deserialize from JSON
      final restored = Room.fromJson(json);

      // Verify all data is preserved
      expect(restored.id, equals(complexRoom.id));
      expect(restored.status, equals(RoomStatus.active));
      expect(restored.players.length, equals(2));
      expect(restored.gameState, isNotNull);
      expect(restored.gameState!.winner, equals('host_user'));
      expect(restored.gameState!.snakes['guest_user']!.alive, isFalse);
      expect(restored.gameState!.food.value, equals(2));
    });
  });
}
