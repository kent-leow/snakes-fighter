import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/menu/screens/game_over_screen.dart';
import '../../features/menu/screens/main_menu_screen.dart';
import '../../features/menu/screens/pause_menu_screen.dart';
import '../../features/menu/screens/settings_screen.dart';
import '../services/settings_service.dart';

/// Centralized routing configuration for the app.
///
/// Defines all route names and generates routes for navigation.
class AppRouter {
  // Route names
  static const String auth = '/auth';
  static const String mainMenu = '/';
  static const String game = '/game';
  static const String settingsRoute = '/settings';
  static const String pauseMenuRoute = '/pause-menu';
  static const String gameOverRoute = '/game-over';
  
  /// Generate routes based on route settings.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auth:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthScreen(),
          settings: settings,
        );
      
      case mainMenu:
        return MaterialPageRoute<void>(
          builder: (_) => const MainMenuScreen(),
          settings: settings,
        );
      
      case settingsRoute:
        final settingsService = settings.arguments as SettingsService?;
        return MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(settingsService: settingsService),
          settings: settings,
        );
      
      case pauseMenuRoute:
        final args = settings.arguments as PauseMenuArguments?;
        return PageRouteBuilder<void>(
          pageBuilder: (context, animation, _) => PauseMenuScreen(
            onResume: args?.onResume ?? () {},
            onRestart: args?.onRestart ?? () {},
            onMainMenu: args?.onMainMenu ?? () {},
          ),
          opaque: false,
          barrierColor: Colors.black54,
          settings: settings,
        );
      
      case gameOverRoute:
        final args = settings.arguments as GameOverArguments?;
        return MaterialPageRoute<void>(
          builder: (_) => GameOverScreen(
            finalScore: args?.finalScore ?? 0,
            highScore: args?.highScore ?? 0,
            onRestart: args?.onRestart ?? () {},
            onMainMenu: args?.onMainMenu ?? () {},
          ),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute<void>(
          builder: (_) => _ErrorScreen(routeName: settings.name ?? 'unknown'),
          settings: settings,
        );
    }
  }
}

/// Arguments for pause menu screen.
class PauseMenuArguments {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const PauseMenuArguments({
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });
}

/// Arguments for game over screen.
class GameOverArguments {
  final int finalScore;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const GameOverArguments({
    required this.finalScore,
    required this.highScore,
    required this.onRestart,
    required this.onMainMenu,
  });
}

/// Error screen for undefined routes.
class _ErrorScreen extends StatelessWidget {
  final String routeName;
  
  const _ErrorScreen({required this.routeName});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Route not found: $routeName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Go to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
