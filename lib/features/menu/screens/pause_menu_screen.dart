import 'package:flutter/material.dart';

import '../../../core/navigation/navigation_service.dart';

/// Pause menu screen that overlays the game when paused.
///
/// Provides options to resume, restart, or return to main menu
/// while preserving the game state underneath.
class PauseMenuScreen extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const PauseMenuScreen({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPauseTitle(context),
                  const SizedBox(height: 32),
                  _buildPauseMenuButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPauseTitle(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.pause_circle_outline,
          size: 64,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        Text(
          'PAUSED',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPauseMenuButtons() {
    return Column(
      children: [
        _buildPauseMenuButton(
          'Resume',
          icon: Icons.play_arrow,
          onPressed: onResume,
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        _buildPauseMenuButton(
          'Restart',
          icon: Icons.refresh,
          onPressed: () => _showRestartConfirmation(),
        ),
        const SizedBox(height: 12),
        _buildPauseMenuButton(
          'Main Menu',
          icon: Icons.home,
          onPressed: () => _showMainMenuConfirmation(),
        ),
      ],
    );
  }
  
  Widget _buildPauseMenuButton(
    String text, {
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade600,
                side: BorderSide(color: Colors.green.shade600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }
  
  void _showRestartConfirmation() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;
    
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restart Game'),
        content: const Text(
          'Are you sure you want to restart? Your current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onRestart();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
  
  void _showMainMenuConfirmation() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;
    
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Return to Main Menu'),
        content: const Text(
          'Are you sure you want to return to the main menu? Your current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onMainMenu();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
            child: const Text('Main Menu'),
          ),
        ],
      ),
    );
  }
}
