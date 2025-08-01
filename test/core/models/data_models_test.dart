import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/models.dart';

void main() {
  group('Position', () {
    test('should create position with correct coordinates', () {
      const position = Position(5, 10);
      expect(position.x, equals(5));
      expect(position.y, equals(10));
    });

    test('should create origin position', () {
      const position = Position.origin();
      expect(position.x, equals(0));
      expect(position.y, equals(0));
    });

    test('should add positions correctly', () {
      const pos1 = Position(2, 3);
      const pos2 = Position(4, 5);
      final result = pos1 + pos2;
      expect(result.x, equals(6));
      expect(result.y, equals(8));
    });

    test('should calculate distance correctly', () {
      const pos1 = Position(0, 0);
      const pos2 = Position(3, 4);
      expect(pos1.distanceTo(pos2), equals(5.0));
    });

    test('should serialize to/from JSON', () {
      const original = Position(10, 20);
      final json = original.toJson();
      final restored = Position.fromJson(json);

      expect(restored.x, equals(original.x));
      expect(restored.y, equals(original.y));
    });

    test('should detect adjacent positions', () {
      const center = Position(5, 5);
      const adjacent = Position(6, 5);
      const diagonal = Position(6, 6);
      const far = Position(8, 8);

      expect(center.isDirectlyAdjacentTo(adjacent), isTrue);
      expect(center.isAdjacentTo(diagonal), isTrue);
      expect(center.isAdjacentTo(far), isFalse);
    });
  });

  group('Enums', () {
    test('Direction should have correct opposites', () {
      expect(Direction.up.opposite, equals(Direction.down));
      expect(Direction.down.opposite, equals(Direction.up));
      expect(Direction.left.opposite, equals(Direction.right));
      expect(Direction.right.opposite, equals(Direction.left));
    });

    test('Direction should convert to position correctly', () {
      expect(Direction.up.toPosition(), equals(const Position(0, -1)));
      expect(Direction.down.toPosition(), equals(const Position(0, 1)));
      expect(Direction.left.toPosition(), equals(const Position(-1, 0)));
      expect(Direction.right.toPosition(), equals(const Position(1, 0)));
    });
  });

  group('Player', () {
    test('should create player with required fields', () {
      final player = Player(
        uid: 'user123',
        displayName: 'TestPlayer',
        color: PlayerColor.red,
        joinedAt: DateTime.now(),
      );

      expect(player.uid, equals('user123'));
      expect(player.displayName, equals('TestPlayer'));
      expect(player.color, equals(PlayerColor.red));
      expect(player.isReady, isFalse);
      expect(player.isConnected, isTrue);
    });

    test('should serialize to/from JSON', () {
      final original = Player(
        uid: 'user123',
        displayName: 'TestPlayer',
        color: PlayerColor.blue,
        joinedAt: DateTime.now(),
        isReady: true,
      );

      final json = original.toJson();
      final restored = Player.fromJson(json);

      expect(restored.uid, equals(original.uid));
      expect(restored.displayName, equals(original.displayName));
      expect(restored.color, equals(original.color));
      expect(restored.isReady, equals(original.isReady));
    });

    test('should toggle ready status', () {
      final player = Player(
        uid: 'user123',
        displayName: 'TestPlayer',
        color: PlayerColor.green,
        joinedAt: DateTime.now(),
      );

      final readyPlayer = player.toggleReady();
      expect(readyPlayer.isReady, isTrue);

      final unreadyPlayer = readyPlayer.toggleReady();
      expect(unreadyPlayer.isReady, isFalse);
    });
  });

  group('Food', () {
    test('should create food with position', () {
      const position = Position(10, 15);
      const food = Food(position: position);

      expect(food.position, equals(position));
      expect(food.value, equals(1));
    });

    test('should serialize to/from JSON', () {
      const original = Food(position: Position(5, 8), value: 2);

      final json = original.toJson();
      final restored = Food.fromJson(json);

      expect(restored.position, equals(original.position));
      expect(restored.value, equals(original.value));
    });
  });

  group('Snake', () {
    test('should create snake with positions and direction', () {
      const positions = [Position(5, 5), Position(4, 5), Position(3, 5)];
      const snake = Snake(positions: positions, direction: Direction.right);

      expect(snake.positions, equals(positions));
      expect(snake.direction, equals(Direction.right));
      expect(snake.alive, isTrue);
      expect(snake.score, equals(0));
    });

    test('should get head and tail correctly', () {
      const positions = [Position(5, 5), Position(4, 5), Position(3, 5)];
      const snake = Snake(positions: positions, direction: Direction.right);

      expect(snake.head, equals(const Position(5, 5)));
      expect(snake.tail, equals(const Position(3, 5)));
    });

    test('should detect self collision', () {
      // Snake that loops back on itself
      const collisionPositions = [
        Position(5, 5),
        Position(4, 5),
        Position(3, 5),
        Position(3, 4),
        Position(4, 4),
        Position(5, 4),
        Position(5, 5), // Same as head
      ];

      const snake = Snake(
        positions: collisionPositions,
        direction: Direction.up,
      );

      expect(snake.hasSelfCollision, isTrue);
    });

    test('should get next head position', () {
      const snake = Snake(
        positions: [Position(5, 5)],
        direction: Direction.right,
      );

      expect(snake.getNextHeadPosition(), equals(const Position(6, 5)));
    });
  });

  group('Room', () {
    test('should create room with basic properties', () {
      final room = Room(
        id: 'room123',
        roomCode: 'ABCD12',
        hostId: 'host123',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
      );

      expect(room.id, equals('room123'));
      expect(room.roomCode, equals('ABCD12'));
      expect(room.hostId, equals('host123'));
      expect(room.status, equals(RoomStatus.waiting));
      expect(room.maxPlayers, equals(4));
      expect(room.players, isEmpty);
    });

    test('should detect if room is full', () {
      final room = Room(
        id: 'room123',
        roomCode: 'ABCD12',
        hostId: 'host123',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        maxPlayers: 2,
        players: {
          'player1': Player(
            uid: 'player1',
            displayName: 'Player1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          ),
          'player2': Player(
            uid: 'player2',
            displayName: 'Player2',
            color: PlayerColor.blue,
            joinedAt: DateTime.now(),
          ),
        },
      );

      expect(room.isFull, isTrue);
      expect(room.hasSpace, isFalse);
    });

    test('should check if game can start', () {
      final room = Room(
        id: 'room123',
        roomCode: 'ABCD12',
        hostId: 'player1',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        players: {
          'player1': Player(
            uid: 'player1',
            displayName: 'Player1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
            isReady: true,
          ),
          'player2': Player(
            uid: 'player2',
            displayName: 'Player2',
            color: PlayerColor.blue,
            joinedAt: DateTime.now(),
            isReady: true,
          ),
        },
      );

      expect(room.canStartGame, isTrue);
    });

    test('should get available colors', () {
      final room = Room(
        id: 'room123',
        roomCode: 'ABCD12',
        hostId: 'player1',
        status: RoomStatus.waiting,
        createdAt: DateTime.now(),
        players: {
          'player1': Player(
            uid: 'player1',
            displayName: 'Player1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          ),
        },
      );

      final availableColors = room.availableColors;
      expect(availableColors, contains(PlayerColor.blue));
      expect(availableColors, contains(PlayerColor.green));
      expect(availableColors, contains(PlayerColor.yellow));
      expect(availableColors, isNot(contains(PlayerColor.red)));
    });
  });

  group('User and UserStats', () {
    test('should create user with stats', () {
      final stats = UserStats(lastActive: DateTime.now());
      final user = User(uid: 'user123', displayName: 'TestUser', stats: stats);

      expect(user.uid, equals('user123'));
      expect(user.displayName, equals('TestUser'));
      expect(user.isAnonymous, isFalse);
      expect(user.isNewPlayer, isTrue);
    });

    test('should calculate win rate correctly', () {
      final stats = UserStats(
        gamesPlayed: 10,
        gamesWon: 7,
        lastActive: DateTime.now(),
      );
      final user = User(uid: 'user123', displayName: 'TestUser', stats: stats);

      expect(user.winRate, equals(0.7));
      expect(user.winRatePercentage, equals(70.0));
      expect(user.winRateString, equals('70.0%'));
    });

    test('should update stats after game', () {
      final stats = UserStats(
        gamesPlayed: 5,
        gamesWon: 2,
        lastActive: DateTime.now(),
      );

      final updatedStats = stats.afterGame(won: true);
      expect(updatedStats.gamesPlayed, equals(6));
      expect(updatedStats.gamesWon, equals(3));

      final updatedStatsLoss = stats.afterGame(won: false);
      expect(updatedStatsLoss.gamesPlayed, equals(6));
      expect(updatedStatsLoss.gamesWon, equals(2));
    });
  });
}
