class AppValidators {
  AppValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }
}
