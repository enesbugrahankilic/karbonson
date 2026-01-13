import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/email_otp_service.dart';


class EmailOtpVerificationPage extends StatefulWidget {
  final String email;
  final String verificationId;
  final Function(String otp) onVerify;

  const EmailOtpVerificationPage({
    Key? key,
    required this.email,
    required this.verificationId,
    required this.onVerify,
  }) : super(key: key);

  @override
  State<EmailOtpVerificationPage> createState() => _EmailOtpVerificationPageState();
}

class _EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final EmailOtpService _otpService = EmailOtpService();
  bool _isVerifying = false;
  int _resendCooldown = 0;
  String _errorMessage = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'Lütfen 6 haneli kodu girin';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });

    try {
      final result = await EmailOtpService.verifyOtpCode(
        email: widget.email,
        code: _otpController.text,
      );

      if (result.isValid) {
        widget.onVerify(_otpController.text);
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Doğrulama sırasında bir hata oluştu';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0) return;

    try {
      await EmailOtpService.sendOtpCode(email: widget.email);
      _startResendCooldown();
      setState(() {
        _errorMessage = '';
        _otpController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni kod gönderildi')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Doğrulama'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.email_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'E-posta Adresinizi Doğrulayın',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.email} adresine gönderilen 6 haneli kodu girin',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Doğrula'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _resendCooldown > 0 ? null : _resendCode,
                child: Text(
                  _resendCooldown > 0
                      ? 'Yeniden gönder ($_resendCooldown)'
                      : 'Kodu yeniden gönder',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}