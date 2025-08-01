import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snakes_fight/core/services/audio_service.dart';
import 'package:snakes_fight/core/services/settings_service.dart';

void main() {
  group('AudioService', () {
    late AudioService audioService;
    late SettingsService settingsService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      settingsService = await SettingsService.create();
      audioService = AudioService.instance;
    });

    tearDown(() {
      audioService.dispose();
    });

    test('should initialize with default settings', () async {
      await audioService.initialize(settingsService: settingsService);

      expect(audioService.soundEnabled, isTrue);
      expect(audioService.volume, equals(1.0));
    });

    test('should respect settings service values', () async {
      await settingsService.setSoundEnabled(false);
      await settingsService.setAudioVolume(0.5);

      await audioService.initialize(settingsService: settingsService);

      expect(audioService.soundEnabled, isFalse);
      expect(audioService.volume, equals(0.5));
    });

    test('should update sound enabled state', () {
      audioService.setSoundEnabled(false);
      expect(audioService.soundEnabled, isFalse);

      audioService.setSoundEnabled(true);
      expect(audioService.soundEnabled, isTrue);
    });

    test('should clamp volume to valid range', () {
      audioService.setVolume(1.5);
      expect(audioService.volume, equals(1.0));

      audioService.setVolume(-0.5);
      expect(audioService.volume, equals(0.0));

      audioService.setVolume(0.7);
      expect(audioService.volume, equals(0.7));
    });

    test(
      'should not throw when playing sounds before initialization',
      () async {
        expect(() => audioService.playSound('food_eat'), returnsNormally);
      },
    );

    test('should not throw when playing unknown sound', () async {
      await audioService.initialize();
      expect(() => audioService.playSound('unknown_sound'), returnsNormally);
    });
  });
}
