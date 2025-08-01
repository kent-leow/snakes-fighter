import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/direction.dart';

/// Provides visual feedback for user input actions.
///
/// This widget displays visual indicators when the user provides input,
/// such as highlighting directional arrows, showing swipe trails, or
/// providing haptic/visual feedback for recognized gestures.
class InputFeedbackWidget extends StatefulWidget {
  /// The child widget to wrap with input feedback.
  final Widget child;

  /// Whether to show directional feedback arrows.
  final bool showDirectionalFeedback;

  /// Whether to show swipe trail feedback.
  final bool showSwipeTrails;

  /// Duration for feedback animations.
  final Duration feedbackDuration;

  /// Colors for different feedback types.
  final InputFeedbackColors colors;

  const InputFeedbackWidget({
    super.key,
    required this.child,
    this.showDirectionalFeedback = true,
    this.showSwipeTrails = false,
    this.feedbackDuration = const Duration(milliseconds: 300),
    this.colors = const InputFeedbackColors(),
  });

  @override
  State<InputFeedbackWidget> createState() => InputFeedbackWidgetState();
}

class InputFeedbackWidgetState extends State<InputFeedbackWidget>
    with TickerProviderStateMixin {
  // Animation controllers for different feedback types
  late AnimationController _directionFeedbackController;
  late AnimationController _swipeTrailController;

  // Animations
  late Animation<double> _directionFeedbackAnimation;
  late Animation<double> _swipeTrailAnimation;

  // Current feedback state
  Direction? _lastDirection;
  List<Offset> _swipeTrail = [];
  bool _showingFeedback = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _directionFeedbackController = AnimationController(
      duration: widget.feedbackDuration,
      vsync: this,
    );

    _swipeTrailController = AnimationController(
      duration: widget.feedbackDuration,
      vsync: this,
    );

    // Initialize animations
    _directionFeedbackAnimation = CurvedAnimation(
      parent: _directionFeedbackController,
      curve: Curves.easeInOut,
    );

    _swipeTrailAnimation = CurvedAnimation(
      parent: _swipeTrailController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _directionFeedbackController.dispose();
    _swipeTrailController.dispose();
    super.dispose();
  }

  /// Shows feedback for a direction input.
  void showDirectionFeedback(Direction direction) {
    if (!widget.showDirectionalFeedback) return;

    setState(() {
      _lastDirection = direction;
      _showingFeedback = true;
    });

    _directionFeedbackController.forward().then((_) {
      _directionFeedbackController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showingFeedback = false;
            _lastDirection = null;
          });
        }
      });
    });
  }

  /// Shows feedback for a swipe gesture with trail.
  void showSwipeTrailFeedback(List<Offset> trail) {
    if (!widget.showSwipeTrails || trail.isEmpty) return;

    setState(() {
      _swipeTrail = List.from(trail);
    });

    _swipeTrailController.forward().then((_) {
      _swipeTrailController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _swipeTrail.clear();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Directional feedback overlay
        if (widget.showDirectionalFeedback &&
            _showingFeedback &&
            _lastDirection != null)
          _buildDirectionalFeedback(),

        // Swipe trail feedback overlay
        if (widget.showSwipeTrails && _swipeTrail.isNotEmpty)
          _buildSwipeTrailFeedback(),
      ],
    );
  }

  /// Builds the directional feedback overlay.
  Widget _buildDirectionalFeedback() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _directionFeedbackAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: DirectionalFeedbackPainter(
              direction: _lastDirection!,
              progress: _directionFeedbackAnimation.value,
              color: widget.colors.directionFeedback,
            ),
          );
        },
      ),
    );
  }

  /// Builds the swipe trail feedback overlay.
  Widget _buildSwipeTrailFeedback() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _swipeTrailAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: SwipeTrailPainter(
              trail: _swipeTrail,
              progress: _swipeTrailAnimation.value,
              color: widget.colors.swipeTrail,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for directional feedback arrows.
class DirectionalFeedbackPainter extends CustomPainter {
  final Direction direction;
  final double progress;
  final Color color;

  const DirectionalFeedbackPainter({
    required this.direction,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: progress * 0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final arrowSize = 50.0 * progress;

    // Draw arrow based on direction
    switch (direction) {
      case Direction.up:
        _drawArrow(canvas, paint, center, Offset(0, -arrowSize));
        break;
      case Direction.down:
        _drawArrow(canvas, paint, center, Offset(0, arrowSize));
        break;
      case Direction.left:
        _drawArrow(canvas, paint, center, Offset(-arrowSize, 0));
        break;
      case Direction.right:
        _drawArrow(canvas, paint, center, Offset(arrowSize, 0));
        break;
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset start, Offset end) {
    // Draw main arrow line
    canvas.drawLine(start, start + end, paint);

    // Draw arrowhead
    const arrowHeadLength = 15.0;
    final angle = (end.direction + 3.14159); // 180 degrees

    final arrowHead1 = Offset(
      start.dx +
          end.dx +
          arrowHeadLength * (end.distance * 0.3) * math.cos(angle - 0.5),
      start.dy +
          end.dy +
          arrowHeadLength * (end.distance * 0.3) * math.sin(angle - 0.5),
    );

    final arrowHead2 = Offset(
      start.dx +
          end.dx +
          arrowHeadLength * (end.distance * 0.3) * math.cos(angle + 0.5),
      start.dy +
          end.dy +
          arrowHeadLength * (end.distance * 0.3) * math.sin(angle + 0.5),
    );

    canvas.drawLine(start + end, arrowHead1, paint);
    canvas.drawLine(start + end, arrowHead2, paint);
  }

  @override
  bool shouldRepaint(DirectionalFeedbackPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Custom painter for swipe trail feedback.
class SwipeTrailPainter extends CustomPainter {
  final List<Offset> trail;
  final double progress;
  final Color color;

  const SwipeTrailPainter({
    required this.trail,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;

    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.6)
      ..strokeWidth = 6.0 * (1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(trail.first.dx, trail.first.dy);

    for (int i = 1; i < trail.length; i++) {
      path.lineTo(trail[i].dx, trail[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw dots along the trail
    final dotPaint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < trail.length; i += 3) {
      final radius = 3.0 * (1.0 - progress);
      canvas.drawCircle(trail[i], radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(SwipeTrailPainter oldDelegate) {
    return oldDelegate.trail != trail ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Configuration for input feedback colors.
class InputFeedbackColors {
  /// Color for directional feedback arrows.
  final Color directionFeedback;

  /// Color for swipe trail feedback.
  final Color swipeTrail;

  /// Color for touch point feedback.
  final Color touchPoint;

  const InputFeedbackColors({
    this.directionFeedback = const Color(0xFF4CAF50), // Green
    this.swipeTrail = const Color(0xFF2196F3), // Blue
    this.touchPoint = const Color(0xFFFF9800), // Orange
  });
}
