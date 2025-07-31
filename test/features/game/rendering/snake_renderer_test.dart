import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snakes_fight/core/models/position.dart';
import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/models/direction.dart';
import 'package:snakes_fight/features/game/models/snake.dart';
import 'package:snakes_fight/features/game/rendering/snake_renderer.dart';

void main() {
  group('SnakeRenderer', () {
    late Snake snake;
    late Canvas canvas;
    late PictureRecorder recorder;
    const cellSize = Size(20.0, 20.0);

    setUp(() {
      snake = Snake(
        initialPosition: const Position(5, 5),
        initialDirection: Direction.right,
        initialLength: 3,
      );
      recorder = PictureRecorder();
      canvas = Canvas(recorder);
    });

    group('renderSnake', () {
      test('should handle empty snake body', () {
        // Create a snake and reset it to a minimal state
        final emptySnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 1,
        );
        
        // Reset to minimal state to simulate an edge case
        emptySnake.reset(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
          initialLength: 1,
        );
        
        // Should not throw when rendering minimal snake
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            emptySnake,
            cellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });

      test('should render snake with head and body', () {
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            snake,
            cellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });

      test('should render dead snake with different colors', () {
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            snake,
            cellSize,
            GameState.gameOver,
          ),
          returnsNormally,
        );
      });
    });

    group('renderSnakeHead', () {
      test('should render head at correct position', () {
        const headPosition = Position(3, 4);
        
        expect(
          () => SnakeRenderer.renderSnakeHead(
            canvas,
            headPosition,
            cellSize,
            false,
          ),
          returnsNormally,
        );
      });

      test('should render dead head without eyes', () {
        const headPosition = Position(3, 4);
        
        expect(
          () => SnakeRenderer.renderSnakeHead(
            canvas,
            headPosition,
            cellSize,
            true,
          ),
          returnsNormally,
        );
      });
    });

    group('renderSnakeBody', () {
      test('should render body segment', () {
        const bodyPosition = Position(2, 3);
        
        expect(
          () => SnakeRenderer.renderSnakeBody(
            canvas,
            bodyPosition,
            cellSize,
            false,
          ),
          returnsNormally,
        );
      });

      test('should render dead body segment', () {
        const bodyPosition = Position(2, 3);
        
        expect(
          () => SnakeRenderer.renderSnakeBody(
            canvas,
            bodyPosition,
            cellSize,
            true,
          ),
          returnsNormally,
        );
      });
    });

    group('renderSnakeBodyOnly', () {
      test('should render all body segments except head', () {
        final bodyPositions = [
          const Position(5, 5), // Head - should be skipped
          const Position(4, 5), // Body segment 1
          const Position(3, 5), // Body segment 2
        ];
        
        expect(
          () => SnakeRenderer.renderSnakeBodyOnly(
            canvas,
            bodyPositions,
            cellSize,
            false,
          ),
          returnsNormally,
        );
      });

      test('should handle single position list', () {
        final singlePosition = [const Position(5, 5)];
        
        expect(
          () => SnakeRenderer.renderSnakeBodyOnly(
            canvas,
            singlePosition,
            cellSize,
            false,
          ),
          returnsNormally,
        );
      });
    });

    group('color schemes', () {
      test('should return correct colors for alive snake', () {
        final colors = SnakeRenderer.getSnakeColors(GameState.playing);
        
        expect(colors['head'], isNotNull);
        expect(colors['body'], isNotNull);
        expect(colors['head'], isNot(equals(Colors.grey)));
        expect(colors['body'], isNot(equals(Colors.grey)));
      });

      test('should return gray colors for dead snake', () {
        final colors = SnakeRenderer.getSnakeColors(GameState.gameOver);
        
        expect(colors['head'], isNotNull);
        expect(colors['body'], isNotNull);
        expect(colors['head'], equals(const Color(0xFF757575)));
        expect(colors['body'], equals(const Color(0xFF757575)));
      });
    });

    group('validation', () {
      test('should validate position within canvas bounds', () {
        const canvasSize = Size(400, 400);
        const validPosition = Position(5, 5);
        const invalidPosition = Position(25, 25);
        
        expect(
          SnakeRenderer.canRenderPosition(
            validPosition,
            canvasSize,
            cellSize,
          ),
          isTrue,
        );
        
        expect(
          SnakeRenderer.canRenderPosition(
            invalidPosition,
            canvasSize,
            cellSize,
          ),
          isFalse,
        );
      });

      test('should validate edge positions', () {
        const canvasSize = Size(400, 400);
        const edgePosition = Position(19, 19); // 19 * 20 = 380, within 400
        const outsidePosition = Position(20, 20); // 20 * 20 = 400, outside
        
        expect(
          SnakeRenderer.canRenderPosition(
            edgePosition,
            canvasSize,
            cellSize,
          ),
          isTrue,
        );
        
        expect(
          SnakeRenderer.canRenderPosition(
            outsidePosition,
            canvasSize,
            cellSize,
          ),
          isFalse,
        );
      });

      test('should validate negative positions', () {
        const canvasSize = Size(400, 400);
        const negativePosition = Position(-1, 5);
        
        expect(
          SnakeRenderer.canRenderPosition(
            negativePosition,
            canvasSize,
            cellSize,
          ),
          isFalse,
        );
      });
    });

    group('different cell sizes', () {
      test('should handle small cell sizes', () {
        const smallCellSize = Size(5.0, 5.0);
        
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            snake,
            smallCellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });

      test('should handle large cell sizes', () {
        const largeCellSize = Size(100.0, 100.0);
        
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            snake,
            largeCellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });

      test('should handle rectangular cell sizes', () {
        const rectCellSize = Size(30.0, 15.0);
        
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            snake,
            rectCellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });
    });

    group('edge cases', () {
      test('should handle snake at grid boundaries', () {
        final boundarySnake = Snake(
          initialPosition: const Position(0, 0),
          initialDirection: Direction.right,
        );
        
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            boundarySnake,
            cellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });

      test('should handle very long snake', () {
        final longSnake = Snake(
          initialPosition: const Position(10, 10),
          initialDirection: Direction.right,
          initialLength: 50,
        );
        
        expect(
          () => SnakeRenderer.renderSnake(
            canvas,
            longSnake,
            cellSize,
            GameState.playing,
          ),
          returnsNormally,
        );
      });
    });

    tearDown(() {
      recorder.endRecording();
    });
  });
}
