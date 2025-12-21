import 'package:flutter/material.dart';
import 'dart:async';
import '../services/email_otp_service.dart';
import '../services/phone_number_validator.dart';
import '../widgets/phone_number_validation_dialog.dart';

/// 2FA SMS Doğrulama Sayfası
class TwoFactorAuthPage extends StatefulWidget {
  final String userId;
  final VoidCallback? onVerificationSuccess;
  final String? initialPhoneNumber;

  const TwoFactorAuthPage({
    Key? key,
    required this.userId,
    this.onVerificationSuccess,
    this.initialPhoneNumber,
  }) : super(key: key);

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  final TextEditingController _codeController = TextEditingController();
  String? _phoneNumber;
  bool _isLoadingSms = false;
  bool _isVerifying = false;
  String? _countdownText;
  Timer? _countdownTimer;
  bool _codeSent = false;
  int _resendAttempts = 0;
  static const int _maxResendAttempts = 3;

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.initialPhoneNumber;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PhoneNumberValidationDialog(
        initialPhoneNumber: _phoneNumber,
        onValidPhone: _sendSmsOtp,
        onCancel: () {
          if (!_codeSent) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _sendSmsOtp(String e164PhoneNumber) async {
    setState(() {
      _isLoadingSms = true;
      _phoneNumber = e164PhoneNumber;
      _codeController.clear();
    });

    try {
      final result = await EmailOtpService.sendSmsOtpCode(
        phoneNumber: e164PhoneNumber,
        purpose: 'two_factor',
      );

      if (mounted) {
        if (result.isSuccess) {
          setState(() {
            _codeSent = true;
            _resendAttempts = 0;
            _isLoadingSms = false;
          });

          _startCountdown();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          setState(() {
            _isLoadingSms = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSms = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS gönderme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startCountdown() {
    const duration = Duration(minutes: 5);
    final endTime = DateTime.now().add(duration);

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        setState(() {
          _countdownText = 'Süre doldu';
          _codeSent = false;
        });
      } else {
        final minutes = remaining.inMinutes;
        final seconds = remaining.inSeconds % 60;
        setState(() {
          _countdownText =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty || _phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğrulama kodunu girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await EmailOtpService.verifySmsOtpCode(
        phoneNumber: _phoneNumber!,
        code: _codeController.text,
      );

      if (mounted) {
        if (result.isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('2FA başarıyla doğrulandı! ✓'),
              backgroundColor: Colors.green,
            ),
          );

          // Doğrulama başarılı callback
          widget.onVerificationSuccess?.call();

          // 1 saniye sonra geri dön
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else if (result.isExpired) {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Kodun süresi dolmuş. Yeni bir kod isteyin.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Doğrulama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resendCode() {
    if (_resendAttempts >= _maxResendAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Çok fazla yeniden gönderme denemesi. Lütfen daha sonra deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _resendAttempts++;
    _codeController.clear();
    _sendSmsOtp(_phoneNumber!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İki Adımlı Doğrulama'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '2FA Doğrulaması',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hesabınızı korumak için SMS ile doğrulama kodu göndereceğiz',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Telefon numarası seçimi
            if (!_codeSent)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Doğrulama kodu almak için telefon numaranızı seçin',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingSms ? null : _showPhoneNumberDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoadingSms
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Telefon Numarası Seç ve Kod Gönder',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SMS Gönderildi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Telefon: ${_phoneNumber ?? "Bilinmiyor"}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kod giriş alanı
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Geri sayım
                  if (_countdownText != null)
                    Text(
                      'Kalan süre: $_countdownText',
                      style: TextStyle(
                        color: _countdownText == 'Süre doldu'
                            ? Colors.red
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Doğrula butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying || _codeController.text.isEmpty
                          ? null
                          : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Doğrula',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kodu tekrar gönder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Kod almadınız mı? '),
                      TextButton(
                        onPressed: (_resendAttempts >= _maxResendAttempts ||
                                _isLoadingSms)
                            ? null
                            : _resendCode,
                        child: Text(
                          'Tekrar Gönder${_resendAttempts > 0 ? ' ($_resendAttempts/$_maxResendAttempts)' : ''}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Telefon numarasını değiştir
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _codeSent = false;
                        _codeController.clear();
                        _countdownTimer?.cancel();
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Telefon Numarasını Değiştir'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
