import 'lib/features/game/models/snake.dart';
import 'lib/features/game/models/direction.dart';
import 'lib/core/models/position.dart';

void main() {
  final snake = Snake(
    initialPosition: const Position(0, 0),
    initialDirection: Direction.right,
    initialLength: 0,
  );
  print('Snake length: ${snake.length}');
  print('Snake body: ${snake.body}');

  // Test the tail calculation issue for left-moving snake
  final leftSnake = Snake(
    initialPosition: const Position(5, 5),
    initialDirection: Direction.left,
  );
  leftSnake.move(); // Move left
  print('Left snake body after move: ${leftSnake.body}');
  print('Left snake tail: ${leftSnake.tail}');
  print('Left snake second-to-last: ${leftSnake.body[leftSnake.length - 2]}');
}
