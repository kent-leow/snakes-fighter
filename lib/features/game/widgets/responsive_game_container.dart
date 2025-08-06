import 'package:flutter/material.dart';

/// A responsive container that adapts the game canvas to different screen sizes.
///
/// This widget ensures the game maintains proper aspect ratio and
/// looks good on mobile phones, tablets, and web browsers.
class ResponsiveGameContainer extends StatelessWidget {
  /// The child widget to make responsive (typically the game canvas).
  final Widget child;

  /// The target aspect ratio for the game (width / height).
  final double targetAspectRatio;

  /// The maximum width for the game container.
  final double? maxWidth;

  /// The maximum height for the game container.
  final double? maxHeight;

  /// The minimum width for the game container.
  final double minWidth;

  /// The minimum height for the game container.
  final double minHeight;

  /// Padding around the game container.
  final EdgeInsets padding;

  /// Background color for the container.
  final Color backgroundColor;

  /// Whether to center the game container.
  final bool centerContent;

  const ResponsiveGameContainer({
    super.key,
    required this.child,
    this.targetAspectRatio = 1.0, // Square by default
    this.maxWidth,
    this.maxHeight,
    this.minWidth = 200.0,
    this.minHeight = 200.0,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = Colors.black,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: backgroundColor,
          child: centerContent
              ? Center(child: _buildResponsiveContainer(constraints))
              : _buildResponsiveContainer(constraints),
        );
      },
    );
  }

  /// Builds the responsive container with proper sizing.
  Widget _buildResponsiveContainer(BoxConstraints constraints) {
    final availableSize = Size(
      constraints.maxWidth - padding.horizontal,
      constraints.maxHeight - padding.vertical,
    );

    final gameSize = _calculateOptimalGameSize(availableSize);

    return Container(
      padding: padding,
      child: SizedBox(
        width: gameSize.width,
        height: gameSize.height,
        child: child,
      ),
    );
  }

  /// Calculates the optimal game size based on available space.
  Size _calculateOptimalGameSize(Size availableSize) {
    // Start with available size
    double width = availableSize.width;
    double height = availableSize.height;

    // Apply aspect ratio constraints
    final currentAspectRatio = width / height;

    if (currentAspectRatio > targetAspectRatio) {
      // Too wide, constrain by height
      width = height * targetAspectRatio;
    } else {
      // Too tall, constrain by width
      height = width / targetAspectRatio;
    }

    // Apply size constraints
    width = _clampWidth(width);
    height = _clampHeight(height);

    // Ensure aspect ratio is maintained after clamping
    final finalAspectRatio = width / height;
    if (finalAspectRatio != targetAspectRatio) {
      if (finalAspectRatio > targetAspectRatio) {
        width = height * targetAspectRatio;
      } else {
        height = width / targetAspectRatio;
      }
    }

    return Size(width, height);
  }

  /// Clamps width to min/max constraints.
  double _clampWidth(double width) {
    if (maxWidth != null) {
      width = width.clamp(minWidth, maxWidth!);
    } else {
      width = width.clamp(minWidth, double.infinity);
    }
    return width;
  }

  /// Clamps height to min/max constraints.
  double _clampHeight(double height) {
    if (maxHeight != null) {
      height = height.clamp(minHeight, maxHeight!);
    } else {
      height = height.clamp(minHeight, double.infinity);
    }
    return height;
  }
}

/// A specialized responsive container for portrait-oriented games.
class PortraitGameContainer extends ResponsiveGameContainer {
  const PortraitGameContainer({
    super.key,
    required super.child,
    super.maxWidth = 400.0,
    super.padding = const EdgeInsets.all(8.0),
    super.backgroundColor,
    super.centerContent,
  }) : super(
         targetAspectRatio: 0.75, // 3:4 portrait ratio
       );
}

/// A specialized responsive container for landscape-oriented games.
class LandscapeGameContainer extends ResponsiveGameContainer {
  const LandscapeGameContainer({
    super.key,
    required super.child,
    super.maxHeight = 500.0,
    super.padding = const EdgeInsets.all(8.0),
    super.backgroundColor,
    super.centerContent,
  }) : super(
         targetAspectRatio: 1.33, // 4:3 landscape ratio
       );
}

/// A specialized responsive container for square games.
class SquareGameContainer extends ResponsiveGameContainer {
  const SquareGameContainer({
    super.key,
    required super.child,
    super.maxWidth = 600.0,
    super.maxHeight = 600.0,
    super.padding = const EdgeInsets.all(16.0),
    super.backgroundColor,
    super.centerContent,
  }) : super(
         targetAspectRatio: 1.0, // 1:1 square ratio
       );
}

/// A responsive container that adapts to different device types.
class AdaptiveGameContainer extends StatelessWidget {
  /// The child widget to make responsive.
  final Widget child;

  /// Background color for the container.
  final Color backgroundColor;

  const AdaptiveGameContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final isTablet = screenSize.shortestSide >= 600;
        final isLandscape = screenSize.width > screenSize.height;

        // Choose container based on device and orientation
        if (isTablet) {
          return SquareGameContainer(
            backgroundColor: backgroundColor,
            child: child,
          );
        } else if (isLandscape) {
          return LandscapeGameContainer(
            backgroundColor: backgroundColor,
            child: child,
          );
        } else {
          return PortraitGameContainer(
            backgroundColor: backgroundColor,
            child: child,
          );
        }
      },
    );
  }
}

/// Utility class for responsive game layout calculations.
class GameLayoutUtils {
  /// Calculates the optimal cell size for a given grid and screen size.
  static double calculateOptimalCellSize({
    required Size screenSize,
    required int gridWidth,
    required int gridHeight,
    required EdgeInsets padding,
    double maxCellSize = 40.0,
    double minCellSize = 10.0,
  }) {
    final availableWidth = screenSize.width - padding.horizontal;
    final availableHeight = screenSize.height - padding.vertical;

    final cellWidth = availableWidth / gridWidth;
    final cellHeight = availableHeight / gridHeight;

    final cellSize = [cellWidth, cellHeight].reduce((a, b) => a < b ? a : b);

    return cellSize.clamp(minCellSize, maxCellSize);
  }

  /// Determines if the current screen is suitable for the game.
  static bool isScreenSuitable(
    Size screenSize, {
    double minWidth = 200.0,
    double minHeight = 200.0,
  }) {
    return screenSize.width >= minWidth && screenSize.height >= minHeight;
  }

  /// Gets the recommended game size for the current screen.
  static Size getRecommendedGameSize(
    Size screenSize,
    double targetAspectRatio,
  ) {
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.8;

    double width = maxWidth;
    double height = maxHeight;

    final currentAspectRatio = width / height;

    if (currentAspectRatio > targetAspectRatio) {
      width = height * targetAspectRatio;
    } else {
      height = width / targetAspectRatio;
    }

    return Size(width, height);
  }
}
