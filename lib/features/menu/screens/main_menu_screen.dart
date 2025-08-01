import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/grid_system.dart';
import '../../../features/game/controllers/game_controller.dart';
import '../../../features/game/widgets/game_canvas.dart';
import '../../../features/game/widgets/game_hud.dart';
import '../../../features/game/widgets/responsive_game_container.dart';

/// Main menu screen for the game.
///
/// Displays the game title, main menu buttons, and provides
/// navigation to different parts of the app.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  SettingsService? _settingsService;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final settingsService = await SettingsService.create();
    if (mounted) {
      setState(() {
        _settingsService = settingsService;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade800, Colors.green.shade600],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameTitle(),
                const SizedBox(height: 60),
                _buildMenuButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Column(
      children: [
        Text(
          AppConstants.appName.toUpperCase(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'v${AppConstants.appVersion}',
          style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Column(
      children: [
        _buildMenuButton('PLAY', icon: Icons.play_arrow, onPressed: _startGame),
        const SizedBox(height: 16),
        _buildMenuButton(
          'SETTINGS',
          icon: Icons.settings,
          onPressed: _openSettings,
        ),
        const SizedBox(height: 16),
        _buildMenuButton('EXIT', icon: Icons.exit_to_app, onPressed: _exitGame),
      ],
    );
  }

  Widget _buildMenuButton(
    String text, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green.shade700,
          elevation: 8,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  void _startGame() {
    // Navigate to game screen
    // For now, we'll create a simple game screen overlay
    _showGameScreen();
  }

  void _openSettings() {
    if (_settingsService != null) {
      NavigationService.push(
        AppRouter.settingsRoute,
        arguments: _settingsService,
      );
    }
  }

  void _exitGame() {
    // Show confirmation dialog
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showGameScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => _GameScreen()));
  }
}

/// Simple game screen for demonstration.
class _GameScreen extends StatefulWidget {
  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  late GameController gameController;
  late GridSystem gridSystem;

  @override
  void initState() {
    super.initState();

    // Initialize grid system
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Game canvas
            Center(
              child: AdaptiveGameContainer(
                backgroundColor: Colors.black87,
                child: GameCanvas(
                  gameController: gameController,
                  gameSize: const Size(400, 400),
                ),
              ),
            ),

            // Game HUD
            ListenableBuilder(
              listenable: gameController,
              builder: (context, _) {
                return GameHUD(
                  scoreManager: gameController.scoreManager,
                  stateManager: gameController.stateManager,
                  onPause: () => _showPauseMenu(),
                  onResume: () => gameController.resumeGame(),
                  onRestart: () => gameController.resetGame(),
                );
              },
            ),

            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseMenu() {
    gameController.pauseGame();
    NavigationService.push(
      AppRouter.pauseMenuRoute,
      arguments: PauseMenuArguments(
        onResume: () {
          NavigationService.pop();
          gameController.resumeGame();
        },
        onRestart: () {
          NavigationService.pop();
          gameController.resetGame();
        },
        onMainMenu: () {
          NavigationService.pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
