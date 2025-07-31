import 'package:flutter/material.dart';

/// Handles rendering of the background grid on the game canvas.
///
/// This renderer provides optional grid lines to help with
/// game navigation without interfering with gameplay.
class GridRenderer {
  // Grid colors
  static const Color _gridLineColor = Color(0xFF424242);     // Dark gray
  static const Color _gridBackgroundColor = Color(0xFF212121); // Very dark gray
  
  // Visual properties
  static const double _gridLineWidth = 0.5;
  static const double _gridOpacity = 0.3;

  /// Renders the background grid on the canvas.
  ///
  /// [canvas] The canvas to draw on
  /// [canvasSize] The size of the canvas
  /// [gridSize] The size of the grid (width x height in cells)
  /// [cellSize] The size of each grid cell
  static void renderGrid(
    Canvas canvas,
    Size canvasSize,
    Size gridSize,
    Size cellSize,
  ) {
    // Draw background
    _renderGridBackground(canvas, canvasSize);
    
    // Draw grid lines
    _renderGridLines(canvas, canvasSize, gridSize, cellSize);
  }

  /// Renders a subtle background for the grid.
  static void _renderGridBackground(Canvas canvas, Size canvasSize) {
    final backgroundPaint = Paint()
      ..color = _gridBackgroundColor.withOpacity(_gridOpacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      backgroundPaint,
    );
  }

  /// Renders the grid lines.
  static void _renderGridLines(
    Canvas canvas,
    Size canvasSize,
    Size gridSize,
    Size cellSize,
  ) {
    final linePaint = Paint()
      ..color = _gridLineColor.withOpacity(_gridOpacity)
      ..strokeWidth = _gridLineWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int x = 0; x <= gridSize.width; x++) {
      final xPos = x * cellSize.width;
      canvas.drawLine(
        Offset(xPos, 0),
        Offset(xPos, canvasSize.height),
        linePaint,
      );
    }

    // Draw horizontal lines
    for (int y = 0; y <= gridSize.height; y++) {
      final yPos = y * cellSize.height;
      canvas.drawLine(
        Offset(0, yPos),
        Offset(canvasSize.width, yPos),
        linePaint,
      );
    }
  }

  /// Renders a highlighted cell at the specified position.
  ///
  /// [canvas] The canvas to draw on
  /// [x] Grid x coordinate
  /// [y] Grid y coordinate
  /// [cellSize] The size of each grid cell
  /// [color] The highlight color
  static void renderHighlightedCell(
    Canvas canvas,
    int x,
    int y,
    Size cellSize,
    Color color,
  ) {
    final highlightPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromLTWH(
      x * cellSize.width,
      y * cellSize.height,
      cellSize.width,
      cellSize.height,
    );
    
    canvas.drawRect(rect, highlightPaint);
  }

  /// Renders multiple highlighted cells.
  ///
  /// [canvas] The canvas to draw on
  /// [positions] List of (x, y) coordinates to highlight
  /// [cellSize] The size of each grid cell
  /// [color] The highlight color
  static void renderHighlightedCells(
    Canvas canvas,
    List<(int, int)> positions,
    Size cellSize,
    Color color,
  ) {
    for (final (x, y) in positions) {
      renderHighlightedCell(canvas, x, y, cellSize, color);
    }
  }

  /// Renders a border around the grid area.
  ///
  /// [canvas] The canvas to draw on
  /// [canvasSize] The size of the canvas
  /// [color] The border color
  /// [width] The border width
  static void renderGridBorder(
    Canvas canvas,
    Size canvasSize,
    Color color,
    double width,
  ) {
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      borderPaint,
    );
  }

  /// Renders a checkerboard pattern background.
  ///
  /// [canvas] The canvas to draw on
  /// [gridSize] The size of the grid (width x height in cells)
  /// [cellSize] The size of each grid cell
  /// [lightColor] Color for light squares
  /// [darkColor] Color for dark squares
  static void renderCheckerboard(
    Canvas canvas,
    Size gridSize,
    Size cellSize,
    Color lightColor,
    Color darkColor,
  ) {
    for (int x = 0; x < gridSize.width; x++) {
      for (int y = 0; y < gridSize.height; y++) {
        final isEven = (x + y) % 2 == 0;
        final color = isEven ? lightColor : darkColor;
        
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        
        final rect = Rect.fromLTWH(
          x * cellSize.width,
          y * cellSize.height,
          cellSize.width,
          cellSize.height,
        );
        
        canvas.drawRect(rect, paint);
      }
    }
  }

  /// Renders grid coordinates for debugging.
  ///
  /// [canvas] The canvas to draw on
  /// [gridSize] The size of the grid (width x height in cells)
  /// [cellSize] The size of each grid cell
  /// [textStyle] Style for the coordinate text
  static void renderGridCoordinates(
    Canvas canvas,
    Size gridSize,
    Size cellSize,
    TextStyle textStyle,
  ) {
    for (int x = 0; x < gridSize.width; x++) {
      for (int y = 0; y < gridSize.height; y++) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '($x,$y)',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        final offset = Offset(
          x * cellSize.width + (cellSize.width - textPainter.width) / 2,
          y * cellSize.height + (cellSize.height - textPainter.height) / 2,
        );
        
        textPainter.paint(canvas, offset);
      }
    }
  }

  /// Gets the grid cell at a given screen position.
  ///
  /// [screenPosition] The position on the screen
  /// [cellSize] The size of each grid cell
  /// Returns the (x, y) grid coordinates or null if outside grid
  static (int, int)? getGridCellAtPosition(
    Offset screenPosition,
    Size cellSize,
  ) {
    if (screenPosition.dx < 0 || screenPosition.dy < 0) {
      return null;
    }
    
    final x = (screenPosition.dx / cellSize.width).floor();
    final y = (screenPosition.dy / cellSize.height).floor();
    
    return (x, y);
  }

  /// Gets the screen position of a grid cell center.
  ///
  /// [x] Grid x coordinate
  /// [y] Grid y coordinate
  /// [cellSize] The size of each grid cell
  static Offset getCellCenterPosition(int x, int y, Size cellSize) {
    return Offset(
      x * cellSize.width + cellSize.width / 2,
      y * cellSize.height + cellSize.height / 2,
    );
  }
}
