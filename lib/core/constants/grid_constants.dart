/// Grid system constants for the Snakes Fight game.
///
/// This class contains all the configuration constants for the grid system
/// that serves as the coordinate system for the entire game.
class GridConstants {
  // Prevent instantiation
  GridConstants._();

  // Default grid dimensions
  static const int defaultGridWidth = 25;
  static const int defaultGridHeight = 25;

  // Cell size constraints
  static const double minCellSize = 15.0;
  static const double maxCellSize = 30.0;
  static const double defaultCellSize = 20.0;

  // Grid layout properties
  static const double gridPadding = 20.0;
  static const double headerHeight = 100.0;

  // Grid boundaries
  static const int minGridWidth = 10;
  static const int maxGridWidth = 50;
  static const int minGridHeight = 10;
  static const int maxGridHeight = 50;

  // Performance thresholds
  static const double maxCoordinateCalculationTime = 1.0; // milliseconds
}
