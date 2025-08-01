import 'package:flutter/material.dart';

import '../../../core/models/game_difficulty.dart';
import '../../../core/services/app_initialization_service.dart';
import '../../../core/services/settings_service.dart';
import '../audio/menu_audio_manager.dart';

/// Settings screen for configuring game preferences.
///
/// Allows users to adjust sound, vibration, and difficulty settings
/// with persistent storage across app sessions.
class SettingsScreen extends StatefulWidget {
  final SettingsService? settingsService;

  const SettingsScreen({super.key, this.settingsService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsService? _settingsService;
  final MenuAudioManager _audioManager = MenuAudioManager();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  GameDifficulty _difficulty = GameDifficulty.normal;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    if (widget.settingsService != null) {
      _settingsService = widget.settingsService;
    } else {
      _settingsService = await SettingsService.create();
    }

    if (mounted && _settingsService != null) {
      setState(() {
        _soundEnabled = _settingsService!.soundEnabled;
        _vibrationEnabled = _settingsService!.vibrationEnabled;
        _difficulty = _settingsService!.difficulty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _settingsService == null
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Audio & Haptics'),
        _buildSoundSetting(),
        _buildVibrationSetting(),
        const SizedBox(height: 24),

        _buildSectionHeader('Gameplay'),
        _buildDifficultySetting(),
        const SizedBox(height: 32),

        _buildResetButton(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSoundSetting() {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Sound Effects',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Enable game sound effects'),
        value: _soundEnabled,
        onChanged: (value) async {
          _audioManager.onSettingChanged();
          setState(() {
            _soundEnabled = value;
          });
          await _settingsService!.setSoundEnabled(value);
          // Update audio service settings
          await AppInitializationService.instance.updateAudioSettings();
        },
        activeColor: Colors.green.shade600,
        secondary: Icon(
          _soundEnabled ? Icons.volume_up : Icons.volume_off,
          color: Colors.green.shade600,
        ),
      ),
    );
  }

  Widget _buildVibrationSetting() {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Vibration',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Enable haptic feedback'),
        value: _vibrationEnabled,
        onChanged: (value) async {
          _audioManager.onSettingChanged();
          setState(() {
            _vibrationEnabled = value;
          });
          await _settingsService!.setVibrationEnabled(value);
        },
        activeColor: Colors.green.shade600,
        secondary: Icon(
          _vibrationEnabled ? Icons.vibration : Icons.phone_android,
          color: Colors.green.shade600,
        ),
      ),
    );
  }

  Widget _buildDifficultySetting() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.green.shade600),
                const SizedBox(width: 16),
                const Text(
                  'Difficulty',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Adjust game speed and challenge level',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildDifficultySegmentedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySegmentedButton() {
    return SegmentedButton<GameDifficulty>(
      segments: GameDifficulty.values.map((difficulty) {
        return ButtonSegment<GameDifficulty>(
          value: difficulty,
          label: Text(difficulty.displayName),
          icon: _getDifficultyIcon(difficulty),
        );
      }).toList(),
      selected: {_difficulty},
      onSelectionChanged: (selected) async {
        _audioManager.onSettingChanged();
        final newDifficulty = selected.first;
        setState(() {
          _difficulty = newDifficulty;
        });
        await _settingsService!.setDifficulty(newDifficulty);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.green.shade600;
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.green.shade600;
        }),
      ),
    );
  }

  Icon _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const Icon(Icons.child_care, size: 16);
      case GameDifficulty.normal:
        return const Icon(Icons.person, size: 16);
      case GameDifficulty.hard:
        return const Icon(Icons.whatshot, size: 16);
    }
  }

  Widget _buildResetButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          _audioManager.onButtonPressed();
          _showResetDialog();
        },
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Defaults'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade600,
          side: BorderSide(color: Colors.red.shade600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioManager.onButtonPressed();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              _audioManager.onButtonPressed();
              Navigator.of(context).pop();
              await _resetSettings();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    await _settingsService!.resetToDefaults();
    // Update audio service settings
    await AppInitializationService.instance.updateAudioSettings();
    if (mounted) {
      setState(() {
        _soundEnabled = _settingsService!.soundEnabled;
        _vibrationEnabled = _settingsService!.vibrationEnabled;
        _difficulty = _settingsService!.difficulty;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings reset to defaults'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
