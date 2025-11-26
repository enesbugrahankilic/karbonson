// lib/utils/room_code_generator.dart
import 'dart:math';

class RoomCodeGenerator {
  static const String _digits = '0123456789';
  static final Random _random = Random();

  /// Generates a unique 4-digit room code
  static String generateRoomCode() {
    return _generateCode(4);
  }

  /// Generates a unique 4-digit access code
  static String generateAccessCode() {
    return _generateCode(4);
  }

  /// Validates if a room code is in correct format (4 digits)
  static bool isValidRoomCode(String code) {
    return code.length == 4 && code.containsOnlyDigits();
  }

  /// Validates if an access code is in correct format (4 digits)
  static bool isValidAccessCode(String code) {
    return code.length == 4 && code.containsOnlyDigits();
  }

  static String _generateCode(int length) {
    StringBuffer code = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      code.write(_digits[_random.nextInt(_digits.length)]);
    }
    
    return code.toString();
  }
}

/// Extension to validate if string contains only digits
extension on String {
  bool containsOnlyDigits() {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }
}