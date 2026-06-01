/// Password validation utility with professional requirements
class PasswordValidator {
  // Private constructor to prevent instantiation
  PasswordValidator._();

  /// Minimum password length
  static const int minLength = 8;

  /// Maximum password length
  static const int maxLength = 20;

  /// Regular expressions for password requirements
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigits = RegExp(r'[0-9]');
  static final RegExp _hasSpecialChar = RegExp(
    r'[!@#$%^&*()\-_+=\[\]{};:,.<>?/|`~]',
  );

  /// Check if password is strong (meets all requirements)
  static bool isPasswordStrong(String password) {
    if (password.isEmpty) return false;
    if (password.length < minLength) return false;
    if (password.length > maxLength) return false;
    if (!_hasUppercase.hasMatch(password)) return false;
    if (!_hasLowercase.hasMatch(password)) return false;
    if (!_hasDigits.hasMatch(password)) return false;
    if (!_hasSpecialChar.hasMatch(password)) return false;

    return true;
  }

  /// Get detailed password validation error message
  static String? getPasswordError(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (password.length > maxLength) {
      return 'Password must not exceed $maxLength characters';
    }

    if (!_hasUppercase.hasMatch(password)) {
      return 'Password must contain at least one uppercase letter (A-Z)';
    }

    if (!_hasLowercase.hasMatch(password)) {
      return 'Password must contain at least one lowercase letter (a-z)';
    }

    if (!_hasDigits.hasMatch(password)) {
      return 'Password must contain at least one digit (0-9)';
    }

    if (!_hasSpecialChar.hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$%^&*()_+)';
    }

    return null; // Password is valid
  }

  /// Check individual requirements for password strength indicator
  static PasswordRequirements checkRequirements(String password) {
    return PasswordRequirements(
      minLength: password.length >= minLength,
      maxLength: password.length <= maxLength,
      hasUppercase: _hasUppercase.hasMatch(password),
      hasLowercase: _hasLowercase.hasMatch(password),
      hasDigits: _hasDigits.hasMatch(password),
      hasSpecialChar: _hasSpecialChar.hasMatch(password),
    );
  }

  /// Get password strength percentage (0-100)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= minLength && password.length <= maxLength) {
      strength += 20;
    }
    if (_hasUppercase.hasMatch(password)) strength += 16;
    if (_hasLowercase.hasMatch(password)) strength += 16;
    if (_hasDigits.hasMatch(password)) strength += 24;
    if (_hasSpecialChar.hasMatch(password)) strength += 24;

    return strength.clamp(0, 100);
  }
}

/// Model to track password requirements
class PasswordRequirements {
  final bool minLength;
  final bool maxLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigits;
  final bool hasSpecialChar;

  PasswordRequirements({
    required this.minLength,
    required this.maxLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigits,
    required this.hasSpecialChar,
  });

  /// Check if all requirements are met
  bool get allMet =>
      minLength &&
      maxLength &&
      hasUppercase &&
      hasLowercase &&
      hasDigits &&
      hasSpecialChar;

  /// Get count of met requirements
  int get metCount =>
      (minLength ? 1 : 0) +
      (maxLength ? 1 : 0) +
      (hasUppercase ? 1 : 0) +
      (hasLowercase ? 1 : 0) +
      (hasDigits ? 1 : 0) +
      (hasSpecialChar ? 1 : 0);
}
