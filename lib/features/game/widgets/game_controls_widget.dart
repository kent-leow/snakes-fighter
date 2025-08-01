import 'package:flutter/material.dart';

import '../controllers/game_state_manager.dart';

/// Widget that provides basic game control buttons.
///
/// Displays context-appropriate controls based on current game state
/// such as pause/resume, restart, and start game buttons.
class GameControlsWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback? onStart;
  final bool showAsRow;
  final double buttonSpacing;
  
  const GameControlsWidget({
    super.key,
    required this.gameState,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
    this.onStart,
    this.showAsRow = true,
    this.buttonSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final controls = _buildControlButtons(context);
    
    if (controls.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: showAsRow
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: _intersperse(controls, SizedBox(width: buttonSpacing)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: _intersperse(controls, SizedBox(height: buttonSpacing)),
            ),
    );
  }
  
  /// Builds control buttons based on current game state.
  List<Widget> _buildControlButtons(BuildContext context) {
    switch (gameState) {
      case GameState.menu:
        return [
          if (onStart != null)
            _buildControlButton(
              context,
              icon: Icons.play_arrow,
              label: 'Start',
              onPressed: onStart!,
              isPrimary: true,
            ),
        ];
        
      case GameState.playing:
        return [
          _buildControlButton(
            context,
            icon: Icons.pause,
            label: 'Pause',
            onPressed: onPause,
          ),
        ];
        
      case GameState.paused:
        return [
          _buildControlButton(
            context,
            icon: Icons.play_arrow,
            label: 'Resume',
            onPressed: onResume,
            isPrimary: true,
          ),
          _buildControlButton(
            context,
            icon: Icons.restart_alt,
            label: 'Restart',
            onPressed: onRestart,
          ),
        ];
        
      case GameState.gameOver:
        return [
          _buildControlButton(
            context,
            icon: Icons.replay,
            label: 'Play Again',
            onPressed: onRestart,
            isPrimary: true,
          ),
        ];
        
      case GameState.restarting:
        return []; // No controls during restart
    }
  }
  
  /// Builds a single control button with consistent styling.
  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        foregroundColor: isPrimary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /// Helper to intersperse widgets with spacers.
  List<Widget> _intersperse(List<Widget> widgets, Widget spacer) {
    if (widgets.isEmpty) return widgets;
    
    final result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
}

/// Compact control widget for minimal space usage.
class CompactGameControlsWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final double buttonSize;
  
  const CompactGameControlsWidget({
    super.key,
    required this.gameState,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
    this.buttonSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildPrimaryControlButton(context);
    
    if (button == null) {
      return const SizedBox.shrink();
    }
    
    return button;
  }
  
  Widget? _buildPrimaryControlButton(BuildContext context) {
    switch (gameState) {
      case GameState.playing:
        return _buildIconButton(
          context,
          icon: Icons.pause,
          onPressed: onPause,
          tooltip: 'Pause Game',
        );
        
      case GameState.paused:
        return _buildIconButton(
          context,
          icon: Icons.play_arrow,
          onPressed: onResume,
          tooltip: 'Resume Game',
          isPrimary: true,
        );
        
      case GameState.gameOver:
        return _buildIconButton(
          context,
          icon: Icons.replay,
          onPressed: onRestart,
          tooltip: 'Restart Game',
          isPrimary: true,
        );
        
      case GameState.menu:
      case GameState.restarting:
        return null;
    }
  }
  
  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(buttonSize / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: isPrimary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        tooltip: tooltip,
      ),
    );
  }
}

/// Floating action button style game controls.
class FloatingGameControlsWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  
  const FloatingGameControlsWidget({
    super.key,
    required this.gameState,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final fabData = _getFabData();
    
    if (fabData == null) {
      return const SizedBox.shrink();
    }
    
    return FloatingActionButton(
      onPressed: fabData.onPressed,
      tooltip: fabData.tooltip,
      backgroundColor: fabData.isPrimary
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      foregroundColor: fabData.isPrimary
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSecondary,
      child: Icon(fabData.icon),
    );
  }
  
  _FabData? _getFabData() {
    switch (gameState) {
      case GameState.playing:
        return _FabData(
          icon: Icons.pause,
          onPressed: onPause,
          tooltip: 'Pause Game',
        );
        
      case GameState.paused:
        return _FabData(
          icon: Icons.play_arrow,
          onPressed: onResume,
          tooltip: 'Resume Game',
          isPrimary: true,
        );
        
      case GameState.gameOver:
        return _FabData(
          icon: Icons.replay,
          onPressed: onRestart,
          tooltip: 'Restart Game',
          isPrimary: true,
        );
        
      case GameState.menu:
      case GameState.restarting:
        return null;
    }
  }
}

/// Data class for floating action button configuration.
class _FabData {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isPrimary;
  
  const _FabData({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isPrimary = false,
  });
}
