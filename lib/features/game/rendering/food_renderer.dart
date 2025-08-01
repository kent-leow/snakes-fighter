import 'package:flutter/material.dart';

import '../../../core/models/position.dart';
import '../models/food.dart';

/// Handles rendering of food items on the game canvas.
///
/// This renderer provides methods to draw food with appealing
/// visuals and animations.
class FoodRenderer {
  // Food colors
  static const Color _foodColor = Color(0xFFFF5722); // Deep orange
  static const Color _foodBorderColor = Color(0xFFD84315); // Darker orange
  static const Color _inactiveColor = Color(0xFF9E9E9E); // Gray

  // Visual properties
  static const double _borderRadius = 4.0;
  static const double _foodScale = 0.7;
  static const double _borderWidth = 1.0;
  static const double _glowRadius = 3.0;

  /// Renders a food item on the canvas.
  ///
  /// [canvas] The canvas to draw on
  /// [food] The food item to render
  /// [cellSize] The size of each grid cell
  static void renderFood(Canvas canvas, Food food, Size cellSize) {
    if (!food.isActive) {
      // Don't render inactive food
      return;
    }

    final rect = _getFoodRect(food.position, cellSize);

    // Draw glow effect
    _renderGlow(canvas, rect);

    // Draw main food body
    _renderFoodBody(canvas, rect);

    // Draw border
    _renderFoodBorder(canvas, rect);

    // Draw shine effect
    _renderShine(canvas, rect);
  }

  /// Renders multiple food items.
  ///
  /// [canvas] The canvas to draw on
  /// [foods] List of food items to render
  /// [cellSize] The size of each grid cell
  static void renderFoods(Canvas canvas, List<Food> foods, Size cellSize) {
    for (final food in foods) {
      if (food.isActive) {
        renderFood(canvas, food, cellSize);
      }
    }
  }

  /// Renders food at a specific position with custom properties.
  ///
  /// [canvas] The canvas to draw on
  /// [position] Position to render the food
  /// [cellSize] The size of each grid cell
  /// [color] Custom color for the food
  /// [scale] Custom scale factor
  static void renderFoodAt(
    Canvas canvas,
    Position position,
    Size cellSize, {
    Color color = _foodColor,
    double scale = _foodScale,
  }) {
    final rect = _getScaledRect(position, cellSize, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  /// Gets the rectangle for rendering food.
  static Rect _getFoodRect(Position position, Size cellSize) {
    return _getScaledRect(position, cellSize, _foodScale);
  }

  /// Gets a scaled rectangle for rendering.
  static Rect _getScaledRect(Position position, Size cellSize, double scale) {
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

  /// Renders the main food body.
  static void _renderFoodBody(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = _foodColor
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  /// Renders the food border.
  static void _renderFoodBorder(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = _foodBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth;

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_borderRadius),
    );

    canvas.drawRRect(rrect, paint);
  }

  /// Renders a glow effect around the food.
  static void _renderGlow(Canvas canvas, Rect rect) {
    final glowPaint = Paint()
      ..color = _foodColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowRadius);

    final glowRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width + _glowRadius * 2,
      height: rect.height + _glowRadius * 2,
    );

    final rrect = RRect.fromRectAndRadius(
      glowRect,
      const Radius.circular(_borderRadius + _glowRadius),
    );

    canvas.drawRRect(rrect, glowPaint);
  }

  /// Renders a shine effect on the food.
  static void _renderShine(Canvas canvas, Rect rect) {
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Create a small shine spot in the top-left corner
    final shineSize = rect.width * 0.3;
    final shineRect = Rect.fromLTWH(
      rect.left + rect.width * 0.2,
      rect.top + rect.height * 0.2,
      shineSize,
      shineSize,
    );

    canvas.drawOval(shineRect, shinePaint);
  }

  /// Gets the color scheme for food based on its state.
  static Map<String, Color> getFoodColors(bool isActive) {
    return {
      'primary': isActive ? _foodColor : _inactiveColor,
      'border': isActive ? _foodBorderColor : _inactiveColor,
    };
  }

  /// Validates if a food position can be rendered within canvas bounds.
  static bool canRenderFood(Position position, Size canvasSize, Size cellSize) {
    final x = position.x * cellSize.width;
    final y = position.y * cellSize.height;

    return x >= 0 &&
        y >= 0 &&
        x + cellSize.width <= canvasSize.width &&
        y + cellSize.height <= canvasSize.height;
  }

  /// Gets the visual bounds of a food item for hit testing.
  static Rect getFoodBounds(Position position, Size cellSize) {
    return _getFoodRect(position, cellSize);
  }
}
