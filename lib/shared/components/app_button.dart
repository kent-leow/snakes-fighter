import 'package:flutter/material.dart';
import '../../core/design_system/design_tokens.dart';

/// Enhanced button component following design system guidelines
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isExpanded;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  /// Factory for primary button
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : style = AppButtonStyle.primary;

  /// Factory for secondary button
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : style = AppButtonStyle.secondary;

  /// Factory for outline button
  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : style = AppButtonStyle.outline;

  /// Factory for text button
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : style = AppButtonStyle.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonConfig = _getButtonConfig(theme, style, size);

    Widget button = switch (style) {
      AppButtonStyle.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonConfig.buttonStyle,
        child: _buildButtonContent(buttonConfig),
      ),
      AppButtonStyle.secondary => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        style: buttonConfig.buttonStyle,
        child: _buildButtonContent(buttonConfig),
      ),
      AppButtonStyle.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonConfig.buttonStyle,
        child: _buildButtonContent(buttonConfig),
      ),
      AppButtonStyle.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonConfig.buttonStyle,
        child: _buildButtonContent(buttonConfig),
      ),
    };

    if (isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButtonContent(_ButtonConfig config) {
    if (isLoading) {
      return SizedBox(
        height: config.iconSize,
        width: config.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(config.foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              color: config.foregroundColor,
              size: config.iconSize,
            ),
            child: icon!,
          ),
          SizedBox(width: DesignTokens.spacing8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  _ButtonConfig _getButtonConfig(
    ThemeData theme,
    AppButtonStyle style,
    AppButtonSize size,
  ) {
    final colorScheme = theme.colorScheme;
    final sizeConfig = _getSizeConfig(size);

    final (backgroundColor, foregroundColor) = switch (style) {
      AppButtonStyle.primary => (colorScheme.primary, colorScheme.onPrimary),
      AppButtonStyle.secondary => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      AppButtonStyle.outline => (Colors.transparent, colorScheme.primary),
      AppButtonStyle.text => (Colors.transparent, colorScheme.primary),
    };

    return _ButtonConfig(
      buttonStyle: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        padding: WidgetStateProperty.all(sizeConfig.padding),
        minimumSize: WidgetStateProperty.all(sizeConfig.minimumSize),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (style == AppButtonStyle.primary &&
              !states.contains(WidgetState.disabled)) {
            return DesignTokens.elevation1;
          }
          return DesignTokens.elevation0;
        }),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconSize: sizeConfig.iconSize,
    );
  }

  _SizeConfig _getSizeConfig(AppButtonSize size) {
    return switch (size) {
      AppButtonSize.small => _SizeConfig(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing16,
          vertical: DesignTokens.spacing8,
        ),
        minimumSize: const Size(64, 32),
        borderRadius: DesignTokens.radiusSmall,
        iconSize: DesignTokens.iconSmall,
      ),
      AppButtonSize.medium => _SizeConfig(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing24,
          vertical: DesignTokens.spacing12,
        ),
        minimumSize: const Size(80, 40),
        borderRadius: DesignTokens.radiusMedium,
        iconSize: DesignTokens.iconMedium,
      ),
      AppButtonSize.large => _SizeConfig(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacing32,
          vertical: DesignTokens.spacing16,
        ),
        minimumSize: const Size(96, 48),
        borderRadius: DesignTokens.radiusLarge,
        iconSize: DesignTokens.iconLarge,
      ),
    };
  }
}

/// Button style enumeration
enum AppButtonStyle { primary, secondary, outline, text }

/// Button size enumeration
enum AppButtonSize { small, medium, large }

/// Internal button configuration
class _ButtonConfig {
  final ButtonStyle buttonStyle;
  final Color backgroundColor;
  final Color foregroundColor;
  final double iconSize;

  const _ButtonConfig({
    required this.buttonStyle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconSize,
  });
}

/// Internal size configuration
class _SizeConfig {
  final EdgeInsets padding;
  final Size minimumSize;
  final double borderRadius;
  final double iconSize;

  const _SizeConfig({
    required this.padding,
    required this.minimumSize,
    required this.borderRadius,
    required this.iconSize,
  });
}
