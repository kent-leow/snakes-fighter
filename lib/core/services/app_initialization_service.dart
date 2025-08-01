import 'dart:async';

import 'package:flutter/foundation.dart';

import 'audio_service.dart';
import 'settings_service.dart';

/// Service for initializing and managing app-wide services.
///
/// Handles the startup sequence and dependency injection for
/// core services like audio and settings.
class AppInitializationService {
  static final AppInitializationService _instance =
      AppInitializationService._();
  static AppInitializationService get instance => _instance;
  AppInitializationService._();

  bool _initialized = false;
  SettingsService? _settingsService;
  AudioService? _audioService;

  /// Initialize all app services in the correct order.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      debugPrint('Initializing app services...');

      // Initialize settings service first
      _settingsService = await SettingsService.create();
      debugPrint('Settings service initialized');

      // Initialize audio service with settings
      _audioService = AudioService.instance;
      await _audioService!.initialize(settingsService: _settingsService);
      debugPrint('Audio service initialized');

      _initialized = true;
      debugPrint('App initialization completed successfully');
    } catch (error) {
      debugPrint('App initialization failed: $error');
      rethrow;
    }
  }

  /// Get the settings service instance.
  SettingsService? get settingsService => _settingsService;

  /// Get the audio service instance.
  AudioService? get audioService => _audioService;

  /// Check if services are initialized.
  bool get isInitialized => _initialized;

  /// Update audio service when settings change.
  Future<void> updateAudioSettings() async {
    if (_settingsService != null && _audioService != null) {
      _audioService!.setSoundEnabled(_settingsService!.soundEnabled);
      _audioService!.setVolume(_settingsService!.audioVolume);
    }
  }

  /// Dispose of all services.
  void dispose() {
    _audioService?.dispose();
    _initialized = false;
  }
}
