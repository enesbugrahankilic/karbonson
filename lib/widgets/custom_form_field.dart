// lib/widgets/custom_form_field.dart
// Reusable custom form field widgets with consistent styling
import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
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
      style: TextStyle(color: ThemeColors.getText(context)),
      decoration: _buildInputDecoration(context),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: ThemeColors.getInputBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getPrimaryButtonColor(context), width: 2),
      ),
      prefixIcon: Icon(Icons.email, color: ThemeColors.getSecondaryText(context)),
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle: TextStyle(
        color: ThemeColors.getErrorColor(context), 
        fontSize: 12
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
      style: TextStyle(color: ThemeColors.getText(context)),
      decoration: _buildInputDecoration(context),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      filled: true,
      fillColor: ThemeColors.getInputBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getPrimaryButtonColor(context), width: 2),
      ),
      prefixIcon: Icon(Icons.lock, color: ThemeColors.getSecondaryText(context)),
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
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle: TextStyle(
        color: ThemeColors.getErrorColor(context), 
        fontSize: 12
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
      validator: (value) => custom_validator.FormFieldValidator.validatePasswordConfirmation(value, passwordToMatch),
      style: TextStyle(color: ThemeColors.getText(context)),
      decoration: _buildInputDecoration(context),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: ThemeColors.getInputBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getPrimaryButtonColor(context), width: 2),
      ),
      prefixIcon: Icon(Icons.lock_outline, color: ThemeColors.getSecondaryText(context)),
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle: TextStyle(
        color: ThemeColors.getErrorColor(context), 
        fontSize: 12
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
      style: TextStyle(color: ThemeColors.getText(context)),
      decoration: _buildInputDecoration(context),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: ThemeColors.getInputBackground(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getBorder(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.getPrimaryButtonColor(context), width: 2),
      ),
      prefixIcon: Icon(Icons.person, color: ThemeColors.getSecondaryText(context)),
      suffixIcon: onSuggestRandom != null
          ? IconButton(
              icon: Icon(Icons.casino, color: ThemeColors.getGreen(context)),
              onPressed: onSuggestRandom,
              tooltip: 'Rastgele isim öner',
            )
          : null,
      labelStyle: TextStyle(color: ThemeColors.getSecondaryText(context)),
      errorStyle: TextStyle(
        color: ThemeColors.getErrorColor(context), 
        fontSize: 12
      ),
      counterStyle: TextStyle(color: ThemeColors.getSecondaryText(context), fontSize: 12),
    );
  }
}