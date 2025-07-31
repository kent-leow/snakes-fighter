import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/logic/consumption_system.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/food.dart';
import 'package:snakes_fight/features/game/models/snake.dart';

void main() {
  group('ConsumptionSystem', () {
    late Snake snake;
    late Food food;

    setUp(() {
      snake = Snake(
        initialPosition: const Position(5, 5),
        initialDirection: Direction.right,
      );
      food = Food(position: const Position(6, 5)); // Right of snake head
    });

    group('checkFoodConsumption', () {
      test('should return true when snake head is at food position', () {
        // Move snake head to food position
        snake.move(); // Snake moves right to (6, 5)

        final result = ConsumptionSystem.checkFoodConsumption(snake, food);

        expect(result, isTrue);
      });

      test('should return false when snake head is not at food position', () {
        // Snake head is at (5, 5), food is at (6, 5)
        final result = ConsumptionSystem.checkFoodConsumption(snake, food);

        expect(result, isFalse);
      });

      test('should return false when food is already consumed', () {
        // Move snake to food position
        snake.move(); // Snake moves to (6, 5)
        food.consume(); // Mark food as consumed

        final result = ConsumptionSystem.checkFoodConsumption(snake, food);

        expect(result, isFalse);
      });
    });

    group('handleFoodConsumption', () {
      test('should handle consumption when snake head reaches food', () {
        // Move snake to food position
        snake.move(); // Snake moves to (6, 5)

        final result = ConsumptionSystem.handleFoodConsumption(snake, food);

        expect(result, isTrue);
        expect(food.isConsumed, isTrue);
        expect(snake.shouldGrow, isTrue);
      });

      test('should return false when no consumption occurs', () {
        // Snake head is not at food position
        final result = ConsumptionSystem.handleFoodConsumption(snake, food);

        expect(result, isFalse);
        expect(food.isActive, isTrue);
        expect(snake.shouldGrow, isFalse);
      });

      test('should not process already consumed food', () {
        food.consume(); // Pre-consume the food
        snake.move(); // Move snake to food position

        final result = ConsumptionSystem.handleFoodConsumption(snake, food);

        expect(result, isFalse);
        expect(snake.shouldGrow, isFalse);
      });
    });

    group('processFoodConsumption', () {
      test('should process multiple food items', () {
        final foodList = [
          Food(position: const Position(6, 5)), // At snake's next position
          Food(position: const Position(7, 7)), // Not at snake position
          Food(position: const Position(8, 8)), // Not at snake position
        ];

        snake.move(); // Move snake to (6, 5)

        final consumedCount = ConsumptionSystem.processFoodConsumption(
          snake,
          foodList,
        );

        expect(consumedCount, 1);
        expect(foodList[0].isConsumed, isTrue);
        expect(foodList[1].isActive, isTrue);
        expect(foodList[2].isActive, isTrue);
      });

      test('should return zero when no food is consumed', () {
        final foodList = [
          Food(position: const Position(7, 7)),
          Food(position: const Position(8, 8)),
        ];

        final consumedCount = ConsumptionSystem.processFoodConsumption(
          snake,
          foodList,
        );

        expect(consumedCount, 0);
        expect(foodList.every((f) => f.isActive), isTrue);
      });

      test('should handle empty food list', () {
        final consumedCount = ConsumptionSystem.processFoodConsumption(
          snake,
          [],
        );

        expect(consumedCount, 0);
      });
    });

    group('hasAnyFoodConsumption', () {
      test('should return true when any food can be consumed', () {
        final foodList = [
          Food(position: const Position(7, 7)), // Not consumable
          Food(position: const Position(6, 5)), // Consumable after move
        ];

        snake.move(); // Move snake to (6, 5)

        final hasConsumption = ConsumptionSystem.hasAnyFoodConsumption(
          snake,
          foodList,
        );

        expect(hasConsumption, isTrue);
      });

      test('should return false when no food can be consumed', () {
        final foodList = [
          Food(position: const Position(7, 7)),
          Food(position: const Position(8, 8)),
        ];

        final hasConsumption = ConsumptionSystem.hasAnyFoodConsumption(
          snake,
          foodList,
        );

        expect(hasConsumption, isFalse);
      });
    });

    group('getConsumableFood', () {
      test('should return first consumable food', () {
        final foodList = [
          Food(position: const Position(7, 7)), // Not consumable
          Food(position: const Position(6, 5)), // Consumable
          Food(position: const Position(6, 5)), // Also consumable
        ];

        snake.move(); // Move snake to (6, 5)

        final consumableFood = ConsumptionSystem.getConsumableFood(
          snake,
          foodList,
        );

        expect(consumableFood, equals(foodList[1]));
      });

      test('should return null when no food is consumable', () {
        final foodList = [
          Food(position: const Position(7, 7)),
          Food(position: const Position(8, 8)),
        ];

        final consumableFood = ConsumptionSystem.getConsumableFood(
          snake,
          foodList,
        );

        expect(consumableFood, isNull);
      });
    });

    group('canConsumeFood', () {
      test('should return true for valid consumption scenario', () {
        snake.move(); // Move snake to food position

        final canConsume = ConsumptionSystem.canConsumeFood(snake, food);

        expect(canConsume, isTrue);
      });

      test('should return false when food is inactive', () {
        snake.move(); // Move snake to food position
        food.consume(); // Make food inactive

        final canConsume = ConsumptionSystem.canConsumeFood(snake, food);

        expect(canConsume, isFalse);
      });

      test('should return false when positions do not match', () {
        // Snake at (5, 5), food at (6, 5)
        final canConsume = ConsumptionSystem.canConsumeFood(snake, food);

        expect(canConsume, isFalse);
      });

      test('should return false for empty snake', () {
        final emptySnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 0,
        );

        final canConsume = ConsumptionSystem.canConsumeFood(emptySnake, food);

        expect(canConsume, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle consumption at grid boundaries', () {
        final boundarySnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
        );
        final boundaryFood = Food(position: const Position(0, 0));

        final result = ConsumptionSystem.handleFoodConsumption(
          boundarySnake,
          boundaryFood,
        );

        expect(result, isTrue);
        expect(boundaryFood.isConsumed, isTrue);
        expect(boundarySnake.shouldGrow, isTrue);
      });

      test('should handle multiple consecutive consumptions', () {
        final food1 = Food(position: const Position(6, 5));
        final food2 = Food(position: const Position(7, 5));

        // First consumption
        snake.move(); // Snake moves to (6, 5)
        ConsumptionSystem.handleFoodConsumption(snake, food1);

        // Second consumption
        snake.move(); // Snake moves to (7, 5)
        final result2 = ConsumptionSystem.handleFoodConsumption(snake, food2);

        expect(result2, isTrue);
        expect(food1.isConsumed, isTrue);
        expect(food2.isConsumed, isTrue);
      });
    });
  });
}
