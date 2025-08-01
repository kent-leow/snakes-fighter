import 'package:flutter/material.dart';

/// Widget that displays the current score and high score with real-time updates.
///
/// Connects to score streams for automatic updates and provides
/// visual feedback for score changes.
class ScoreDisplayWidget extends StatelessWidget {
  final Stream<int> scoreStream;
  final int currentScore;
  final int highScore;
  final bool showHighScore;
  final TextStyle? scoreTextStyle;
  final TextStyle? highScoreTextStyle;

  const ScoreDisplayWidget({
    super.key,
    required this.scoreStream,
    required this.currentScore,
    required this.highScore,
    this.showHighScore = true,
    this.scoreTextStyle,
    this.highScoreTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: scoreStream,
      initialData: currentScore,
      builder: (context, snapshot) {
        final score = snapshot.data ?? currentScore;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current score
            _buildScoreText(
              context,
              'Score: $score',
              scoreTextStyle ??
                  Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            // High score (if enabled and available)
            if (showHighScore && highScore > 0) ...[
              const SizedBox(height: 4),
              _buildScoreText(
                context,
                'Best: $highScore',
                highScoreTextStyle ??
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Builds score text with optional animation for score changes.
  Widget _buildScoreText(BuildContext context, String text, TextStyle? style) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: style ?? DefaultTextStyle.of(context).style,
      child: Text(text, style: style),
    );
  }
}

/// Compact version of score display for smaller spaces.
class CompactScoreDisplayWidget extends StatelessWidget {
  final Stream<int> scoreStream;
  final int currentScore;
  final TextStyle? textStyle;

  const CompactScoreDisplayWidget({
    super.key,
    required this.scoreStream,
    required this.currentScore,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: scoreStream,
      initialData: currentScore,
      builder: (context, snapshot) {
        final score = snapshot.data ?? currentScore;

        return Text(
          score.toString(),
          style:
              textStyle ??
              Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        );
      },
    );
  }
}

/// Animated score display that shows score changes with visual effects.
class AnimatedScoreDisplayWidget extends StatefulWidget {
  final Stream<int> scoreStream;
  final int currentScore;
  final int highScore;
  final Duration animationDuration;

  const AnimatedScoreDisplayWidget({
    super.key,
    required this.scoreStream,
    required this.currentScore,
    required this.highScore,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedScoreDisplayWidget> createState() =>
      _AnimatedScoreDisplayWidgetState();
}

class _AnimatedScoreDisplayWidgetState extends State<AnimatedScoreDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  int _previousScore = 0;
  bool _showScoreIncrease = false;

  @override
  void initState() {
    super.initState();
    _previousScore = widget.currentScore;

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.green.withValues(alpha: 0.0),
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onScoreChanged(int newScore) {
    if (newScore > _previousScore) {
      setState(() {
        _showScoreIncrease = true;
      });

      _animationController.forward().then((_) {
        _animationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showScoreIncrease = false;
            });
          }
        });
      });
    }
    _previousScore = newScore;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: widget.scoreStream,
      initialData: widget.currentScore,
      builder: (context, snapshot) {
        final score = snapshot.data ?? widget.currentScore;

        // Trigger animation on score change
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onScoreChanged(score);
        });

        return Stack(
          children: [
            // Main score display
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _showScoreIncrease ? _scaleAnimation.value : 1.0,
                  child: ScoreDisplayWidget(
                    scoreStream: widget.scoreStream,
                    currentScore: score,
                    highScore: widget.highScore,
                  ),
                );
              },
            ),

            // Score increase indicator
            if (_showScoreIncrease)
              Positioned(
                top: -20,
                right: 0,
                child: AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) {
                    return Text(
                      '+${score - _previousScore}',
                      style: TextStyle(
                        color: _colorAnimation.value,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
