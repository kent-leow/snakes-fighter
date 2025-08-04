import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities for adaptive layouts
class ResponsiveBreakpoints {
  // Private constructor to prevent instantiation
  ResponsiveBreakpoints._();

  // Breakpoint values in logical pixels
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;

  /// Check if current screen size is mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if current screen size is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;

  /// Check if current screen size is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop &&
      MediaQuery.of(context).size.width < largeDesktop;

  /// Check if current screen size is large desktop
  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= largeDesktop;

  /// Get current device type as enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    if (width < largeDesktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobile) return ScreenSize.compact;
    if (width < desktop) return ScreenSize.medium;
    return ScreenSize.expanded;
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Screen size categories based on Material Design 3
enum ScreenSize {
  compact,  // < 600dp
  medium,   // 600dp - 900dp
  expanded, // > 900dp
}

/// Responsive layout widget that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.largeDesktop) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
        
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        
        if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          return tablet ?? mobile;
        }
        
        return mobile;
      },
    );
  }
}

/// Responsive value that changes based on screen size
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  /// Get the appropriate value for current context
  T getValue(BuildContext context) {
    if (ResponsiveBreakpoints.isLargeDesktop(context)) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
    
    if (ResponsiveBreakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    
    if (ResponsiveBreakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    
    return mobile;
  }
}

/// Extension on BuildContext for easy responsive access
extension ResponsiveExtension on BuildContext {
  /// Check if current screen is mobile
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  
  /// Check if current screen is tablet
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  
  /// Check if current screen is desktop
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);
  
  /// Check if current screen is large desktop
  bool get isLargeDesktop => ResponsiveBreakpoints.isLargeDesktop(this);
  
  /// Get current device type
  DeviceType get deviceType => ResponsiveBreakpoints.getDeviceType(this);
  
  /// Get current screen size category
  ScreenSize get screenSize => ResponsiveBreakpoints.getScreenSize(this);
  
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Responsive grid system
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<int> columns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = columns.getValue(context);
    final itemsPerRow = (children.length / columnCount).ceil();
    
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: List.generate(itemsPerRow, (rowIndex) {
        final startIndex = rowIndex * columnCount;
        final endIndex = (startIndex + columnCount).clamp(0, children.length);
        final rowChildren = children.sublist(startIndex, endIndex);
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < itemsPerRow - 1 ? runSpacing : 0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rowChildren.length; i++) ...[
                Expanded(child: rowChildren[i]),
                if (i < rowChildren.length - 1) SizedBox(width: spacing),
              ],
              // Fill remaining space if row is not complete
              if (rowChildren.length < columnCount)
                ...List.generate(
                  columnCount - rowChildren.length,
                  (index) => const Expanded(child: SizedBox()),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// Responsive padding utility
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<EdgeInsets> padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding.getValue(context),
      child: child,
    );
  }
}
