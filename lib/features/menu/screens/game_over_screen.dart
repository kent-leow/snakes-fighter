import 'package:flutter/material.dart';

/// Game over screen displayed when the game ends.
///
/// Shows the final score, high score, and provides options
/// to restart the game or return to the main menu.
class GameOverScreen extends StatelessWidget {
  final int finalScore;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  
  const GameOverScreen({
    super.key,
    required this.finalScore,
    required this.highScore,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = finalScore > 0 && finalScore >= highScore;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade800,
              Colors.red.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                  MediaQuery.of(context).padding.top - 
                  MediaQuery.of(context).padding.bottom - 64,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGameOverTitle(context, isNewHighScore),
                  const SizedBox(height: 32),
                  _buildScoreDisplay(context, isNewHighScore),
                  const SizedBox(height: 48),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameOverTitle(BuildContext context, bool isNewHighScore) {
    return Column(
      children: [
        Icon(
          isNewHighScore ? Icons.emoji_events : Icons.sentiment_dissatisfied,
          size: 80,
          color: Colors.yellow.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          isNewHighScore ? 'NEW HIGH SCORE!' : 'GAME OVER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              const Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        if (isNewHighScore) ...[
          const SizedBox(height: 8),
          Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.yellow.shade100,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildScoreDisplay(BuildContext context, bool isNewHighScore) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          children: [
            _buildScoreItem(
              context,
              'Final Score',
              finalScore,
              isHighlighted: isNewHighScore,
            ),
            if (!isNewHighScore && highScore > 0) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildScoreItem(
                context,
                'High Score',
                highScore,
                isSecondary: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreItem(
    BuildContext context,
    String label,
    int score, {
    bool isHighlighted = false,
    bool isSecondary = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSecondary ? Colors.grey.shade600 : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? Colors.yellow.shade700
                : isSecondary
                    ? Colors.grey.shade600
                    : Colors.green.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'PLAY AGAIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: onMainMenu,
            icon: const Icon(Icons.home),
            label: const Text(
              'MAIN MENU',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
