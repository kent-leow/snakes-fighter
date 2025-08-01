import 'package:flutter_test/flutter_test.dart';

import 'package:snakes_fight/features/menu/audio/menu_audio_manager.dart';

void main() {
  group('MenuAudioManager', () {
    late MenuAudioManager menuAudioManager;

    setUp(() {
      menuAudioManager = MenuAudioManager();
    });

    test('should not throw when calling audio methods', () {
      expect(() => menuAudioManager.onButtonPressed(), returnsNormally);
      expect(() => menuAudioManager.onMenuTransition(), returnsNormally);
      expect(() => menuAudioManager.onGameStart(), returnsNormally);
      expect(() => menuAudioManager.onBackToMenu(), returnsNormally);
      expect(() => menuAudioManager.onSettingChanged(), returnsNormally);
    });
  });
}
