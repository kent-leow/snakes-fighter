import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/models/food.dart';

void main() {
  group('Food', () {
    group('initialization', () {
      test('should create food with correct position and active state', () {
        const position = Position(5, 10);
        final food = Food(position: position);

        expect(food.position, position);
        expect(food.isActive, isTrue);
        expect(food.isConsumed, isFalse);
      });
    });

    group('consumption', () {
      test('should mark food as consumed when consume is called', () {
        final food = Food(position: const Position(3, 7));

        expect(food.isActive, isTrue);
        expect(food.isConsumed, isFalse);

        food.consume();

        expect(food.isActive, isFalse);
        expect(food.isConsumed, isTrue);
      });

      test('should reset food to active state when reset is called', () {
        final food = Food(position: const Position(1, 1));
        food.consume();

        expect(food.isActive, isFalse);

        food.reset();

        expect(food.isActive, isTrue);
        expect(food.isConsumed, isFalse);
      });
    });

    group('position checking', () {
      test('should correctly identify when food is at a position', () {
        const targetPosition = Position(8, 12);
        final food = Food(position: targetPosition);

        expect(food.isAt(targetPosition), isTrue);
        expect(food.isAt(const Position(8, 11)), isFalse);
        expect(food.isAt(const Position(7, 12)), isFalse);
      });
    });

    group('copying', () {
      test('should create an exact copy of the food', () {
        final originalFood = Food(position: const Position(4, 6));
        originalFood.consume();

        final copiedFood = originalFood.copy();

        expect(copiedFood.position, originalFood.position);
        expect(copiedFood.isActive, originalFood.isActive);
        expect(copiedFood.isConsumed, originalFood.isConsumed);
        expect(copiedFood, isNot(same(originalFood))); // Different instances
      });

      test('should create independent copies', () {
        final originalFood = Food(position: const Position(2, 3));
        final copiedFood = originalFood.copy();

        originalFood.consume();

        expect(originalFood.isConsumed, isTrue);
        expect(copiedFood.isActive, isTrue); // Should remain unaffected
      });
    });

    group('equality and hashing', () {
      test('should be equal when position and state match', () {
        final food1 = Food(position: const Position(1, 2));
        final food2 = Food(position: const Position(1, 2));

        expect(food1, equals(food2));
        expect(food1.hashCode, equals(food2.hashCode));
      });

      test('should not be equal when positions differ', () {
        final food1 = Food(position: const Position(1, 2));
        final food2 = Food(position: const Position(1, 3));

        expect(food1, isNot(equals(food2)));
      });

      test('should not be equal when states differ', () {
        final food1 = Food(position: const Position(1, 2));
        final food2 = Food(position: const Position(1, 2));

        food1.consume();

        expect(food1, isNot(equals(food2)));
      });
    });

    group('string representation', () {
      test('should provide meaningful string representation', () {
        final food = Food(position: const Position(5, 8));

        final stringRep = food.toString();

        expect(stringRep, contains('Position(5, 8)'));
        expect(stringRep, contains('active: true'));
      });

      test('should reflect consumed state in string representation', () {
        final food = Food(position: const Position(3, 4));
        food.consume();

        final stringRep = food.toString();

        expect(stringRep, contains('active: false'));
      });
    });
  });
}
