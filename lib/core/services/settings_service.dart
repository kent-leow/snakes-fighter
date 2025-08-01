import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_difficulty.dart';

/// Service for managing game settings and preferences.
///
/// Handles persistence of user preferences using SharedPreferences,
/// including sound, vibration, and difficulty settings.
class SettingsService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _difficultyKey = 'difficulty';
  
  final SharedPreferences _prefs;
  
  SettingsService(this._prefs);
  
  /// Creates a SettingsService instance with SharedPreferences.
  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }
  
  // Sound settings
  
  /// Whether sound effects are enabled.
  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;
  
  /// Set whether sound effects are enabled.
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }
  
  // Vibration settings
  
  /// Whether haptic feedback/vibration is enabled.
  bool get vibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? true;
  
  /// Set whether haptic feedback/vibration is enabled.
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }
  
  // Difficulty settings
  
  /// Current game difficulty level.
  GameDifficulty get difficulty {
    final difficultyIndex = _prefs.getInt(_difficultyKey) ?? 1; // Default to normal
    if (difficultyIndex >= 0 && difficultyIndex < GameDifficulty.values.length) {
      return GameDifficulty.values[difficultyIndex];
    }
    return GameDifficulty.normal;
  }
  
  /// Set the game difficulty level.
  Future<void> setDifficulty(GameDifficulty difficulty) async {
    await _prefs.setInt(_difficultyKey, difficulty.index);
  }
  
  /// Reset all settings to default values.
  Future<void> resetToDefaults() async {
    await Future.wait([
      setSoundEnabled(true),
      setVibrationEnabled(true),
      setDifficulty(GameDifficulty.normal),
    ]);
  }
}
