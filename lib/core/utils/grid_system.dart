import 'dart:math' as math;
import 'dart:ui';

import '../constants/grid_constants.dart';
import '../models/position.dart';

/// Grid coordinate system that handles conversions between grid coordinates
/// and screen coordinates, along with grid properties and calculations.
class GridSystem {
  /// The width of the grid in cells.
  final int gridWidth;

  /// The height of the grid in cells.
  final int gridHeight;

  /// The size of each cell in pixels.
  final double cellSize;

  /// The screen width available for the grid.
  final double screenWidth;

  /// The screen height available for the grid.
  final double screenHeight;

  /// Creates a new grid system with the specified parameters.
  GridSystem({
    required this.gridWidth,
    required this.gridHeight,
    required this.cellSize,
    required this.screenWidth,
    required this.screenHeight,
  }) : assert(gridWidth > 0, 'Grid width must be positive'),
       assert(gridHeight > 0, 'Grid height must be positive'),
       assert(cellSize > 0, 'Cell size must be positive');

  /// Creates a grid system that automatically calculates the optimal cell size
  /// to fit the given screen dimensions.
  factory GridSystem.adaptive({
    required int gridWidth,
    required int gridHeight,
    required double screenWidth,
    required double screenHeight,
  }) {
    final availableWidth = screenWidth - (GridConstants.gridPadding * 2);
    final availableHeight =
        screenHeight -
        GridConstants.headerHeight -
        (GridConstants.gridPadding * 2);

    final cellWidthConstraint = availableWidth / gridWidth;
    final cellHeightConstraint = availableHeight / gridHeight;

    final optimalCellSize = math.min(cellWidthConstraint, cellHeightConstraint);
    final cellSize = optimalCellSize.clamp(
      GridConstants.minCellSize,
      GridConstants.maxCellSize,
    );

    return GridSystem(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      cellSize: cellSize,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  /// Converts a grid position to screen coordinates (top-left corner of cell).
  Offset gridToScreen(Position gridPos) {
    final gridPixelWidth = gridWidth * cellSize;
    final gridPixelHeight = gridHeight * cellSize;

    final gridStartX = (screenWidth - gridPixelWidth) / 2;
    final gridStartY = (screenHeight - gridPixelHeight) / 2;

    return Offset(
      gridStartX + (gridPos.x * cellSize),
      gridStartY + (gridPos.y * cellSize),
    );
  }

  /// Converts a grid position to the center of the cell in screen coordinates.
  Offset gridToScreenCenter(Position gridPos) {
    final topLeft = gridToScreen(gridPos);
    return Offset(topLeft.dx + cellSize / 2, topLeft.dy + cellSize / 2);
  }

  /// Converts screen coordinates to grid position.
  Position screenToGrid(Offset screenPos) {
    final gridPixelWidth = gridWidth * cellSize;
    final gridPixelHeight = gridHeight * cellSize;

    final gridStartX = (screenWidth - gridPixelWidth) / 2;
    final gridStartY = (screenHeight - gridPixelHeight) / 2;

    final gridX = ((screenPos.dx - gridStartX) / cellSize).floor();
    final gridY = ((screenPos.dy - gridStartY) / cellSize).floor();

    return Position(gridX, gridY);
  }

  /// Gets the total screen size occupied by the grid.
  Size get gridScreenSize => Size(gridWidth * cellSize, gridHeight * cellSize);

  /// Gets the logical grid size.
  Size get gridLogicalSize => Size(gridWidth.toDouble(), gridHeight.toDouble());

  /// Gets the bounding rectangle of the grid in screen coordinates.
  Rect get gridScreenBounds {
    final topLeft = gridToScreen(const Position(0, 0));
    return Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      gridWidth * cellSize,
      gridHeight * cellSize,
    );
  }

  /// Gets the bounding rectangle of the grid in logical coordinates.
  Rect get gridLogicalBounds {
    return Rect.fromLTWH(0, 0, gridWidth.toDouble(), gridHeight.toDouble());
  }

  /// Checks if the given position is within the grid boundaries.
  bool isValidPosition(Position pos) {
    return pos.x >= 0 && pos.x < gridWidth && pos.y >= 0 && pos.y < gridHeight;
  }

  /// Generates a random position within the grid boundaries.
  Position getRandomPosition([math.Random? random]) {
    final rng = random ?? math.Random();
    return Position(rng.nextInt(gridWidth), rng.nextInt(gridHeight));
  }

  /// Gets all valid positions in the grid.
  List<Position> getAllPositions() {
    final positions = <Position>[];
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        positions.add(Position(x, y));
      }
    }
    return positions;
  }

  /// Gets all positions along the border of the grid.
  List<Position> getBorderPositions() {
    final positions = <Position>[];

    // Top and bottom edges
    for (int x = 0; x < gridWidth; x++) {
      positions.add(Position(x, 0));
      positions.add(Position(x, gridHeight - 1));
    }

    // Left and right edges (excluding corners already added)
    for (int y = 1; y < gridHeight - 1; y++) {
      positions.add(Position(0, y));
      positions.add(Position(gridWidth - 1, y));
    }

    return positions;
  }

  /// Gets the center position of the grid.
  Position get centerPosition => Position(gridWidth ~/ 2, gridHeight ~/ 2);

  /// Calculates the total number of cells in the grid.
  int get totalCells => gridWidth * gridHeight;

  /// Creates a copy of this grid system with modified parameters.
  GridSystem copyWith({
    int? gridWidth,
    int? gridHeight,
    double? cellSize,
    double? screenWidth,
    double? screenHeight,
  }) {
    return GridSystem(
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      cellSize: cellSize ?? this.cellSize,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
    );
  }

  @override
  String toString() {
    return 'GridSystem(${gridWidth}x$gridHeight, cellSize: $cellSize)';
  }
}
