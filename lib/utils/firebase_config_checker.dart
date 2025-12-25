// lib/utils/firebase_config_checker.dart
// Firebase Configuration Diagnostic Tool

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_auth_service.dart';

class FirebaseConfigChecker extends StatefulWidget {
  const FirebaseConfigChecker({super.key});

  @override
  State<FirebaseConfigChecker> createState() => _FirebaseConfigCheckerState();
}

class _FirebaseConfigCheckerState extends State<FirebaseConfigChecker> {
  bool _isRunning = false;
  Map<String, dynamic> _diagnosticResults = {};
  String _statusMessage = 'Hazır';

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _statusMessage = 'Firebase konfigürasyonu kontrol ediliyor...';
      _diagnosticResults = {};
    });

    try {
      // Get comprehensive debug info
      final debugInfo = await FirebaseAuthService.getDebugInfo();

      // Check anonymous auth specifically
      final anonymousCheck =
          await FirebaseAuthService.checkAnonymousAuthEnabled();

      // Check general auth configuration
      final configCheck = await FirebaseAuthService.checkAuthConfiguration();

      setState(() {
        _diagnosticResults = {
          'debug_info': debugInfo,
          'anonymous_check': anonymousCheck,
          'config_check': configCheck,
          'timestamp': DateTime.now().toIso8601String(),
        };
        _statusMessage = 'Tanı tamamlandı';
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firebase diagnostic failed: $e');
      }
      setState(() {
        _statusMessage = 'Tanı sırasında hata: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.security, color: Colors.orange, size: 28),
          const SizedBox(width: 8),
          const Text('Firebase Yapılandırma Tanısı'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_diagnosticResults.isNotEmpty) ...[
              _buildDiagnosticSection(
                '🔍 Tanı Sonuçları',
                _buildDiagnosticResults(),
              ),
            ],
            const SizedBox(height: 16),
            if (_diagnosticResults.isNotEmpty &&
                _diagnosticResults['anonymous_check']?['enabled'] == false)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Çözüm: Anonymous Authentication Etkinleştir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Firebase Console\'a gidin\n'
                      '2. Authentication > Sign-in method seçin\n'
                      '3. Anonymous provider\'ı etkinleştirin\n'
                      '4. Değişiklikleri kaydedin',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (_diagnosticResults.isNotEmpty)
          TextButton.icon(
            onPressed: () => _runDiagnostics(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Yeniden Test Et'),
          ),
        TextButton(
          onPressed: _isRunning ? null : () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
        if (_diagnosticResults.isEmpty)
          ElevatedButton.icon(
            onPressed: _isRunning ? null : _runDiagnostics,
            icon: _isRunning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow, size: 16),
            label: const Text('Tanı Başlat'),
          ),
      ],
    );
  }

  Widget _buildDiagnosticResults() {
    final anonymousCheck = _diagnosticResults['anonymous_check'];
    final configCheck = _diagnosticResults['config_check'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckItem(
          'Firebase Başlatıldı',
          configCheck?['firebase_initialized'] == true,
        ),
        _buildCheckItem(
          'Anonymous Sign-in Etkin',
          anonymousCheck?['enabled'] == true,
        ),
        _buildCheckItem(
          'Mevcut Kullanıcı',
          configCheck?['current_user_available'] == true,
        ),
        const SizedBox(height: 12),
        if (anonymousCheck?['reason'] != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Detay: ${anonymousCheck['reason']}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckItem(String title, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.cancel,
            color: isSuccess ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: isSuccess ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticSection(String title, Widget content) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
