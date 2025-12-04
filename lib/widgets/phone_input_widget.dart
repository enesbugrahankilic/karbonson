import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneInputWidget({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> {
  @override
  void initState() {
    super.initState();
    // Controller'a listener ekle
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    String text = widget.controller.text;
    
    // Sadece rakamları al
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Türk telefon numarası formatı: 05555555555 (11 rakam)
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(0, math.min(digitsOnly.length, 11));
    } else if (digitsOnly.startsWith('90')) {
      digitsOnly = digitsOnly.substring(0, math.min(digitsOnly.length, 12));
      digitsOnly = '0${digitsOnly.substring(2)}'; // +90 -> 0
    } else if (digitsOnly.isNotEmpty && digitsOnly.length <= 10) {
      // + ile başlamayan ve 10 haneli numaralar
      digitsOnly = digitsOnly.substring(0, math.min(digitsOnly.length, 10));
    }

    // Formatla
    String formatted = _formatPhoneNumber(digitsOnly);
    
    // Eğer değişiklik varsa controller'ı güncelle
    if (formatted != widget.controller.text) {
      final cursorPosition = widget.controller.selection;
      widget.controller.text = formatted;
      
      // Cursor pozisyonunu ayarla
      if (cursorPosition.isValid) {
        final newPosition = _getNewCursorPosition(
          widget.controller.text, 
          cursorPosition,
          text,
          digitsOnly
        );
        widget.controller.selection = TextSelection.collapsed(
          offset: newPosition,
        );
      }
    }

    // onChanged callback'i çağır
    widget.onChanged?.call(widget.controller.text);
  }

  String _formatPhoneNumber(String digits) {
    if (digits.isEmpty) return '';
    
    // Türk telefon formatı: 0555 555 55 55
    if (digits.startsWith('0') && digits.length >= 4) {
      if (digits.length <= 4) return digits;
      if (digits.length <= 7) return '${digits.substring(0, 4)} ${digits.substring(4)}';
      if (digits.length <= 9) return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9, 11)}';
    }
    
    return digits;
  }

  int _getNewCursorPosition(String newText, TextSelection oldSelection, String oldText, String newDigits) {
    // Basit cursor pozisyon hesaplaması
    int newPosition = oldSelection.extentOffset;
    
    // Eğer son karakter silindiyse cursor'u geri çek
    if (newText.length < oldSelection.extentOffset) {
      newPosition = newText.length;
    }
    
    return newPosition;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText ?? 'Telefon Numarası',
        hintText: widget.hintText ?? '0555 555 55 55',
        prefixIcon: const Icon(Icons.phone),
        filled: true,
        fillColor: widget.enabled 
            ? Theme.of(context).inputDecorationTheme.fillColor 
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        counterText: '', // Karakter sayacını gizle
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(14), // "0555 555 55 55" = 14 karakter
      ],
      validator: (value) {
        // Önce custom validator'ı çağır
        if (widget.validator != null) {
          final result = widget.validator!(value);
          if (result != null) return result;
        }
        
        // Varsayılan validasyon
        if (value == null || value.trim().isEmpty) {
          return 'Telefon numarası girin';
        }
        
        String digits = value.replaceAll(RegExp(r'[^\d]'), '');
        
        // Türk telefon numarası kontrolü
        if (digits.startsWith('0') && digits.length == 11) {
          // 05 ile başlayıp 11 haneli olmalı
          if (digits.startsWith('05') && 
              int.tryParse(digits[2]) != null && 
              int.parse(digits[2]) >= 0 && 
              int.parse(digits[2]) <= 9) {
            return null; // Geçerli
          }
        }
        
        // Alternatif olarak +90 formatını da kabul et
        if (digits.startsWith('90') && digits.length == 12) {
          return null; // Geçerli +90 formatı
        }
        
        return 'Geçerli bir Türk telefon numarası girin (örn: 0555 555 55 55)';
      },
      onChanged: (value) {
        // _onTextChanged zaten listener'da çağrılıyor
      },
    );
  }
}