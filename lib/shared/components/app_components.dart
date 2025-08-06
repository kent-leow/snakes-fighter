import 'package:flutter/material.dart';

import '../../core/design_system/design_tokens.dart';

/// Enhanced card component following design system guidelines
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final AppCardVariant variant;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.variant = AppCardVariant.elevated,
  });

  /// Factory for outlined card
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
  }) : variant = AppCardVariant.outlined,
       elevation = null;

  /// Factory for filled card
  const AppCard.filled({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
  }) : variant = AppCardVariant.filled,
       elevation = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectivePadding =
        padding ?? const EdgeInsets.all(DesignTokens.spacing16);
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(DesignTokens.radiusMedium);

    final (cardColor, cardElevation, border) = switch (variant) {
      AppCardVariant.elevated => (
        color ?? colorScheme.surface,
        elevation ?? DesignTokens.elevation1,
        null,
      ),
      AppCardVariant.outlined => (
        color ?? colorScheme.surface,
        0.0,
        Border.all(color: colorScheme.outline),
      ),
      AppCardVariant.filled => (
        color ?? colorScheme.surfaceContainerHighest,
        0.0,
        null,
      ),
    };

    Widget card = Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: cardElevation > 0
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: cardElevation * 2,
                  offset: Offset(0, cardElevation),
                ),
              ]
            : null,
      ),
      child: Padding(padding: effectivePadding, child: child),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// Card variant enumeration
enum AppCardVariant { elevated, outlined, filled }

/// Loading indicator component
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final AppLoadingSize size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = AppLoadingSize.medium,
    this.color,
  });

  /// Factory for small loading indicator
  const AppLoadingIndicator.small({super.key, this.message, this.color})
    : size = AppLoadingSize.small;

  /// Factory for large loading indicator
  const AppLoadingIndicator.large({super.key, this.message, this.color})
    : size = AppLoadingSize.large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final indicatorSize = switch (size) {
      AppLoadingSize.small => 16.0,
      AppLoadingSize.medium => 24.0,
      AppLoadingSize.large => 32.0,
    };

    final indicator = SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        strokeWidth: size == AppLoadingSize.small ? 2.0 : 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? colorScheme.primary),
      ),
    );

    if (message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: DesignTokens.spacing16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }
}

/// Loading size enumeration
enum AppLoadingSize { small, medium, large }

/// Badge component for status indicators
class AppBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final AppBadgeSize size;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.size = AppBadgeSize.medium,
    this.variant = AppBadgeVariant.filled,
  });

  /// Factory for success badge
  const AppBadge.success({
    super.key,
    required this.text,
    this.size = AppBadgeSize.medium,
    this.variant = AppBadgeVariant.filled,
  }) : backgroundColor = null,
       textColor = null;

  /// Factory for error badge
  const AppBadge.error({
    super.key,
    required this.text,
    this.size = AppBadgeSize.medium,
    this.variant = AppBadgeVariant.filled,
  }) : backgroundColor = null,
       textColor = null;

  /// Factory for warning badge
  const AppBadge.warning({
    super.key,
    required this.text,
    this.size = AppBadgeSize.medium,
    this.variant = AppBadgeVariant.filled,
  }) : backgroundColor = null,
       textColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (effectiveBackgroundColor, effectiveTextColor) = switch (variant) {
      AppBadgeVariant.filled => (
        backgroundColor ?? colorScheme.primary,
        textColor ?? colorScheme.onPrimary,
      ),
      AppBadgeVariant.outlined => (
        Colors.transparent,
        textColor ?? colorScheme.primary,
      ),
    };

    final padding = switch (size) {
      AppBadgeSize.small => const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing8,
        vertical: DesignTokens.spacing2,
      ),
      AppBadgeSize.medium => const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing12,
        vertical: DesignTokens.spacing4,
      ),
      AppBadgeSize.large => const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacing16,
        vertical: DesignTokens.spacing8,
      ),
    };

    final textStyle = switch (size) {
      AppBadgeSize.small => theme.textTheme.labelSmall,
      AppBadgeSize.medium => theme.textTheme.labelMedium,
      AppBadgeSize.large => theme.textTheme.labelLarge,
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXXLarge),
        border: variant == AppBadgeVariant.outlined
            ? Border.all(color: effectiveTextColor)
            : null,
      ),
      child: Text(
        text,
        style: textStyle?.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Badge size enumeration
enum AppBadgeSize { small, medium, large }

/// Badge variant enumeration
enum AppBadgeVariant { filled, outlined }
