import '../constants/grid_constants.dart';
import '../models/position.dart';

/// Utility class for validating grid-related operations and constraints.
///
/// This class provides static methods for validating positions, grid dimensions,
/// and other grid-related parameters to prevent errors and ensure data integrity.
class GridValidator {
  // Prevent instantiation
  GridValidator._();

  /// Checks if a position is within the specified grid boundaries.
  ///
  /// Returns true if the position is within bounds (0 <= x < width, 0 <= y < height).
  static bool isInBounds(Position position, int width, int height) {
    return position.x >= 0 &&
        position.x < width &&
        position.y >= 0 &&
        position.y < height;
  }

  /// Validates if the grid dimensions are within acceptable limits.
  ///
  /// Returns true if both width and height are within the valid range
  /// defined in GridConstants.
  static bool isValidGridSize(int width, int height) {
    return width >= GridConstants.minGridWidth &&
        width <= GridConstants.maxGridWidth &&
        height >= GridConstants.minGridHeight &&
        height <= GridConstants.maxGridHeight;
  }

  /// Validates if the cell size is within acceptable limits.
  ///
  /// Returns true if the cell size is between the minimum and maximum
  /// values defined in GridConstants.
  static bool isValidCellSize(double cellSize) {
    return cellSize >= GridConstants.minCellSize &&
        cellSize <= GridConstants.maxCellSize;
  }

  /// Filters a list of positions to only include those within bounds.
  ///
  /// Returns a new list containing only positions that are within
  /// the specified grid dimensions.
  static List<Position> filterValidPositions(
    List<Position> positions,
    int width,
    int height,
  ) {
    return positions
        .where((position) => isInBounds(position, width, height))
        .toList();
  }

  /// Validates if a position is on the border of the grid.
  ///
  /// Returns true if the position is on any edge of the grid.
  static bool isOnBorder(Position position, int width, int height) {
    if (!isInBounds(position, width, height)) return false;

    return position.x == 0 ||
        position.x == width - 1 ||
        position.y == 0 ||
        position.y == height - 1;
  }

  /// Validates if a position is in the corner of the grid.
  ///
  /// Returns true if the position is at any of the four corners.
  static bool isInCorner(Position position, int width, int height) {
    if (!isInBounds(position, width, height)) return false;

    return (position.x == 0 || position.x == width - 1) &&
        (position.y == 0 || position.y == height - 1);
  }

  /// Validates if all positions in a list are within bounds.
  ///
  /// Returns true only if all positions are valid.
  static bool areAllPositionsValid(
    List<Position> positions,
    int width,
    int height,
  ) {
    return positions.every((position) => isInBounds(position, width, height));
  }

  /// Validates if a list of positions contains any duplicates.
  ///
  /// Returns true if there are duplicate positions in the list.
  static bool hasDuplicatePositions(List<Position> positions) {
    final seen = <Position>{};
    for (final position in positions) {
      if (!seen.add(position)) {
        return true;
      }
    }
    return false;
  }

  /// Validates if a path of positions is continuous (each position is adjacent to the next).
  ///
  /// Returns true if each position in the path is directly adjacent to the next one.
  static bool isValidPath(List<Position> path) {
    if (path.length < 2) return true;

    for (int i = 0; i < path.length - 1; i++) {
      if (!path[i].isDirectlyAdjacentTo(path[i + 1])) {
        return false;
      }
    }
    return true;
  }

  /// Validates screen dimensions for grid display.
  ///
  /// Returns true if the screen dimensions are sufficient for the minimum grid requirements.
  static bool isValidScreenSize(double width, double height) {
    const minRequiredWidth =
        GridConstants.minGridWidth * GridConstants.minCellSize +
        (GridConstants.gridPadding * 2);
    const minRequiredHeight =
        GridConstants.minGridHeight * GridConstants.minCellSize +
        GridConstants.headerHeight +
        (GridConstants.gridPadding * 2);

    return width >= minRequiredWidth && height >= minRequiredHeight;
  }

  /// Validates if a region (rectangle) defined by two positions is valid.
  ///
  /// Returns true if both positions are in bounds and form a valid rectangle.
  static bool isValidRegion(
    Position topLeft,
    Position bottomRight,
    int width,
    int height,
  ) {
    return isInBounds(topLeft, width, height) &&
        isInBounds(bottomRight, width, height) &&
        topLeft.x <= bottomRight.x &&
        topLeft.y <= bottomRight.y;
  }
}
