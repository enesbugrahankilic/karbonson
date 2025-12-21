// lib/widgets/custom_form_field.dart
// Reusable custom form field widgets with consistent styling using Design System
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import 'form_field_validator.dart' as custom_validator;

/// Custom email form field with built-in validation
class EmailFormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String?)? onSaved;

  const EmailFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: 1,
      onSaved: onSaved,
      validator: custom_validator.FormFieldValidator.validateEmail,
      style: DesignSystem.getBodyMedium(context),
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.email),
      ),
    );
  }
}

/// Custom password form field with show/hide toggle
class PasswordFormField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String?)? onSaved;

  const PasswordFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onSaved,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      maxLines: 1,
      onSaved: widget.onSaved,
      validator: custom_validator.FormFieldValidator.validatePassword,
      style: DesignSystem.getBodyMedium(context),
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: ThemeColors.getSecondaryText(context),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}

/// Custom password confirmation form field
class PasswordConfirmationFormField extends StatelessWidget {
  final String labelText;
  final String passwordToMatch;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String?)? onSaved;

  const PasswordConfirmationFormField({
    super.key,
    required this.labelText,
    required this.passwordToMatch,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: 1,
      onSaved: onSaved,
      validator: (value) =>
          custom_validator.FormFieldValidator.validatePasswordConfirmation(
              value, passwordToMatch),
      style: DesignSystem.getBodyMedium(context),
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline),
      ),
    );
  }
}

/// Custom nickname form field with random suggestion feature
class NicknameFormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String?)? onSaved;
  final VoidCallback? onSuggestRandom;

  const NicknameFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onSaved,
    this.onSuggestRandom,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: TextInputType.text,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: 1,
      maxLength: 20,
      onSaved: onSaved,
      validator: custom_validator.FormFieldValidator.validateNickname,
      style: DesignSystem.getBodyMedium(context),
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.person),
        suffixIcon: onSuggestRandom != null
            ? IconButton(
                icon: Icon(Icons.casino, color: ThemeColors.getGreen(context)),
                onPressed: onSuggestRandom,
                tooltip: 'Rastgele isim öner',
              )
            : null,
      ),
    );
  }
}

/// Enhanced text form field with design system integration
class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomTextFormField({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      onSaved: onSaved,
      validator: validator,
      style: DesignSystem.getBodyMedium(context),
      decoration: DesignSystem.getInputDecoration(
        context,
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
