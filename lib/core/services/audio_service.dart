import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'settings_service.dart';

/// Service for managing audio playback and sound effects.
///
/// Provides centralized audio management with volume control,
/// sound toggles, and resource management.
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  AudioService._();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, String> _soundPaths = {
    'food_eat': 'sounds/game/food_eat.wav',
    'game_over': 'sounds/game/game_over.wav',
    'collision': 'sounds/game/collision.wav',
    'button_click': 'sounds/menu/button_click.wav',
    'menu_transition': 'sounds/menu/menu_transition.wav',
    'game_start': 'sounds/menu/game_start.wav',
  };

  bool _soundEnabled = true;
  double _volume = 1.0;
  bool _initialized = false;
  SettingsService? _settingsService;

  /// Initialize the audio service with settings.
  Future<void> initialize({SettingsService? settingsService}) async {
    if (_initialized) return;

    _settingsService = settingsService;

    if (_settingsService != null) {
      _soundEnabled = _settingsService!.soundEnabled;
      _volume = _settingsService!.audioVolume;
    }

    // Pre-load all sound effects for better performance
    for (final entry in _soundPaths.entries) {
      try {
        final player = AudioPlayer();
        await player.setSource(AssetSource(entry.value));
        await player.setVolume(_volume);
        _players[entry.key] = player;
      } catch (e) {
        // Gracefully handle missing audio files during development
        // ignore: avoid_print
        print('Warning: Could not load audio file ${entry.value}: $e');
      }
    }

    _initialized = true;
  }

  /// Play a sound effect by ID.
  Future<void> playSound(String soundId) async {
    if (!_soundEnabled || !_initialized) return;

    final player = _players[soundId];
    if (player != null) {
      try {
        await player.setVolume(_volume);
        await player.seek(Duration.zero);
        await player.resume();
      } catch (e) {
        // ignore: avoid_print
        print('Warning: Could not play sound $soundId: $e');
      }
    }
  }

  /// Enable or disable sound effects.
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Set the master volume for all sound effects.
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);

    // Update volume for all loaded players
    for (final player in _players.values) {
      player.setVolume(_volume);
    }
  }

  /// Get the current sound enabled state.
  bool get soundEnabled => _soundEnabled;

  /// Get the current volume level.
  double get volume => _volume;

  /// Dispose of all audio resources.
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _initialized = false;
  }
}
