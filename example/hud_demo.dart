import 'package:flutter/material.dart';
import 'package:snakes_fight/core/utils/grid_system.dart';
import 'package:snakes_fight/features/game/controllers/game_controller.dart';
import 'package:snakes_fight/features/game/controllers/game_state_manager.dart';
import 'package:snakes_fight/features/game/widgets/game_canvas.dart';
import 'package:snakes_fight/features/game/widgets/game_hud.dart';

/// Example app demonstrating the HUD system integrated with the game.
///
/// This demonstrates all the implemented HUD features:
/// - Real-time score display
/// - Game status indicators
/// - Game controls (pause/resume/restart)
/// - Responsive design
void main() {
  runApp(const HUDDemoApp());
}

class HUDDemoApp extends StatelessWidget {
  const HUDDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game HUD Demo',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const GameScreenWithHUD(),
    );
  }
}

class GameScreenWithHUD extends StatefulWidget {
  const GameScreenWithHUD({super.key});

  @override
  State<GameScreenWithHUD> createState() => _GameScreenWithHUDState();
}

class _GameScreenWithHUDState extends State<GameScreenWithHUD> {
  late GameController gameController;
  late GridSystem gridSystem;

  @override
  void initState() {
    super.initState();

    // Initialize game system
    gridSystem = GridSystem(
      gridWidth: 20,
      gridHeight: 20,
      cellSize: 20.0,
      screenWidth: 400.0,
      screenHeight: 600.0,
    );

    gameController = GameController(gridSystem: gridSystem);

    // Set up initial high score for demonstration
    gameController.scoreManager.updateHighScore(150);
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: gameController,
          builder: (context, _) {
            return Stack(
              children: [
                // Game canvas in the center
                Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GameCanvas(
                      gameController: gameController,
                      gameSize: const Size(400, 400),
                    ),
                  ),
                ),

                // Game HUD overlay
                GameHUD(
                  scoreManager: gameController.scoreManager,
                  stateManager: gameController.stateManager,
                  onPause: () => gameController.pauseGame(),
                  onResume: () => gameController.resumeGame(),
                  onRestart: () => gameController.resetGame(),
                ),

                // Demo controls at the bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildDemoControls(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds demo controls for testing HUD features.
  Widget _buildDemoControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Demo Controls',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _startGame,
                child: const Text('Start Game'),
              ),
              ElevatedButton(
                onPressed: _addDemoScore,
                child: const Text('+10 Score'),
              ),
              ElevatedButton(
                onPressed: _simulateFoodEaten,
                child: const Text('Eat Food'),
              ),
              ElevatedButton(
                onPressed: _gameOver,
                child: const Text('Game Over'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startGame() {
    if (gameController.currentState == GameState.menu) {
      gameController.startGame();
    }
  }

  void _addDemoScore() {
    gameController.scoreManager.addPoints(10);
  }

  void _simulateFoodEaten() {
    gameController.scoreManager.addFoodPoints(
      snakeLength: gameController.snake.length,
    );
  }

  void _gameOver() {
    if (gameController.isPlaying || gameController.isPaused) {
      gameController.stopGame();
    }
  }
}
