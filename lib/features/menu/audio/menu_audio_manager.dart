import '../../../core/services/audio_service.dart';

/// Manages menu-specific audio effects and UI feedback sounds.
///
/// Provides convenient methods for playing sounds during menu interactions
/// like button presses, navigation, and game transitions.
class MenuAudioManager {
  final AudioService _audioService = AudioService.instance;

  /// Play sound when any button is pressed.
  void onButtonPressed() {
    _audioService.playSound('button_click');
  }

  /// Play sound when transitioning between menu screens.
  void onMenuTransition() {
    _audioService.playSound('menu_transition');
  }

  /// Play sound when starting a new game.
  void onGameStart() {
    _audioService.playSound('game_start');
  }

  /// Play sound when returning to main menu.
  void onBackToMenu() {
    _audioService.playSound('menu_transition');
  }

  /// Play sound for settings changes.
  void onSettingChanged() {
    _audioService.playSound('button_click');
  }
}
