import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameController', () {
    late GridSystem gridSystem;
    late GameController gameController;

    setUp(() {
      gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 20,
        cellSize: 20.0,
        screenWidth: 400.0,
        screenHeight: 400.0,
      );
      gameController = GameController(gridSystem: gridSystem);
    });

    tearDown(() {
      gameController.dispose();
    });

    group('initialization', () {
      test('should initialize with correct default state', () {
        expect(gameController.currentState, GameState.menu);
        expect(gameController.score, 0);
        expect(gameController.snake.head, gridSystem.centerPosition);
        expect(gameController.snake.currentDirection, Direction.right);
      });

      test('should have valid initial snake position', () {
        final snakeHead = gameController.snake.head;
        expect(gridSystem.isValidPosition(snakeHead), isTrue);
      });
    });

    group('game state management', () {
      test('should start game correctly', () async {
        await gameController.startGame();

        expect(gameController.currentState, GameState.playing);
        expect(gameController.isPlaying, isTrue);
        expect(gameController.isPaused, isFalse);
        expect(gameController.isGameOver, isFalse);
      });

      test('should pause game correctly', () async {
        await gameController.startGame();
        await gameController.pauseGame();

        expect(gameController.currentState, GameState.paused);
        expect(gameController.isPaused, isTrue);
        expect(gameController.isPlaying, isFalse);
      });

      test('should resume game correctly', () async {
        await gameController.startGame();
        await gameController.pauseGame();
        await gameController.resumeGame();

        expect(gameController.currentState, GameState.playing);
        expect(gameController.isPlaying, isTrue);
        expect(gameController.isPaused, isFalse);
      });

      test('should stop game correctly', () async {
        await gameController.startGame();
        await gameController.stopGame();

        expect(gameController.currentState, GameState.gameOver);
        expect(gameController.isGameOver, isTrue);
        expect(gameController.isPlaying, isFalse);
      });

      test('should reset game correctly', () async {
        await gameController.startGame();
        await gameController.stopGame();
        await gameController.resetGame();

        expect(gameController.currentState, GameState.playing);
        expect(gameController.score, 0);
        expect(gameController.snake.head, gridSystem.centerPosition);
      });
    });

    group('snake direction control', () {
      test('should change snake direction when playing', () async {
        await gameController.startGame();

        final success = gameController.changeSnakeDirection(Direction.up);

        expect(success, isTrue);
        expect(gameController.snake.nextDirection, Direction.up);
      });

      test('should not change direction when not playing', () {
        final success = gameController.changeSnakeDirection(Direction.up);

        expect(success, isFalse);
        expect(gameController.snake.nextDirection, isNull);
      });

      test('should reject invalid direction changes', () async {
        await gameController.startGame(); // Snake starts going right

        final success = gameController.changeSnakeDirection(Direction.left);

        expect(success, isFalse);
      });
    });

    group('performance tracking', () {
      test('should provide performance metrics', () {
        expect(gameController.currentFps, isA<double>());
        expect(gameController.averageFrameTime, isA<double>());
      });

      test('should provide game statistics', () {
        final stats = gameController.getGameStats();

        expect(stats, containsPair('gameState', isA<String>()));
        expect(stats, containsPair('snakeLength', isA<int>()));
        expect(stats, containsPair('score', isA<int>()));
      });
    });

    group('game state validation', () {
      test('should validate normal game state', () {
        expect(gameController.validateGameState(), isTrue);
      });

      test('should detect invalid snake positions', () {
        // Manually create invalid state for testing
        gameController.snake.reset(
          initialPosition: const Position(25, 25), // Out of bounds
          initialDirection: Direction.right,
          initialLength: 1,
        );

        expect(gameController.validateGameState(), isFalse);
      });
    });

    group('notifications', () {
      test('should notify listeners on state changes', () async {
        var notificationCount = 0;
        gameController.addListener(() => notificationCount++);

        await gameController.startGame();
        await gameController.pauseGame();
        await gameController.resetGame();

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
