import 'package:flutter/material.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/widgets/game_canvas.dart';
import 'package:snakes_fight/features/game/widgets/responsive_game_container.dart';

/// Demonstration app showing the game canvas rendering system in action.
/// 
/// This example shows:
/// - Game canvas with snake and food rendering
/// - Responsive design that adapts to screen size
/// - Integration with game controller
/// - 60fps performance with smooth animations
class GameCanvasDemo extends StatefulWidget {
  const GameCanvasDemo({super.key});

  @override
  State<GameCanvasDemo> createState() => _GameCanvasDemoState();
}

class _GameCanvasDemoState extends State<GameCanvasDemo> {
  late GameController gameController;
  late GridSystem gridSystem;

  @override
  void initState() {
    super.initState();
    
    // Initialize grid system for demo
    gridSystem = GridSystem(
      gridWidth: 20,
      gridHeight: 20,
      cellSize: 20.0,
      screenWidth: 400.0,
      screenHeight: 400.0,
    );
    
    // Initialize game controller
    gameController = GameController(gridSystem: gridSystem);
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game Canvas Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Game Canvas Rendering Demo'),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
            // Game controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: gameController.isPlaying 
                        ? null 
                        : () => gameController.startGame(),
                    child: const Text('Start Game'),
                  ),
                  ElevatedButton(
                    onPressed: gameController.isPlaying 
                        ? () => gameController.pauseGame()
                        : gameController.isPaused 
                            ? () => gameController.resumeGame()
                            : null,
                    child: Text(gameController.isPaused ? 'Resume' : 'Pause'),
                  ),
                  ElevatedButton(
                    onPressed: gameController.isGameOver 
                        ? () => gameController.resetGame()
                        : gameController.isPlaying || gameController.isPaused
                            ? () => gameController.stopGame()
                            : null,
                    child: Text(gameController.isGameOver ? 'Reset' : 'Stop'),
                  ),
                ],
              ),
            ),
            
            // Game status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('State: ${gameController.currentState.name}'),
                  Text('Score: ${gameController.score}'),
                  Text('Length: ${gameController.snake.length}'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Game canvas with responsive container
            Expanded(
              child: AdaptiveGameContainer(
                backgroundColor: Colors.black87,
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: const Size(400, 400),
                  showGrid: true,
                  backgroundColor: Colors.black,
                ),
              ),
            ),
            
            // Performance info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'FPS: ${gameController.currentFps.toStringAsFixed(1)} | '
                'Frame Time: ${gameController.averageFrameTime.toStringAsFixed(1)}ms',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const GameCanvasDemo());
}
