import '../models/food.dart';
import '../models/snake.dart';

/// Handles food consumption detection and processing.
///
/// This system manages the logic for detecting when a snake consumes food
/// and handles the consumption event including snake growth triggering.
class ConsumptionSystem {
  /// Checks if the snake's head is at the same position as active food.
  ///
  /// Returns true if the snake head position matches the food position
  /// and the food is currently active.
  static bool checkFoodConsumption(Snake snake, Food food) {
    if (!food.isActive) {
      return false; // Food is already consumed
    }

    return snake.isHeadAt(food.position);
  }

  /// Handles the food consumption event.
  ///
  /// This method:
  /// 1. Marks the food as consumed
  /// 2. Triggers snake growth
  /// 3. Returns true if consumption was processed successfully
  ///
  /// Returns false if the food was already consumed or other error occurred.
  static bool handleFoodConsumption(Snake snake, Food food) {
    if (!checkFoodConsumption(snake, food)) {
      return false; // No consumption occurred
    }

    // Mark food as consumed
    food.consume();

    // Trigger snake growth
    snake.grow();

    return true;
  }

  /// Processes consumption for multiple food items.
  ///
  /// Checks all food items in the list and processes consumption for any
  /// that are being consumed by the snake. Returns the number of food
  /// items that were consumed.
  static int processFoodConsumption(Snake snake, List<Food> foodList) {
    int consumedCount = 0;

    for (final food in foodList) {
      if (handleFoodConsumption(snake, food)) {
        consumedCount++;
      }
    }

    return consumedCount;
  }

  /// Checks if any food in the list is being consumed by the snake.
  ///
  /// Returns true if at least one food item is at the snake's head position
  /// and is active.
  static bool hasAnyFoodConsumption(Snake snake, List<Food> foodList) {
    for (final food in foodList) {
      if (checkFoodConsumption(snake, food)) {
        return true;
      }
    }
    return false;
  }

  /// Gets the first food item that would be consumed by the snake.
  ///
  /// Returns the first active food item at the snake's head position,
  /// or null if no food is being consumed.
  static Food? getConsumableFood(Snake snake, List<Food> foodList) {
    for (final food in foodList) {
      if (checkFoodConsumption(snake, food)) {
        return food;
      }
    }
    return null;
  }

  /// Validates that food consumption is possible.
  ///
  /// Returns true if the snake head position matches the food position
  /// and both the snake and food are in valid states.
  static bool canConsumeFood(Snake snake, Food food) {
    // Food must be active
    if (!food.isActive) {
      return false;
    }

    // Snake must have a valid head position
    if (snake.length == 0) {
      return false;
    }

    // Positions must match
    return snake.isHeadAt(food.position);
  }
}
