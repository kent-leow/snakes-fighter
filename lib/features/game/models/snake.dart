import '../../../core/models/position.dart';
import 'direction.dart';

/// Represents a snake in the game with position tracking, movement, and growth.
///
/// The snake consists of a body (list of positions) where the first position
/// is the head. Movement is handled by adding a new head and potentially
/// removing the tail.
class Snake {
  /// The positions that make up the snake's body.
  /// The first position (index 0) is the head.
  final List<Position> _body;

  /// The current direction the snake is moving.
  Direction _currentDirection;

  /// The next direction the snake will move (queued direction change).
  Direction? _nextDirection;

  /// Whether the snake should grow on the next move.
  bool _shouldGrow = false;

  /// Creates a new snake with the given initial position and direction.
  Snake({
    required Position initialPosition,
    required Direction initialDirection,
    int initialLength = 3,
  }) : _body = _generateInitialBody(
         initialPosition,
         initialDirection,
         initialLength,
       ),
       _currentDirection = initialDirection;

  /// Generates the initial body positions for a new snake.
  static List<Position> _generateInitialBody(
    Position head,
    Direction direction,
    int length,
  ) {
    final body = <Position>[head];
    final (dx, dy) = direction.opposite.delta;

    for (int i = 1; i < length; i++) {
      final lastPos = body.last;
      body.add(Position(lastPos.x + dx, lastPos.y + dy));
    }

    return body;
  }

  /// Gets the head position of the snake.
  Position get head => _body.first;

  /// Gets the tail position of the snake.
  Position get tail => _body.last;

  /// Gets an immutable copy of the snake's body positions.
  List<Position> get body => List.unmodifiable(_body);

  /// Gets the current direction of the snake.
  Direction get currentDirection => _currentDirection;

  /// Gets the next queued direction (if any).
  Direction? get nextDirection => _nextDirection;

  /// Gets the length of the snake.
  int get length => _body.length;

  /// Checks if the snake should grow on the next move.
  bool get shouldGrow => _shouldGrow;

  /// Queues a direction change for the next move.
  ///
  /// The direction change will only be applied if it's valid (not opposite
  /// to current direction). Returns true if the direction was queued.
  bool changeDirection(Direction newDirection) {
    if (_currentDirection.canChangeTo(newDirection)) {
      _nextDirection = newDirection;
      return true;
    }
    return false;
  }

  /// Moves the snake one step in its current direction.
  ///
  /// If a direction change is queued, it will be applied before moving.
  /// If the snake should grow, the tail is not removed.
  void move() {
    // Apply queued direction change
    if (_nextDirection != null) {
      _currentDirection = _nextDirection!;
      _nextDirection = null;
    }

    // Calculate new head position
    final (dx, dy) = _currentDirection.delta;
    final newHead = Position(head.x + dx, head.y + dy);

    // Add new head
    _body.insert(0, newHead);

    // Remove tail unless growing
    if (!_shouldGrow) {
      _body.removeLast();
    } else {
      _shouldGrow = false;
    }
  }

  /// Marks the snake to grow on its next move.
  void grow() {
    _shouldGrow = true;
  }

  /// Checks if the snake collides with itself.
  ///
  /// This checks if the head position matches any body segment position.
  bool collidesWithSelf() {
    final headPos = head;
    return _body.skip(1).any((pos) => pos == headPos);
  }

  /// Checks if the snake's head is at the given position.
  bool isHeadAt(Position position) {
    return head == position;
  }

  /// Checks if any part of the snake's body is at the given position.
  bool isBodyAt(Position position) {
    return _body.contains(position);
  }

  /// Checks if the snake's body (excluding head) is at the given position.
  bool isBodyExcludingHeadAt(Position position) {
    return _body.skip(1).contains(position);
  }

  /// Gets all positions occupied by the snake's body.
  Set<Position> get occupiedPositions => Set.from(_body);

  /// Creates a copy of this snake with the same state.
  Snake copy() {
    final newSnake = Snake(
      initialPosition: _body.first,
      initialDirection: _currentDirection,
      initialLength: 1,
    );

    // Copy the body
    newSnake._body.clear();
    newSnake._body.addAll(_body);

    // Copy the state
    newSnake._currentDirection = _currentDirection;
    newSnake._nextDirection = _nextDirection;
    newSnake._shouldGrow = _shouldGrow;

    return newSnake;
  }

  /// Resets the snake to its initial state.
  void reset({
    required Position initialPosition,
    required Direction initialDirection,
    int initialLength = 3,
  }) {
    _body.clear();
    _body.addAll(
      _generateInitialBody(initialPosition, initialDirection, initialLength),
    );
    _currentDirection = initialDirection;
    _nextDirection = null;
    _shouldGrow = false;
  }

  @override
  String toString() {
    return 'Snake(length: ${_body.length}, head: $head, direction: $_currentDirection)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Snake &&
        other._body.length == _body.length &&
        other._currentDirection == _currentDirection &&
        other._nextDirection == _nextDirection &&
        other._shouldGrow == _shouldGrow &&
        _listsEqual(other._body, _body);
  }

  @override
  int get hashCode {
    return Object.hash(
      _body.length,
      _currentDirection,
      _nextDirection,
      _shouldGrow,
      Object.hashAll(_body),
    );
  }

  /// Helper method to compare two lists for equality.
  static bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
