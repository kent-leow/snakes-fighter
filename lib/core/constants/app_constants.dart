/// App-wide constants for Snakes Fight game
class AppConstants {
  // App info
  static const String appName = 'Snakes Fight';
  static const String appVersion = '1.0.0';
  
  // Game constants
  static const int defaultGridSize = 20;
  static const int maxPlayers = 4;
  static const int minPlayers = 2;
  
  // Timing constants
  static const Duration gameTickDuration = Duration(milliseconds: 150);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}
