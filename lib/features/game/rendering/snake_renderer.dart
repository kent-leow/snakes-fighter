import 'package:flutter/material.dart';

import '../../../core/models/position.dart';
import '../controllers/game_state_manager.dart';
import '../models/snake.dart';

/// Handles rendering of the snake on the game canvas.
///
/// This renderer provides methods to draw the snake with distinct
/// head and body segments, optimized for performance.
class SnakeRenderer {
  // Snake colors
  static const Color _headColor = Color(0xFF4CAF50);  // Green
  static const Color _bodyColor = Color(0xFF81C784);  // Light green
  static const Color _deadColor = Color(0xFF757575);  // Gray
  
  // Visual properties
  static const double _borderRadius = 2.0;
  static const double _headScale = 0.9;
  static const double _bodyScale = 0.8;

  /// Renders the complete snake on the canvas.
  ///
  /// [canvas] The canvas to draw on
  /// [snake] The snake to render
  /// [cellSize] The size of each grid cell
  /// [gameState] Current game state for visual effects
  static void renderSnake(
    Canvas canvas,
    Snake snake,
    Size cellSize,
    GameState gameState,
  ) {
    if (snake.body.isEmpty) return;
    
    final isDead = gameState == GameState.gameOver;
    
    // Render body segments first (so head appears on top)
    for (int i = 1; i < snake.body.length; i++) {
      renderSnakeBody(
        canvas,
        snake.body[i],
        cellSize,
        isDead,
      );
    }
    
    // Render head last
    renderSnakeHead(
      canvas,
      snake.head,
      cellSize,
      isDead,
    );
  }

  /// Renders the snake's head.
  ///
  /// [canvas] The canvas to draw on
  /// [headPosition] The position of the head
  /// [cellSize] The size of each grid cell
  /// [isDead] Whether the snake is dead (affects color)
  static void renderSnakeHead(
    Canvas canvas,
    Position headPosition,
    Size cellSize,
    bool isDead,
  ) {
    final paint = Paint()
      ..color = isDead ? _deadColor : _headColor
      ..style = PaintingStyle.fill;
    
    final rect = _getScaledRect(
      headPosition,
      cellSize,
      _headScale,
    );
    
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );
    
    canvas.drawRRect(rrect, paint);
    
    // Add eyes if alive
    if (!isDead) {
      _renderEyes(canvas, rect);
    }
  }

  /// Renders a snake body segment.
  ///
  /// [canvas] The canvas to draw on
  /// [bodyPosition] The position of the body segment
  /// [cellSize] The size of each grid cell
  /// [isDead] Whether the snake is dead (affects color)
  static void renderSnakeBody(
    Canvas canvas,
    Position bodyPosition,
    Size cellSize,
    bool isDead,
  ) {
    final paint = Paint()
      ..color = isDead ? _deadColor : _bodyColor
      ..style = PaintingStyle.fill;
    
    final rect = _getScaledRect(
      bodyPosition,
      cellSize,
      _bodyScale,
    );
    
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );
    
    canvas.drawRRect(rrect, paint);
  }

  /// Renders the complete snake body (excluding head).
  ///
  /// [canvas] The canvas to draw on
  /// [bodyPositions] List of body segment positions
  /// [cellSize] The size of each grid cell
  /// [isDead] Whether the snake is dead (affects color)
  static void renderSnakeBodyOnly(
    Canvas canvas,
    List<Position> bodyPositions,
    Size cellSize,
    bool isDead,
  ) {
    for (final position in bodyPositions.skip(1)) {
      renderSnakeBody(canvas, position, cellSize, isDead);
    }
  }

  /// Gets a scaled rectangle for rendering a snake segment.
  ///
  /// [position] Grid position of the segment
  /// [cellSize] Size of each grid cell
  /// [scale] Scale factor (0.0 to 1.0)
  static Rect _getScaledRect(
    Position position,
    Size cellSize,
    double scale,
  ) {
    final x = position.x * cellSize.width;
    final y = position.y * cellSize.height;
    
    final padding = (1.0 - scale) / 2.0;
    final paddingX = cellSize.width * padding;
    final paddingY = cellSize.height * padding;
    
    return Rect.fromLTWH(
      x + paddingX,
      y + paddingY,
      cellSize.width * scale,
      cellSize.height * scale,
    );
  }

  /// Renders eyes on the snake head.
  ///
  /// [canvas] The canvas to draw on
  /// [headRect] The rectangle of the head
  static void _renderEyes(Canvas canvas, Rect headRect) {
    const eyeColor = Colors.black;
    const eyeSize = 2.0;
    
    final eyePaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;
    
    // Calculate eye positions
    final eyeY = headRect.top + headRect.height * 0.3;
    final leftEyeX = headRect.left + headRect.width * 0.25;
    final rightEyeX = headRect.left + headRect.width * 0.75;
    
    // Draw eyes
    canvas.drawCircle(
      Offset(leftEyeX, eyeY),
      eyeSize,
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(rightEyeX, eyeY),
      eyeSize,
      eyePaint,
    );
  }

  /// Gets the color scheme for the snake based on game state.
  static Map<String, Color> getSnakeColors(GameState gameState) {
    final isDead = gameState == GameState.gameOver;
    
    return {
      'head': isDead ? _deadColor : _headColor,
      'body': isDead ? _deadColor : _bodyColor,
    };
  }

  /// Validates if a position can be rendered within the canvas bounds.
  static bool canRenderPosition(
    Position position,
    Size canvasSize,
    Size cellSize,
  ) {
    final x = position.x * cellSize.width;
    final y = position.y * cellSize.height;
    
    return x >= 0 &&
           y >= 0 &&
           x + cellSize.width <= canvasSize.width &&
           y + cellSize.height <= canvasSize.height;
  }
}
