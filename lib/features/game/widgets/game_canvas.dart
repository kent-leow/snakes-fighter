import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../controllers/game_state_manager.dart';
import '../models/food.dart';
import '../models/snake.dart';
import '../rendering/food_renderer.dart';
import '../rendering/grid_renderer.dart';
import '../rendering/snake_renderer.dart';

/// A custom widget that renders the game using Flutter's CustomPainter.
///
/// This widget provides efficient rendering of the snake, food, and grid
/// while maintaining 60fps performance through optimized painting.
class GameCanvas extends StatefulWidget {
  /// The game controller that provides game state.
  final GameController gameController;

  /// The size of the game area.
  final Size gameSize;

  /// Whether to show the grid background.
  final bool showGrid;

  /// The background color of the canvas.
  final Color backgroundColor;

  const GameCanvas({
    super.key,
    required this.gameController,
    required this.gameSize,
    this.showGrid = true,
    this.backgroundColor = Colors.black,
  });

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for smooth 60fps rendering
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    );

    // Listen to game controller changes
    widget.gameController.addListener(_onGameStateChanged);

    // Start animation loop
    _animationController.repeat();
  }

  @override
  void dispose() {
    widget.gameController.removeListener(_onGameStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    // Trigger repaint when game state changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.gameSize.width,
      height: widget.gameSize.height,
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: GameCanvasPainter(
              snake: widget.gameController.snake,
              food: widget.gameController.currentFood,
              gameState: widget.gameController.currentState,
              showGrid: widget.showGrid,
              gridSize: Size(
                widget.gameController.gridSystem.gridWidth.toDouble(),
                widget.gameController.gridSystem.gridHeight.toDouble(),
              ),
              cellSize: widget.gameController.gridSystem.cellSize,
            ),
            size: widget.gameSize,
          );
        },
      ),
    );
  }
}

/// Custom painter that renders all game elements on the canvas.
///
/// This painter efficiently renders the snake, food, and optional grid
/// using Flutter's Canvas API for optimal performance.
class GameCanvasPainter extends CustomPainter {
  /// The snake to render.
  final Snake snake;

  /// The current food item to render (if any).
  final Food? food;

  /// The current game state.
  final GameState gameState;

  /// Whether to show the grid background.
  final bool showGrid;

  /// The size of the grid (width x height in cells).
  final Size gridSize;

  /// The size of each grid cell in pixels.
  final double cellSize;

  const GameCanvasPainter({
    required this.snake,
    required this.food,
    required this.gameState,
    required this.showGrid,
    required this.gridSize,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate cell size based on canvas size
    final actualCellSize = Size(
      size.width / gridSize.width,
      size.height / gridSize.height,
    );

    // Render grid background (if enabled)
    if (showGrid) {
      GridRenderer.renderGrid(canvas, size, gridSize, actualCellSize);
    }

    // Render food
    if (food != null && food!.isActive) {
      FoodRenderer.renderFood(canvas, food!, actualCellSize);
    }

    // Render snake
    SnakeRenderer.renderSnake(canvas, snake, actualCellSize, gameState);
  }

  @override
  bool shouldRepaint(GameCanvasPainter oldDelegate) {
    // Repaint if any game element has changed
    return oldDelegate.snake != snake ||
        oldDelegate.food != food ||
        oldDelegate.gameState != gameState ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.cellSize != cellSize;
  }

  @override
  bool hitTest(Offset position) {
    // Allow hit testing for touch input
    return true;
  }
}
