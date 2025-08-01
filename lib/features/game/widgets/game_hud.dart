import 'package:flutter/material.dart';

import '../controllers/game_state_manager.dart';
import '../models/score_manager.dart';
import 'game_controls_widget.dart';
import 'game_status_widget.dart';
import 'score_display_widget.dart';

/// Main HUD widget that overlays game information on the game canvas.
///
/// Provides a non-intrusive interface showing score, game status,
/// and basic game controls positioned strategically to avoid 
/// interfering with gameplay.
class GameHUD extends StatelessWidget {
  final ScoreManager scoreManager;
  final GameStateManager stateManager;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  
  const GameHUD({
    super.key,
    required this.scoreManager,
    required this.stateManager,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top HUD - Score and basic info
        _buildTopHUD(context),
        
        // Center HUD - Game status messages
        _buildCenterHUD(context),
        
        // Bottom HUD - Game controls
        _buildBottomHUD(context),
      ],
    );
  }
  
  /// Builds the top HUD containing score and game info.
  Widget _buildTopHUD(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Score display
            Expanded(
              flex: 2,
              child: ScoreDisplayWidget(
                scoreStream: scoreManager.scoreStream,
                currentScore: scoreManager.currentScore,
                highScore: scoreManager.highScore,
              ),
            ),
            
            // Game info (snake length, food count, etc.)
            Expanded(
              flex: 1,
              child: _buildGameInfo(context),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the center HUD for game status messages.
  Widget _buildCenterHUD(BuildContext context) {
    return Positioned.fill(
      child: Center(
        child: GameStatusWidget(
          gameState: stateManager.currentState,
        ),
      ),
    );
  }
  
  /// Builds the bottom HUD for game controls.
  Widget _buildBottomHUD(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: bottomPadding + 16,
      left: 16,
      right: 16,
      child: GameControlsWidget(
        gameState: stateManager.currentState,
        onPause: onPause,
        onResume: onResume,
        onRestart: onRestart,
      ),
    );
  }
  
  /// Builds additional game information display.
  Widget _buildGameInfo(BuildContext context) {
    return StreamBuilder<int>(
      stream: scoreManager.scoreStream,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Food: ${scoreManager.foodEaten}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Session: ${scoreManager.gameSessionCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}
