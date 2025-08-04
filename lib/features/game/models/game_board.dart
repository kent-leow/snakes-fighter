import '../../../core/models/position.dart';

/// Represents the game board for multiplayer games.
class GameBoard {
  /// The width of the board in grid units.
  final int width;
  
  /// The height of the board in grid units.
  final int height;
  
  /// Creates a new game board with the specified dimensions.
  const GameBoard({
    required this.width,
    required this.height,
  });
  
  /// Default board size for multiplayer games.
  static const GameBoard defaultBoard = GameBoard(width: 25, height: 25);
  
  /// Checks if a position is within the board boundaries.
  bool isValidPosition(Position position) {
    return position.x >= 0 && 
           position.x < width && 
           position.y >= 0 && 
           position.y < height;
  }
  
  /// Gets the center position of the board.
  Position get center => Position(width ~/ 2, height ~/ 2);
  
  /// Gets the total number of cells on the board.
  int get totalCells => width * height;
  
  /// Gets all valid positions on the board.
  List<Position> get allPositions {
    final positions = <Position>[];
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        positions.add(Position(x, y));
      }
    }
    return positions;
  }
  
  @override
  String toString() => 'GameBoard(${width}x$height)';
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is GameBoard && 
         other.width == width && 
         other.height == height);
  }
  
  @override
  int get hashCode => Object.hash(width, height);
}
