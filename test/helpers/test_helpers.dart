import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snakes_fight/core/models/models.dart';
import 'package:snakes_fight/core/services/services.dart';

// Generate mocks for these classes  
@GenerateMocks([
  AuthService,
  DatabaseService,
])
import 'test_helpers.mocks.dart';

/// Mock User (Firebase Auth User)
class MockUser extends Mock implements auth.User {
  @override
  String get uid => 'test_user_id';

  @override
  String? get displayName => 'Test User';

  @override
  bool get isAnonymous => false;

  @override
  String? get email => 'test@example.com';
}

/// Mock UserCredential
class MockUserCredential extends Mock implements auth.UserCredential {
  @override
  auth.User? get user => MockUser();
}

/// Mock RoomCodeService
class MockRoomCodeService extends Mock {
  Future<String> generateUniqueRoomCode() async => 'ABC123';
}

/// Test data helpers
class TestData {
  static Room get sampleRoom => Room(
    id: 'test_room_id',
    roomCode: 'ABC123',
    hostId: 'test_host',
    status: RoomStatus.waiting,
    createdAt: DateTime.now(),
    maxPlayers: 4,
    players: {
      'test_host': Player(
        uid: 'test_host',
        displayName: 'Host Player',
        color: PlayerColor.red,
        joinedAt: DateTime.now(),
      ),
    },
  );

  static Player get samplePlayer => Player(
    uid: 'test_player_id',
    displayName: 'Test Player',
    color: PlayerColor.blue,
    joinedAt: DateTime.now(),
  );

  static GameState get sampleGameState => GameState(
    startedAt: DateTime.now(),
    food: const Food(position: Position(10, 10)),
    snakes: {
      'test_player_1': Snake(
        positions: [Position(5, 5)],
        direction: Direction.right,
      ),
    },
  );
}

/// Test helper methods
class TestHelpers {
  /// Creates a mock AuthService with default behavior
  static MockAuthService createMockAuthService() {
    final mock = MockAuthService();
    final mockUser = MockUser();
    
    when(mock.currentUser).thenReturn(mockUser);
    when(mock.signInAnonymously()).thenAnswer(
      (_) async => MockUserCredential(),
    );
    when(mock.isSignedIn).thenReturn(true);
    when(mock.userDisplayName).thenReturn('Test User');
    return mock;
  }

  /// Creates a mock DatabaseService with default behavior
  static MockDatabaseService createMockDatabaseService() {
    final mock = MockDatabaseService();
    when(mock.createRoom(any)).thenAnswer(
      (_) async => TestData.sampleRoom,
    );
    when(mock.getRoomById(any)).thenAnswer(
      (_) async => TestData.sampleRoom,
    );
    when(mock.getRoomByCode(any)).thenAnswer(
      (_) async => TestData.sampleRoom,
    );
    when(mock.watchRoom(any)).thenAnswer(
      (_) => Stream.value(TestData.sampleRoom),
    );
    when(mock.watchGameState(any)).thenAnswer(
      (_) => Stream.value(TestData.sampleGameState),
    );
    return mock;
  }

  /// Creates a mock RoomCodeService with default behavior
  static MockRoomCodeService createMockRoomCodeService() {
    final mock = MockRoomCodeService();
    return mock;
  }

  /// Creates a Room with specified number of players
  static Room createRoomWithPlayers(int playerCount) {
    final players = <String, Player>{};
    for (int i = 0; i < playerCount; i++) {
      final playerId = 'player_$i';
      players[playerId] = Player(
        uid: playerId,
        displayName: 'Player $i',
        color: PlayerColor.values[i % PlayerColor.values.length],
        joinedAt: DateTime.now(),
      );
    }

    return Room(
      id: 'test_room_id',
      roomCode: 'ABC123',
      hostId: 'player_0',
      status: RoomStatus.waiting,
      createdAt: DateTime.now(),
      maxPlayers: 4,
      players: players,
    );
  }

  /// Creates a GameState with specified players
  static GameState createGameStateWithPlayers(List<String> playerIds) {
    final snakes = <String, Snake>{};
    for (int i = 0; i < playerIds.length; i++) {
      final playerId = playerIds[i];
      snakes[playerId] = Snake(
        positions: [Position(5 + i, 5 + i)],
        direction: Direction.right,
      );
    }

    return GameState(
      startedAt: DateTime.now(),
      food: const Food(position: Position(10, 10)),
      snakes: snakes,
    );
  }

  /// Waits for a specified duration (useful for async tests)
  static Future<void> wait([Duration duration = const Duration(milliseconds: 100)]) {
    return Future.delayed(duration);
  }

  /// Verifies that a function throws a specific exception type
  static void expectThrows<T extends Exception>(
    void Function() function,
    String expectedMessage,
  ) {
    try {
      function();
      throw Exception('Expected $T to be thrown');
    } catch (e) {
      if (e is! T) {
        throw Exception('Expected $T but got ${e.runtimeType}');
      }
      if (!e.toString().contains(expectedMessage)) {
        throw Exception('Expected message to contain "$expectedMessage" but got "${e.toString()}"');
      }
    }
  }
}
