import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snakes_fight/core/models/enums.dart';
import 'package:snakes_fight/core/models/player.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/engine/multiplayer_game_engine.dart';
import 'package:snakes_fight/features/game/models/game_board.dart';
import 'package:snakes_fight/features/game/services/game_sync_service.dart';

class MockGameSyncService extends Mock implements GameSyncService {}

void main() {
  group('MultiplayerGameEngine Integration', () {
    late MultiplayerGameEngine engine;
    late MockGameSyncService mockSyncService;
    late GameBoard gameBoard;

    setUp(() {
      mockSyncService = MockGameSyncService();
      gameBoard = const GameBoard(width: 20, height: 20);
      engine = MultiplayerGameEngine(
        board: gameBoard,
        syncService: mockSyncService,
        config: GameConfig.defaultConfig(),
      );
    });

    group('game initialization', () {
      test('should initialize game with 2 players correctly', () {
        final now = DateTime.now();
        final players = <String, Player>{
          'player1': Player(
            uid: 'player1',
            displayName: 'Player 1',
            color: PlayerColor.red,
            joinedAt: now,
          ),
          'player2': Player(
            uid: 'player2',
            displayName: 'Player 2',
            color: PlayerColor.blue,
            joinedAt: now,
          ),
        };

        expect(() => engine.initializeGame(players), returnsNormally);

        final gameState = engine.getGameStateSnapshot();
        expect(gameState['snakes'], hasLength(2));
        expect(gameState['isActive'], isTrue);
        expect(gameState['food'], isNotNull);

        // Check that both snakes are initialized
        final snakes = gameState['snakes'] as Map<String, dynamic>;
        expect(snakes.keys, contains('player1'));
        expect(snakes.keys, contains('player2'));

        // Check initial states
        final player1Snake = snakes['player1'] as Map<String, dynamic>;
        final player2Snake = snakes['player2'] as Map<String, dynamic>;

        expect(player1Snake['alive'], isTrue);
        expect(player1Snake['score'], equals(0));
        expect(player2Snake['alive'], isTrue);
        expect(player2Snake['score'], equals(0));
      });

      test('should initialize game with 4 players correctly', () {
        final now = DateTime.now();
        final players = <String, Player>{
          'player1': Player(
            uid: 'player1',
            displayName: 'Player 1',
            color: PlayerColor.red,
            joinedAt: now,
          ),
          'player2': Player(
            uid: 'player2',
            displayName: 'Player 2',
            color: PlayerColor.blue,
            joinedAt: now,
          ),
          'player3': Player(
            uid: 'player3',
            displayName: 'Player 3',
            color: PlayerColor.green,
            joinedAt: now,
          ),
          'player4': Player(
            uid: 'player4',
            displayName: 'Player 4',
            color: PlayerColor.yellow,
            joinedAt: now,
          ),
        };

        expect(() => engine.initializeGame(players), returnsNormally);

        final gameState = engine.getGameStateSnapshot();
        expect(gameState['snakes'], hasLength(4));

        // Check that starting positions are spread out
        final snakes = gameState['snakes'] as Map<String, dynamic>;
        final positions = <Position>[];
        for (final snake in snakes.values) {
          final snakeData = snake as Map<String, dynamic>;
          final positionsList = snakeData['positions'] as List<dynamic>;
          final headPos = positionsList.first as Map<String, dynamic>;
          positions.add(Position(headPos['x'] as int, headPos['y'] as int));
        }

        // All starting positions should be different
        expect(positions.toSet().length, equals(4));
      });

      test('should throw error for invalid player count', () {
        expect(() => engine.initializeGame({}), throwsArgumentError);

        final tooManyPlayers = <String, Player>{};
        for (int i = 1; i <= 5; i++) {
          tooManyPlayers['player$i'] = Player(
            uid: 'player$i',
            displayName: 'Player $i',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          );
        }

        expect(
          () => engine.initializeGame(tooManyPlayers),
          throwsArgumentError,
        );
      });
    });

    group('player direction updates', () {
      setUp(() {
        final players = <String, Player>{
          'player1': Player(
            uid: 'player1',
            displayName: 'Player 1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          ),
        };
        engine.initializeGame(players);
      });

      test('should allow valid direction change', () {
        final result = engine.updatePlayerDirection('player1', Direction.up);
        expect(result, isTrue);

        final gameState = engine.getGameStateSnapshot();
        final snakes = gameState['snakes'] as Map<String, dynamic>;
        final player1Snake = snakes['player1'] as Map<String, dynamic>;
        expect(player1Snake['direction'], equals('up'));
      });

      test('should prevent reverse direction change', () {
        // First set direction to right
        engine.updatePlayerDirection('player1', Direction.right);

        // Try to change to left (opposite) - should fail
        final result = engine.updatePlayerDirection('player1', Direction.left);
        expect(result, isFalse);

        final gameState = engine.getGameStateSnapshot();
        final snakes = gameState['snakes'] as Map<String, dynamic>;
        final player1Snake = snakes['player1'] as Map<String, dynamic>;
        expect(
          player1Snake['direction'],
          equals('right'),
        ); // Should remain right
      });

      test('should ignore direction change for non-existent player', () {
        final result = engine.updatePlayerDirection(
          'non_existent',
          Direction.up,
        );
        expect(result, isFalse);
      });
    });

    group('game state management', () {
      test('should provide correct game state snapshot', () {
        final players = <String, Player>{
          'player1': Player(
            uid: 'player1',
            displayName: 'Player 1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          ),
        };
        engine.initializeGame(players);

        final snapshot = engine.getGameStateSnapshot();

        expect(snapshot, containsPair('snakes', isA<Map<String, dynamic>>()));
        expect(snapshot, containsPair('food', isNotNull));
        expect(snapshot, containsPair('isActive', isTrue));
        expect(snapshot, containsPair('gameStartTime', isNotNull));

        final snakes = snapshot['snakes'] as Map<String, dynamic>;
        expect(snakes, hasLength(1));
        expect(snakes.keys, contains('player1'));
      });

      test('should clean up properly on dispose', () {
        final players = <String, Player>{
          'player1': Player(
            uid: 'player1',
            displayName: 'Player 1',
            color: PlayerColor.red,
            joinedAt: DateTime.now(),
          ),
        };
        engine.initializeGame(players);

        engine.dispose();

        final snapshot = engine.getGameStateSnapshot();
        expect(snapshot['isActive'], isFalse);
      });
    });
  });
}
