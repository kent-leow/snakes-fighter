import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system/design_tokens.dart';

/// Enhanced text field component following design system guidelines
class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  /// Factory for email input
  const AppTextField.email({
    super.key,
    this.labelText = 'Email',
    this.hintText = 'Enter your email',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon = const Icon(Icons.email_outlined),
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autofocus = false,
  }) : keyboardType = TextInputType.emailAddress,
       obscureText = false,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       prefixText = null,
       suffixText = null,
       textCapitalization = TextCapitalization.none;

  /// Factory for password input
  const AppTextField.password({
    super.key,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon = const Icon(Icons.lock_outlined),
    this.suffixIcon,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.autofocus = false,
  }) : keyboardType = TextInputType.visiblePassword,
       obscureText = true,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       prefixText = null,
       suffixText = null,
       textCapitalization = TextCapitalization.none;

  /// Factory for search input
  const AppTextField.search({
    super.key,
    this.labelText,
    this.hintText = 'Search...',
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon = const Icon(Icons.search),
    this.suffixIcon,
    this.textInputAction = TextInputAction.search,
    this.focusNode,
    this.autofocus = false,
  }) : keyboardType = TextInputType.text,
       obscureText = false,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       prefixText = null,
       suffixText = null,
       textCapitalization = TextCapitalization.none;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: widget.enabled
                ? colorScheme.onSurface
                : colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(colorScheme),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.12),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacing16,
              vertical: DesignTokens.spacing16,
            ),
            labelStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
            ),
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (widget.helperText != null && widget.errorText == null)
          Padding(
            padding: const EdgeInsets.only(
              left: DesignTokens.spacing16,
              top: DesignTokens.spacing4,
            ),
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}

/// Text area component for multi-line input
class AppTextArea extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;

  const AppTextArea({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
    );
  }
}
