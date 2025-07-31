import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/controllers/input_controller.dart';
import 'package:snakes_fight/features/game/models/direction.dart';

void main() {
  group('InputController', () {
    late GridSystem gridSystem;
    late GameController gameController;
    late InputController inputController;

    setUp(() {
      gridSystem = GridSystem(
        gridWidth: 20,
        gridHeight: 20,
        cellSize: 20.0,
        screenWidth: 400.0,
        screenHeight: 400.0,
      );
      gameController = GameController(gridSystem: gridSystem);
      inputController = InputController(gameController: gameController);
    });

    tearDown(() {
      gameController.dispose();
    });

    group('touch input', () {
      test('should handle horizontal swipes', () {
        gameController.startGame();

        // Right swipe
        var handled = inputController.handleSwipe(deltaX: 100.0, deltaY: 10.0);
        expect(handled, isTrue);
        expect(gameController.snake.nextDirection, Direction.right);

        // Left swipe (should fail as backwards)
        handled = inputController.handleSwipe(deltaX: -100.0, deltaY: 10.0);
        expect(handled, isFalse);
      });

      test('should handle vertical swipes', () {
        gameController.startGame();

        // Up swipe (valid since snake starts going right)
        var handled = inputController.handleSwipe(deltaX: 10.0, deltaY: -100.0);
        expect(handled, isTrue);
        expect(gameController.snake.nextDirection, Direction.up);

        // Test with a fresh game controller to avoid direction conflicts
        final newGameController = GameController(gridSystem: gridSystem);
        final newInputController = InputController(
          gameController: newGameController,
        );
        newGameController.startGame();

        // Down swipe (valid since snake starts going right)
        handled = newInputController.handleSwipe(deltaX: 10.0, deltaY: 100.0);
        expect(handled, isTrue);
        expect(newGameController.snake.nextDirection, Direction.down);

        newGameController.dispose();
      });

      test('should ignore swipes below sensitivity threshold', () {
        gameController.startGame();

        final handled = inputController.handleSwipe(deltaX: 20.0, deltaY: 10.0);

        expect(handled, isFalse);
        expect(gameController.snake.nextDirection, isNull);
      });

      test('should handle tap for game control', () {
        final handled = inputController.handleTap();

        expect(handled, isTrue);
        expect(gameController.gameState, GameState.playing);
      });

      test('should adjust touch sensitivity', () {
        inputController.setTouchSensitivity(100.0);
        expect(inputController.touchSensitivity, 100.0);

        // Should ignore invalid sensitivity
        inputController.setTouchSensitivity(-10.0);
        expect(inputController.touchSensitivity, 100.0);
      });
    });

    group('state management', () {
      test('should clear pressed keys', () {
        inputController.clearPressedKeys();
        expect(inputController.pressedKeys, isEmpty);
      });

      test('should reset input state', () {
        inputController.reset();
        expect(inputController.pressedKeys, isEmpty);
      });

      test('should provide input statistics', () {
        final stats = inputController.getInputStats();

        expect(stats, containsPair('pressedKeysCount', isA<int>()));
        expect(stats, containsPair('touchSensitivity', isA<double>()));
        expect(stats, containsPair('throttleMs', isA<int>()));
      });
    });

    group('edge cases', () {
      test('should handle input when game is not playing', () {
        // Game is idle - swipe should not work
        final handled = inputController.handleSwipe(
          deltaX: 100.0,
          deltaY: 10.0,
        );
        expect(handled, isFalse);
      });

      test('should handle swipe with zero delta', () {
        gameController.startGame();

        final handled = inputController.handleSwipe(deltaX: 0.0, deltaY: 0.0);

        expect(handled, isFalse);
      });
    });

    group('notifications', () {
      test('should notify listeners on state changes', () {
        var notificationCount = 0;
        inputController.addListener(() => notificationCount++);

        inputController.setTouchSensitivity(75.0);
        inputController.clearPressedKeys();
        inputController.reset();

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
