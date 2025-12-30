import 'package:flutter/material.dart';
import '../services/input_validation_service.dart';

/// Advanced input validation widget that provides real-time validation feedback
/// Integrates with InputValidationService for comprehensive validation
class InputValidatorWidget extends StatefulWidget {
  final String? initialValue;
  final String label;
  final String hint;
  final ValidationType validationType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool showValidationMessage;
  final bool autoValidate;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const InputValidatorWidget({
    super.key,
    this.initialValue,
    required this.label,
    required this.hint,
    required this.validationType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.showValidationMessage = true,
    this.autoValidate = false,
    this.controller,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<InputValidatorWidget> createState() => _InputValidatorWidgetState();
}

class _InputValidatorWidgetState extends State<InputValidatorWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  ValidationResult? _currentValidation;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    // Add listeners for real-time validation
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _currentValidation = _validateInput(_controller.text);
    });
    
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _hasInteracted = true;
      });
    }
  }

  ValidationResult _validateInput(String value) {
    switch (widget.validationType) {
      case ValidationType.email:
        return InputValidationService().validateEmail(value);
      case ValidationType.nickname:
        return InputValidationService().validateNickname(value);
      case ValidationType.password:
        return InputValidationService().validatePassword(value);
      case ValidationType.general:
        return _validateGeneralInput(value);
    }
  }

  ValidationResult _validateGeneralInput(String value) {
    if (value.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Bu alan gereklidir',
        errorCode: ValidationErrorCode.requiredField,
      );
    }

    if (value.length > 1000) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Metin çok uzun',
        errorCode: ValidationErrorCode.tooLong,
      );
    }

    return ValidationResult(isValid: true);
  }

  bool get _shouldShowError {
    return _hasInteracted || widget.autoValidate || widget.showValidationMessage;
  }

  bool get _isValid {
    return _currentValidation?.isValid ?? false;
  }

  String? get _errorText {
    if (!_shouldShowError || _isValid) return null;
    return _currentValidation?.errorMessage;
  }

  Color _getBorderColor() {
    if (!_shouldShowError) return Colors.grey.shade300;
    return _isValid ? Colors.green.shade400 : Colors.red.shade400;
  }

  Color? _getFillColor() {
    if (!_isValid && _hasInteracted && !_focusNode.hasFocus) {
      return Colors.red.shade50;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _getBorderColor()),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: _getBorderColor(), width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
            ),
            filled: _getFillColor() != null,
            fillColor: _getFillColor(),
            errorStyle: const TextStyle(fontSize: 12.0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          style: const TextStyle(fontSize: 16.0),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 4.0),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16.0,
                color: Colors.red.shade400,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: Text(
                  _errorText!,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (_isValid && _hasInteracted) ...[
          const SizedBox(height: 4.0),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16.0,
                color: Colors.green.shade400,
              ),
              const SizedBox(width: 4.0),
              Text(
                'Geçerli',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _controller.text.isEmpty ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey.shade600,
        ),
        onPressed: () {
          setState(() {
            // Toggle obscure text - this would need to be managed differently
            // for proper state management
          });
        },
      );
    }

    if (_hasInteracted) {
      if (_isValid) {
        return Icon(Icons.check_circle, color: Colors.green.shade400);
      } else if (_currentValidation?.errorMessage.isNotEmpty == true) {
        return Icon(Icons.error, color: Colors.red.shade400);
      }
    }

    return null;
  }

  /// Public method to manually trigger validation
  void validate() {
    setState(() {
      _hasInteracted = true;
      _currentValidation = _validateInput(_controller.text);
    });
  }

  /// Public method to clear validation state
  void clearValidation() {
    setState(() {
      _hasInteracted = false;
      _currentValidation = null;
    });
  }

  /// Get current validation result
  ValidationResult? get currentValidation => _currentValidation;

  /// Check if current input is valid
  bool get isValid => _isValid;
}

/// Validation types supported by the widget
enum ValidationType {
  email,
  nickname,
  password,
  general,
}

/// Convenience widgets for common validation scenarios
class EmailInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;

  const EmailInputWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return InputValidatorWidget(
      controller: controller,
      onChanged: onChanged,
      validationType: ValidationType.email,
      label: label ?? 'E-posta',
      hint: hint ?? 'ornek@email.com',
      prefixIcon: const Icon(Icons.email),
      textInputAction: TextInputAction.next,
    );
  }
}

class NicknameInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;

  const NicknameInputWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return InputValidatorWidget(
      controller: controller,
      onChanged: onChanged,
      validationType: ValidationType.nickname,
      label: label ?? 'Kullanıcı Adı',
      hint: hint ?? 'En az 3 karakter',
      prefixIcon: const Icon(Icons.person),
      maxLength: 20,
      textInputAction: TextInputAction.next,
    );
  }
}

class PasswordInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const PasswordInputWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.obscureText = true,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return InputValidatorWidget(
      controller: controller,
      onChanged: onChanged,
      validationType: ValidationType.password,
      label: label ?? 'Şifre',
      hint: hint ?? 'En az 8 karakter, büyük/küçük harf, rakam ve özel karakter',
      obscureText: obscureText,
      prefixIcon: const Icon(Icons.lock),
      textInputAction: textInputAction ?? TextInputAction.next,
    );
  }
}