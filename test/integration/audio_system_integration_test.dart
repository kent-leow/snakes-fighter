import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snakes_fight/core/services/app_initialization_service.dart';
import 'package:snakes_fight/core/services/audio_service.dart';
import 'package:snakes_fight/core/services/settings_service.dart';
import 'package:snakes_fight/features/game/audio/game_audio_manager.dart';
import 'package:snakes_fight/features/menu/audio/menu_audio_manager.dart';

void main() {
  group('Audio System Integration', () {
    late AppInitializationService appService;
    late SettingsService settingsService;
    late AudioService audioService;
    late GameAudioManager gameAudioManager;
    late MenuAudioManager menuAudioManager;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      appService = AppInitializationService.instance;
      await appService.initialize();

      settingsService = appService.settingsService!;
      audioService = appService.audioService!;
      gameAudioManager = GameAudioManager();
      menuAudioManager = MenuAudioManager();
    });

    tearDown(() {
      appService.dispose();
    });

    group('Audio Service Integration', () {
      test('should initialize with settings service', () {
        expect(audioService.soundEnabled, isTrue);
        expect(audioService.volume, equals(1.0));
      });

      test('should update when settings change', () async {
        await settingsService.setSoundEnabled(false);
        await settingsService.setAudioVolume(0.5);

        await appService.updateAudioSettings();

        expect(audioService.soundEnabled, isFalse);
        expect(audioService.volume, equals(0.5));
      });

      test('should handle volume clamping', () async {
        await settingsService.setAudioVolume(1.5);
        await appService.updateAudioSettings();

        expect(audioService.volume, equals(1.0));
      });
    });

    group('Game Audio Manager Integration', () {
      test('should play game sounds', () {
        expect(() => gameAudioManager.onFoodConsumed(), returnsNormally);
        expect(() => gameAudioManager.onGameOver(), returnsNormally);
        expect(() => gameAudioManager.onCollision(), returnsNormally);
      });

      test('should handle score milestone sounds', () {
        expect(() => gameAudioManager.onScoreIncrease(100), returnsNormally);
        expect(() => gameAudioManager.onScoreIncrease(200), returnsNormally);
        expect(() => gameAudioManager.onScoreIncrease(150), returnsNormally);
      });
    });

    group('Menu Audio Manager Integration', () {
      test('should play menu sounds', () {
        expect(() => menuAudioManager.onButtonPressed(), returnsNormally);
        expect(() => menuAudioManager.onMenuTransition(), returnsNormally);
        expect(() => menuAudioManager.onGameStart(), returnsNormally);
        expect(() => menuAudioManager.onBackToMenu(), returnsNormally);
        expect(() => menuAudioManager.onSettingChanged(), returnsNormally);
      });
    });

    group('Settings Integration', () {
      test('should persist audio volume settings', () async {
        await settingsService.setAudioVolume(0.7);

        // Create new service instance
        final newService = await SettingsService.create();
        expect(newService.audioVolume, equals(0.7));
      });

      test('should reset audio settings to defaults', () async {
        await settingsService.setSoundEnabled(false);
        await settingsService.setAudioVolume(0.3);

        await settingsService.resetToDefaults();

        expect(settingsService.soundEnabled, isTrue);
        expect(settingsService.audioVolume, equals(1.0));
      });
    });

    group('End-to-End Audio Workflow', () {
      test('should handle complete game audio workflow', () async {
        // Menu sounds
        menuAudioManager.onButtonPressed(); // Main menu button
        menuAudioManager.onGameStart(); // Start game

        // Game sounds
        gameAudioManager.onFoodConsumed(); // Eat food
        gameAudioManager.onScoreIncrease(100); // Milestone
        gameAudioManager.onCollision(); // Hit wall
        gameAudioManager.onGameOver(); // Game ends

        // Back to menu
        menuAudioManager.onBackToMenu();

        // Settings
        menuAudioManager.onMenuTransition(); // Open settings
        menuAudioManager.onSettingChanged(); // Change setting

        // Should complete without errors
        expect(true, isTrue);
      });

      test('should respect sound settings throughout workflow', () async {
        // Disable sound
        await settingsService.setSoundEnabled(false);
        await appService.updateAudioSettings();

        expect(audioService.soundEnabled, isFalse);

        // All sound calls should still work (but silently)
        menuAudioManager.onButtonPressed();
        gameAudioManager.onFoodConsumed();
        menuAudioManager.onMenuTransition();

        // Re-enable sound
        await settingsService.setSoundEnabled(true);
        await appService.updateAudioSettings();

        expect(audioService.soundEnabled, isTrue);
      });
    });
  });
}
