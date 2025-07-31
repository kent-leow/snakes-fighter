import 'lib/core/models/position.dart';
import 'lib/core/utils/grid_system.dart';
import 'lib/features/game/controllers/game_controller.dart';
import 'lib/features/game/models/direction.dart';

void main() {
  final gridSystem = GridSystem(
    gridWidth: 10,
    gridHeight: 10,
    cellSize: 20.0,
    screenWidth: 200.0,
    screenHeight: 200.0,
  );
  final gameController = GameController(gridSystem: gridSystem);

  print('Initial state:');
  print('Snake head: ${gameController.snake.head}');
  print('Food position: ${gameController.currentFood?.position}');
  print('Score: ${gameController.score}');
  print('Snake length: ${gameController.snake.length}');

  gameController.startGame();

  // Test single step
  print('\nAfter starting game:');
  print('Snake head: ${gameController.snake.head}');
  gameController.stepGame();
  print('After one step: ${gameController.snake.head}');

  // Test food consumption manually
  if (gameController.currentFood != null) {
    final food = gameController.currentFood!;
    print('\nTrying to move snake to food at: ${food.position}');

    // Move snake adjacent to food
    gameController.snake.reset(
      initialPosition: Position(food.position.x - 1, food.position.y),
      initialDirection: Direction.right,
    );

    print('Snake reset to: ${gameController.snake.head}');
    print('Snake direction: ${gameController.snake.currentDirection}');

    // Single step should move to food
    gameController.stepGame();

    print('After step - Snake head: ${gameController.snake.head}');
    print('Food position: ${food.position}');
    print('Food consumed: ${food.isConsumed}');
    print('Score: ${gameController.score}');
    print('Snake should grow: ${gameController.snake.shouldGrow}');
    print('Snake length: ${gameController.snake.length}');
  }

  gameController.dispose();
}
