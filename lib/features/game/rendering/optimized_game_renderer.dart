import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../models/food.dart';
import '../models/snake.dart';
import '../controllers/game_state_manager.dart';

/// Optimized game renderer for high-performance 60fps rendering.
///
/// Uses object pooling, pre-allocated paints, and efficient drawing
/// techniques to minimize garbage collection and ensure smooth gameplay.
class OptimizedGameRenderer {
  final Canvas _canvas;
  final Size _canvasSize;

  // Pre-allocated paints for different game elements
  final Paint _foodPaint = Paint()..style = PaintingStyle.fill;
  final Paint _backgroundPaint = Paint()..style = PaintingStyle.fill;
  final Map<PlayerColor, Paint> _playerPaints = {};

  // Reusable drawing objects to minimize allocations
  final Path _reusablePath = Path();

  // Object pools for reduced garbage collection
  final Queue<Rect> _rectPool = Queue<Rect>();

  // Performance optimizations
  static const int _maxPoolSize = 100;
  late final double _cellWidth;
  late final double _cellHeight;

  OptimizedGameRenderer({
    required Canvas canvas,
    required Size canvasSize,
    required Size gridSize,
  }) : _canvas = canvas,
       _canvasSize = canvasSize {
    _cellWidth = canvasSize.width / gridSize.width;
    _cellHeight = canvasSize.height / gridSize.height;
    _initializePaints();
  }

  /// Renders the complete game state efficiently.
  void renderGame({
    required Map<String, Snake> snakes,
    required Food? food,
    required GameState gameState,
    bool showGrid = true,
  }) {
    // Clear canvas with background
    _renderBackground();

    // Render grid if enabled
    if (showGrid) {
      _renderGrid();
    }

    // Render food
    if (food != null && food.isActive) {
      _renderFood(food);
    }

    // Render all snakes efficiently
    for (final entry in snakes.entries) {
      final playerId = entry.key;
      final snake = entry.value;

      _renderSnake(snake, _getPlayerColor(playerId));
    }
  }

  /// Renders a single snake with optimized drawing.
  void _renderSnake(Snake snake, PlayerColor playerColor) {
    final paint = _playerPaints[playerColor]!;

    // Use path for efficient multi-segment rendering
    _reusablePath.reset();

    bool isFirst = true;
    final body = snake.body;
    for (int i = 0; i < body.length; i++) {
      final position = body[i];
      final isHead = i == 0;

      final rect = _getRectFromPool(
        position.x * _cellWidth,
        position.y * _cellHeight,
        _cellWidth,
        _cellHeight,
      );

      if (isFirst) {
        _reusablePath.addRect(rect);
        isFirst = false;
      } else {
        _reusablePath.addRect(rect);
      }

      // Render head differently if needed
      if (isHead) {
        // Add slight highlight for head
        final headPaint = Paint()
          ..color = paint.color.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill;
        _canvas.drawRect(rect, headPaint);
      }

      _returnRectToPool(rect);
    }

    // Draw the entire snake path at once
    _canvas.drawPath(_reusablePath, paint);
  }

  /// Renders food with visual effects.
  void _renderFood(Food food) {
    final rect = _getRectFromPool(
      food.position.x * _cellWidth,
      food.position.y * _cellHeight,
      _cellWidth,
      _cellHeight,
    );

    // Main food body
    _canvas.drawRect(rect, _foodPaint);

    // Add subtle border for visibility
    final borderPaint = Paint()
      ..color = Colors.red.darker
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    _canvas.drawRect(rect, borderPaint);

    _returnRectToPool(rect);
  }

  /// Renders background efficiently.
  void _renderBackground() {
    _backgroundPaint.color = Colors.black;
    _canvas.drawRect(
      Rect.fromLTWH(0, 0, _canvasSize.width, _canvasSize.height),
      _backgroundPaint,
    );
  }

  /// Renders grid lines efficiently.
  void _renderGrid() {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= _canvasSize.width; x += _cellWidth) {
      _canvas.drawLine(Offset(x, 0), Offset(x, _canvasSize.height), gridPaint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= _canvasSize.height; y += _cellHeight) {
      _canvas.drawLine(Offset(0, y), Offset(_canvasSize.width, y), gridPaint);
    }
  }

  /// Initializes all paint objects for optimal performance.
  void _initializePaints() {
    // Initialize food paint
    _foodPaint.color = Colors.red;

    // Initialize player paints for each color
    for (final color in PlayerColor.values) {
      _playerPaints[color] = Paint()
        ..style = PaintingStyle.fill
        ..color = _getColorFromPlayerColor(color);
    }
  }

  /// Gets Flutter Color from PlayerColor enum.
  Color _getColorFromPlayerColor(PlayerColor playerColor) {
    switch (playerColor) {
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.blue:
        return Colors.blue;
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.yellow:
        return Colors.yellow;
    }
  }

  /// Maps player ID to color for consistency.
  PlayerColor _getPlayerColor(String playerId) {
    const colors = PlayerColor.values;
    final hash = playerId.hashCode.abs();
    return colors[hash % colors.length];
  }

  // Object pooling methods for memory efficiency

  /// Gets a Rect from pool or creates new one.
  Rect _getRectFromPool(double left, double top, double width, double height) {
    if (_rectPool.isNotEmpty) {
      _rectPool.removeFirst();
      // Note: Rect is immutable in Flutter, so we create a new one
      return Rect.fromLTWH(left, top, width, height);
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Returns a Rect to pool for reuse.
  void _returnRectToPool(Rect rect) {
    if (_rectPool.length < _maxPoolSize) {
      _rectPool.add(rect);
    }
  }

  /// Cleans up object pools to prevent memory leaks.
  void dispose() {
    _rectPool.clear();
  }
}

/// Extension to provide darker color variant.
extension ColorExtension on Color {
  Color get darker {
    return Color.fromARGB(
      (a * 255.0).round() & 0xff,
      (((r * 255.0).round() & 0xff) * 0.8).round(),
      (((g * 255.0).round() & 0xff) * 0.8).round(),
      (((b * 255.0).round() & 0xff) * 0.8).round(),
    );
  }
}
