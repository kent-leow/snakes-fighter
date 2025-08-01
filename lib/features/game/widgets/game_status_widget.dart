import 'package:flutter/material.dart';

import '../controllers/game_state_manager.dart';

/// Widget that displays current game state with visual indicators.
///
/// Shows appropriate messages and animations for different game states
/// such as paused, game over, starting, etc.
class GameStatusWidget extends StatelessWidget {
  final GameState gameState;
  final TextStyle? textStyle;
  final Duration animationDuration;
  
  const GameStatusWidget({
    super.key,
    required this.gameState,
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: _buildStatusContent(context),
    );
  }
  
  /// Builds the content based on current game state.
  Widget _buildStatusContent(BuildContext context) {
    switch (gameState) {
      case GameState.menu:
        return _buildStatusMessage(
          context,
          'TAP TO START',
          icon: Icons.play_arrow,
          color: Theme.of(context).colorScheme.primary,
        );
        
      case GameState.playing:
        return const SizedBox.shrink(); // No message during gameplay
        
      case GameState.paused:
        return _buildStatusMessage(
          context,
          'PAUSED',
          subtitle: 'Tap to resume',
          icon: Icons.pause,
          color: Theme.of(context).colorScheme.secondary,
        );
        
      case GameState.gameOver:
        return _buildGameOverMessage(context);
        
      case GameState.restarting:
        return _buildStatusMessage(
          context,
          'RESTARTING...',
          icon: Icons.refresh,
          color: Theme.of(context).colorScheme.tertiary,
          showLoading: true,
        );
    }
  }
  
  /// Builds a standard status message with optional icon and subtitle.
  Widget _buildStatusMessage(
    BuildContext context,
    String message, {
    String? subtitle,
    IconData? icon,
    Color? color,
    bool showLoading = false,
  }) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.onSurface;
    
    return Container(
      key: ValueKey(message), // For AnimatedSwitcher
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          if (icon != null) ...[
            showLoading
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  )
                : Icon(
                    icon,
                    size: 48,
                    color: primaryColor,
                  ),
            const SizedBox(height: 16),
          ],
          
          // Main message
          Text(
            message,
            style: textStyle ?? theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1.2,
            ),
          ),
          
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
  
  /// Builds the game over message with additional information.
  Widget _buildGameOverMessage(BuildContext context) {
    return _buildStatusMessage(
      context,
      'GAME OVER',
      subtitle: 'Tap restart to play again',
      icon: Icons.sports_esports,
      color: Theme.of(context).colorScheme.error,
    );
  }
}

/// Compact status indicator for smaller spaces.
class CompactGameStatusWidget extends StatelessWidget {
  final GameState gameState;
  final double size;
  
  const CompactGameStatusWidget({
    super.key,
    required this.gameState,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildStatusIcon(context),
    );
  }
  
  Widget _buildStatusIcon(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (gameState) {
      case GameState.menu:
        icon = Icons.play_arrow;
        color = Theme.of(context).colorScheme.primary;
        break;
      case GameState.playing:
        return SizedBox.shrink(key: ValueKey(gameState));
      case GameState.paused:
        icon = Icons.pause;
        color = Theme.of(context).colorScheme.secondary;
        break;
      case GameState.gameOver:
        icon = Icons.stop;
        color = Theme.of(context).colorScheme.error;
        break;
      case GameState.restarting:
        return SizedBox(
          key: ValueKey(gameState),
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        );
    }
    
    return Icon(
      icon,
      size: size,
      color: color,
      key: ValueKey(gameState),
    );
  }
}

/// Status bar that shows game state with text indicators.
class GameStatusBar extends StatelessWidget {
  final GameState gameState;
  final EdgeInsets padding;
  
  const GameStatusBar({
    super.key,
    required this.gameState,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor(context);
    
    if (statusText.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompactGameStatusWidget(gameState: gameState, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText() {
    switch (gameState) {
      case GameState.menu:
        return 'Ready to start';
      case GameState.playing:
        return ''; // No text during gameplay
      case GameState.paused:
        return 'Paused';
      case GameState.gameOver:
        return 'Game Over';
      case GameState.restarting:
        return 'Restarting';
    }
  }
  
  Color _getStatusColor(BuildContext context) {
    switch (gameState) {
      case GameState.menu:
        return Theme.of(context).colorScheme.primary;
      case GameState.playing:
        return Theme.of(context).colorScheme.onSurface;
      case GameState.paused:
        return Theme.of(context).colorScheme.secondary;
      case GameState.gameOver:
        return Theme.of(context).colorScheme.error;
      case GameState.restarting:
        return Theme.of(context).colorScheme.tertiary;
    }
  }
}
