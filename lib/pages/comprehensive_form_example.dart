// lib/pages/comprehensive_form_example.dart
// Complete example showing email validation, network monitoring, and form submission

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import '../services/connectivity_service.dart';
import '../services/form_validation_service.dart';
import '../widgets/network_status_widget.dart';
import '../widgets/form_field_validator.dart' as form_validator;

class ComprehensiveFormExample extends StatefulWidget {
  const ComprehensiveFormExample({super.key});

  @override
  State<ComprehensiveFormExample> createState() => _ComprehensiveFormExampleState();
}

class _ComprehensiveFormExampleState extends State<ComprehensiveFormExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  
  // Enhanced connectivity service with continuous monitoring
  final ConnectivityService _connectivityService = ConnectivityService();
  
  // Form validation service
  late final FormValidationService _validationService;
  
  // Stream subscriptions for continuous monitoring
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _validationService = FormValidationService(
      connectivityService: _connectivityService,
    );
    _initializeConnectivityMonitoring();
  }

  void _initializeConnectivityMonitoring() {
    // Initialize continuous connectivity monitoring
    _connectivityService.initialize();
    
    // Listen to connectivity state changes
    _connectivitySubscription = _connectivityService.connectivityStateStream
        .listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(bool isConnected) {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild to update UI state
      });
      
      // Show appropriate message based on connectivity change
      if (isConnected) {
        // Coming back online
        if (kDebugMode) {
          debugPrint('FormExample: Back online - can retry submission');
        }
      } else {
        // Going offline
        if (kDebugMode) {
          debugPrint('FormExample: Gone offline - submission blocked');
        }
      }
    }
  }

  /// Enhanced form submission handler with comprehensive validation
  Future<void> _handleFormSubmission() async {
    await _validationService.validateAndSubmit(
      formKey: _formKey,
      submissionFunction: _executeFormSubmission,
      onValidationFailure: () {
        _validationService.showValidationError(context);
        if (kDebugMode) {
          debugPrint('FormExample: Validation failed');
        }
      },
      onNetworkFailure: () {
        _validationService.showOfflineMessage(context);
        if (kDebugMode) {
          debugPrint('FormExample: Network check failed - offline');
        }
      },
      onSubmissionSuccess: () {
        _validationService.showSuccessMessage(context, 'Form başarıyla gönderildi!');
        if (kDebugMode) {
          debugPrint('FormExample: Submission successful');
        }
      },
      onSubmissionError: (error) {
        _validationService.showErrorMessage(context, 'Hata: $error');
        if (kDebugMode) {
          debugPrint('FormExample: Submission error: $error');
        }
      },
    );
  }

  /// The actual form submission logic
  Future<void> _executeFormSubmission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call or Firebase operation
      await Future.delayed(const Duration(seconds: 2));
      
      if (kDebugMode) {
        debugPrint('FormExample: Form data submitted');
        debugPrint('Email: ${_emailController.text.trim()}');
      }
      
      // Clear form on success
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Retry connectivity and form submission
  Future<void> _handleRetry() async {
    final isReconnected = await _connectivityService.retryConnectivity();
    
    if (isReconnected) {
      if (kDebugMode) {
        debugPrint('FormExample: Reconnected - retrying form submission');
      }
      await _handleFormSubmission();
    } else {
      _validationService.showErrorMessage(
        context, 
        'Hala çevrimdışısınız. Lütfen internet bağlantınızı kontrol edin.'
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _connectivityService.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kapsamlı Form Örneği'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Network Status Widget
            NetworkStatusWidget(
              connectivityService: _connectivityService,
              onRetry: _handleRetry,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            
            const SizedBox(height: 20),
            
            // Form Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Icon(
                      Icons.email,
                      size: 48,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'E-posta Form Örneği',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'E-posta validasyonu, ağ kontrolü ve sürekli bağlantı izleme',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field with Enhanced Validation
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'E-posta Adresi',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorMaxLines: 2,
                            ),
                            validator: form_validator.FormFieldValidator.validateEmail,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Şifre Tekrar',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre tekrarı gerekli';
                              }
                              if (value != _passwordController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: (_isLoading || !isConnected) ? null : _handleFormSubmission,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isLoading ? 'Gönderiliyor...' : 'Gönder'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: isConnected ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Status Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistem Durumu:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Bağlantı Durumu:',
                      isConnected ? 'Çevrimiçi' : 'Çevrimdışı',
                      isConnected ? Colors.green : Colors.red,
                    ),
                    _buildStatusRow(
                      'Form Validasyonu:',
                      'Aktif (E-posta Regex + Boşluk Kontrolü)',
                      Colors.blue,
                    ),
                    _buildStatusRow(
                      'Ağ İzleme:',
                      'Sürekli (Real-time)',
                      Colors.blue,
                    ),
                    _buildStatusRow(
                      'Hata Mesajları:',
                      'Türkçe (Offline: "Çevrimdışı durumdasınız...")',
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}