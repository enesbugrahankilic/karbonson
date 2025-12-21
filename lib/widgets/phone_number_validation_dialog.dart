import 'package:flutter/material.dart';
import '../services/phone_number_validator.dart';

/// SMS gönderimi öncesi telefon numarası formatını kontrol eden dialog
class PhoneNumberValidationDialog extends StatefulWidget {
  final String? initialPhoneNumber;
  final Function(String validE164Number) onValidPhone;
  final VoidCallback? onCancel;

  const PhoneNumberValidationDialog({
    Key? key,
    this.initialPhoneNumber,
    required this.onValidPhone,
    this.onCancel,
  }) : super(key: key);

  @override
  State<PhoneNumberValidationDialog> createState() =>
      _PhoneNumberValidationDialogState();
}

class _PhoneNumberValidationDialogState
    extends State<PhoneNumberValidationDialog> {
  late TextEditingController _phoneController;
  bool _isValidFormat = false;
  String _formattedNumber = '';
  String _errorMessage = '';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: widget.initialPhoneNumber ?? '');
    _validatePhoneNumber(_phoneController.text);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String phoneNumber) {
    setState(() {
      _isChecking = true;
      _errorMessage = '';
    });

    if (phoneNumber.isEmpty) {
      setState(() {
        _isValidFormat = false;
        _formattedNumber = '';
        _isChecking = false;
      });
      return;
    }

    try {
      if (PhoneNumberValidator.isValid(phoneNumber)) {
        final e164 = PhoneNumberValidator.toE164(phoneNumber);
        if (e164 != null && PhoneNumberValidator.isSMSCompatible(e164)) {
          setState(() {
            _isValidFormat = true;
            _formattedNumber = PhoneNumberValidator.format(phoneNumber);
            _errorMessage = '';
            _isChecking = false;
          });
        } else {
          setState(() {
            _isValidFormat = false;
            _formattedNumber = '';
            _errorMessage = 'SMS gönderimi için uyumlu değil';
            _isChecking = false;
          });
        }
      } else {
        setState(() {
          _isValidFormat = false;
          _formattedNumber = '';
          _errorMessage = 'Geçerli bir telefon numarası girin';
          _errorMessage += '\nÖrnekler: +905551234567, 05551234567, 5551234567';
          _isChecking = false;
        });
      }
    } catch (e) {
      setState(() {
        _isValidFormat = false;
        _formattedNumber = '';
        _errorMessage = 'Hata: ${e.toString()}';
        _isChecking = false;
      });
    }
  }

  void _sendSMS() {
    if (_isValidFormat && _formattedNumber.isNotEmpty) {
      final e164 = PhoneNumberValidator.toE164(_phoneController.text);
      if (e164 != null) {
        widget.onValidPhone(e164);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMS Numarası Doğrulama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SMS almak için telefon numaranızı girin:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+90 555 123 4567 veya 05551234567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isValidFormat ? Colors.green : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isValidFormat ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                prefixIcon: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(
                        _isValidFormat ? Icons.check_circle : Icons.phone,
                        color: _isValidFormat ? Colors.green : Colors.grey,
                      ),
              ),
              onChanged: _validatePhoneNumber,
            ),
            const SizedBox(height: 12),
            if (_isValidFormat && _formattedNumber.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SMS Formatı: $_formattedNumber',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    widget.onCancel?.call();
                    Navigator.pop(context);
                  },
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isValidFormat ? _sendSMS : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SMS Gönder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
