import '../../../core/models/position.dart';

/// Represents food in the game that can be consumed by the snake.
///
/// Food has a position on the grid and can be in an active or consumed state.
/// When consumed, food is marked as inactive and should trigger snake growth.
class Food {
  /// The position of the food on the grid.
  final Position _position;

  /// Whether the food is currently active (not consumed).
  bool _isActive;

  /// Creates new food at the specified position.
  Food({required Position position}) : _position = position, _isActive = true;

  /// Gets the position of the food.
  Position get position => _position;

  /// Gets whether the food is currently active.
  bool get isActive => _isActive;

  /// Gets whether the food has been consumed.
  bool get isConsumed => !_isActive;

  /// Marks the food as consumed.
  ///
  /// Once consumed, the food becomes inactive and should be removed
  /// from the game or replaced with new food.
  void consume() {
    _isActive = false;
  }

  /// Resets the food to its active state.
  ///
  /// This can be useful for object reuse or resetting game state.
  void reset() {
    _isActive = true;
  }

  /// Checks if the food is at the given position.
  bool isAt(Position position) {
    return _position == position;
  }

  /// Creates a copy of this food with the same state.
  Food copy() {
    final newFood = Food(position: _position);
    newFood._isActive = _isActive;
    return newFood;
  }

  @override
  String toString() {
    return 'Food(position: $_position, active: $_isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food &&
        other._position == _position &&
        other._isActive == _isActive;
  }

  @override
  int get hashCode {
    return Object.hash(_position, _isActive);
  }
}
