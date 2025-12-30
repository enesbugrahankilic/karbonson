import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../services/email_otp_service.dart';
import '../services/phone_number_validator.dart';
import '../widgets/phone_number_validation_dialog.dart';
import '../theme/theme_colors.dart';

/// Gelişmiş SMS OTP giriş widget'ı
class SmsOtpLoginWidget extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onError;
  final bool showAsDialog;

  const SmsOtpLoginWidget({
    super.key,
    this.onLoginSuccess,
    this.onError,
    this.showAsDialog = false,
  });

  @override
  State<SmsOtpLoginWidget> createState() => _SmsOtpLoginWidgetState();
}

class _SmsOtpLoginWidgetState extends State<SmsOtpLoginWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _selectedPhoneNumber = '';
  int _resendCountdown = 0;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _initializePhoneNumber() async {
    // Kullanıcının kayıtlı telefon numarasını al (varsa)
    try {
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // For now, don't preload phone number - user will enter it
        // Future enhancement: could load from user profile if available
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Telefon numarası yükleme hatası: $e');
      }
    }
  }

  Future<void> _sendSmsOtp() async {
    if (_phoneController.text.isEmpty) {
      _showError('Lütfen telefon numaranızı girin');
      return;
    }

    // Telefon numarasını doğrula
    if (!PhoneNumberValidator.isValid(_phoneController.text)) {
      _showError('Geçerli bir telefon numarası girin');
      return;
    }

    // E.164 formatına çevir
    final e164Number = PhoneNumberValidator.toE164(_phoneController.text);
    if (e164Number == null) {
      _showError('Telefon numarası formatı desteklenmiyor');
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedPhoneNumber = e164Number;
    });

    try {
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: e164Number,
        purpose: 'login_verification',
      );

      if (result.isSuccess) {
        setState(() {
          _otpSent = true;
          _canResend = false;
          _resendCountdown = 60; // 60 saniye bekleme
        });
        _showSuccess(
            'SMS kodu gönderildi: ${PhoneNumberValidator.format(e164Number)}');
        _startResendCountdown();
      } else {
        _showError(result.message);
        widget.onError?.call();
      }
    } catch (e) {
      _showError('SMS gönderilirken hata oluştu: $e');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifySmsOtp() async {
    if (_otpController.text.isEmpty) {
      _showError('Lütfen SMS kodunu girin');
      return;
    }

    if (_otpController.text.length != 6) {
      _showError('SMS kodu 6 haneli olmalıdır');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await EmailOtpService.verifySmsOtpCode(
        phoneNumber: _selectedPhoneNumber,
        code: _otpController.text,
      );

      if (result.isValid) {
        _showSuccess('Giriş başarılı! 🎉');
        widget.onLoginSuccess?.call();
      } else if (result.isExpired) {
        _showError('SMS kodu süresi dolmuş. Yeni kod isteyin.');
        setState(() {
          _otpSent = false;
          _canResend = true;
        });
      } else {
        _showError('Geçersiz SMS kodu. Lütfen tekrar deneyin.');
      }
    } catch (e) {
      _showError('Doğrulama sırasında hata oluştu: $e');
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startResendCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
          _startResendCountdown();
        } else {
          _canResend = true;
        }
      });
    });
  }

  Future<void> _showPhoneValidationDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => PhoneNumberValidationDialog(
        initialPhoneNumber: _phoneController.text,
        onValidPhone: (validNumber) {
          Navigator.of(context).pop(validNumber);
        },
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _phoneController.text = result;
        _selectedPhoneNumber = result;
      });
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefon Numarası',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getText(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '0555 123 45 67',
                  filled: true,
                  fillColor: ThemeColors.getInputBackground(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: ThemeColors.getBorder(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: ThemeColors.getPrimaryButtonColor(context),
                        width: 2),
                  ),
                  prefixIcon: Icon(Icons.phone,
                      color: ThemeColors.getSecondaryText(context)),
                ),
                style: TextStyle(color: ThemeColors.getText(context)),
                readOnly: _otpSent, // OTP gönderildikten sonra değiştirilemez
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _otpSent ? null : _showPhoneValidationDialog,
              icon: Icon(
                Icons.edit,
                color: _otpSent
                    ? Colors.grey
                    : ThemeColors.getPrimaryButtonColor(context),
              ),
              tooltip: 'Numara Düzenle',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMS Kodu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.getText(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: '123456',
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
              borderSide: BorderSide(
                  color: ThemeColors.getPrimaryButtonColor(context), width: 2),
            ),
            counterText: '',
          ),
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isLoading || !_canResend) ? null : _sendSmsOtp,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send),
        label: Text(
          _isLoading
              ? 'Gönderiliyor...'
              : _canResend
                  ? 'SMS Kod Gönder'
                  : 'Tekrar Gönder (${_resendCountdown}s)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.getPrimaryButtonColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _verifySmsOtp,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.verified),
        label: Text(
          _isLoading ? 'Doğrulanıyor...' : 'Kodu Doğrula',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColors.getGreen(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: ThemeColors.getDialogBackground(context),
        title: Row(
          children: [
            Icon(Icons.sms, color: ThemeColors.getGreen(context), size: 28),
            const SizedBox(width: 8),
            Text(
              'SMS ile Giriş',
              style: TextStyle(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_otpSent) ...[
                  _buildPhoneInput(),
                  const SizedBox(height: 16),
                  _buildSendButton(),
                ] else ...[
                  Text(
                    'SMS kodu gönderildi:\n${PhoneNumberValidator.format(_selectedPhoneNumber)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeColors.getSecondaryText(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOtpInput(),
                  const SizedBox(height: 16),
                  _buildVerifyButton(),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _canResend
                        ? () {
                            setState(() {
                              _otpSent = false;
                              _otpController.clear();
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.refresh,
                      size: 18,
                      color: _canResend
                          ? ThemeColors.getInfoColor(context)
                          : Colors.grey,
                    ),
                    label: Text(
                      _canResend
                          ? 'Farklı Numara Kullan'
                          : 'Yeni Kod (${_resendCountdown}s)',
                      style: TextStyle(
                        color: _canResend
                            ? ThemeColors.getInfoColor(context)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: TextStyle(color: ThemeColors.getSecondaryText(context)),
            ),
          ),
        ],
      );
    }

    // Normal widget görünümü
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sms, color: ThemeColors.getGreen(context), size: 28),
                const SizedBox(width: 12),
                Text(
                  'SMS ile Giriş',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.getText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_otpSent) ...[
              _buildPhoneInput(),
              const SizedBox(height: 20),
              _buildSendButton(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'SMS kodu gönderildi:\n${PhoneNumberValidator.format(_selectedPhoneNumber)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeColors.getText(context),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildOtpInput(),
              const SizedBox(height: 20),
              _buildVerifyButton(),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _canResend
                      ? () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: _canResend
                        ? ThemeColors.getInfoColor(context)
                        : Colors.grey,
                  ),
                  label: Text(
                    _canResend
                        ? 'Farklı Numara Kullan'
                        : 'Yeni Kod (${_resendCountdown}s)',
                    style: TextStyle(
                      color: _canResend
                          ? ThemeColors.getInfoColor(context)
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
