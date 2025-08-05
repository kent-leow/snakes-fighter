/// Application information and configuration
class AppInfo {
  /// Application version from pubspec.yaml
  static const String version = '1.0.0';
  
  /// Build number (incremented automatically in CI/CD)
  static const int buildNumber = 1;
  
  /// Current environment (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  /// Firebase project ID based on environment
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'snakes-fight-dev',
  );
  
  /// Application name
  static const String appName = 'Snakes Fight';
  
  /// Application description
  static const String appDescription = 'Multiplayer Snake Game';
  
  /// Package/Bundle identifier
  static const String packageName = 'com.snakesfight.game';
  
  // Environment helpers
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  
  /// Display version string
  static String get displayVersion => '$version ($buildNumber)';
  
  /// Full app identifier with environment
  static String get fullAppId => isProduction 
      ? packageName 
      : '$packageName.${environment}';
  
  /// API base URL based on environment
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://snakes-fight-prod.web.app';
      case 'staging':
        return 'https://snakes-fight-staging.web.app';
      default:
        return 'https://snakes-fight-dev.web.app';
    }
  }
  
  /// Firebase database URL based on environment
  static String get databaseUrl {
    switch (environment) {
      case 'production':
        return 'https://snakes-fight-prod-default-rtdb.firebaseio.com/';
      case 'staging':
        return 'https://snakes-fight-staging-default-rtdb.firebaseio.com/';
      default:
        return 'https://snakes-fight-dev-default-rtdb.firebaseio.com/';
    }
  }
  
  /// Debug information
  static Map<String, dynamic> get debugInfo => {
    'version': version,
    'buildNumber': buildNumber,
    'environment': environment,
    'firebaseProjectId': firebaseProjectId,
    'packageName': packageName,
    'apiBaseUrl': apiBaseUrl,
    'databaseUrl': databaseUrl,
  };
}
