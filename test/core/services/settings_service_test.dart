import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snakes_fight/core/models/game_difficulty.dart';
import 'package:snakes_fight/core/services/settings_service.dart';

void main() {
  group('SettingsService', () {
    late SettingsService settingsService;
    
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });
    
    group('Sound Settings', () {
      test('should default to enabled', () {
        expect(settingsService.soundEnabled, true);
      });
      
      test('should save and load sound enabled state', () async {
        await settingsService.setSoundEnabled(false);
        expect(settingsService.soundEnabled, false);
        
        await settingsService.setSoundEnabled(true);
        expect(settingsService.soundEnabled, true);
      });
    });
    
    group('Vibration Settings', () {
      test('should default to enabled', () {
        expect(settingsService.vibrationEnabled, true);
      });
      
      test('should save and load vibration enabled state', () async {
        await settingsService.setVibrationEnabled(false);
        expect(settingsService.vibrationEnabled, false);
        
        await settingsService.setVibrationEnabled(true);
        expect(settingsService.vibrationEnabled, true);
      });
    });
    
    group('Difficulty Settings', () {
      test('should default to normal difficulty', () {
        expect(settingsService.difficulty, GameDifficulty.normal);
      });
      
      test('should save and load difficulty settings', () async {
        await settingsService.setDifficulty(GameDifficulty.easy);
        expect(settingsService.difficulty, GameDifficulty.easy);
        
        await settingsService.setDifficulty(GameDifficulty.hard);
        expect(settingsService.difficulty, GameDifficulty.hard);
        
        await settingsService.setDifficulty(GameDifficulty.normal);
        expect(settingsService.difficulty, GameDifficulty.normal);
      });
      
      test('should handle invalid difficulty index gracefully', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('difficulty', 99); // Invalid index
        
        final service = SettingsService(prefs);
        expect(service.difficulty, GameDifficulty.normal);
      });
    });
    
    group('Reset Settings', () {
      test('should reset all settings to defaults', () async {
        // Change all settings
        await settingsService.setSoundEnabled(false);
        await settingsService.setVibrationEnabled(false);
        await settingsService.setDifficulty(GameDifficulty.hard);
        
        // Verify changes
        expect(settingsService.soundEnabled, false);
        expect(settingsService.vibrationEnabled, false);
        expect(settingsService.difficulty, GameDifficulty.hard);
        
        // Reset to defaults
        await settingsService.resetToDefaults();
        
        // Verify reset
        expect(settingsService.soundEnabled, true);
        expect(settingsService.vibrationEnabled, true);
        expect(settingsService.difficulty, GameDifficulty.normal);
      });
    });
    
    group('Factory Constructor', () {
      test('should create SettingsService with SharedPreferences', () async {
        final service = await SettingsService.create();
        expect(service, isA<SettingsService>());
        expect(service.soundEnabled, true);
        expect(service.vibrationEnabled, true);
        expect(service.difficulty, GameDifficulty.normal);
      });
    });
    
    group('Persistence', () {
      test('should persist settings across service instances', () async {
        // Set values in first instance
        await settingsService.setSoundEnabled(false);
        await settingsService.setVibrationEnabled(false);
        await settingsService.setDifficulty(GameDifficulty.easy);
        
        // Create new instance with same SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final newService = SettingsService(prefs);
        
        // Values should be persisted
        expect(newService.soundEnabled, false);
        expect(newService.vibrationEnabled, false);
        expect(newService.difficulty, GameDifficulty.easy);
      });
    });
  });
}
