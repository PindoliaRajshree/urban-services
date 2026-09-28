import 'package:flutter_test/flutter_test.dart';
import 'package:urban_services/core/utils/password_validator.dart';

// Sign-up and password reset both use PasswordValidator.getPasswordError,
// so these rules apply to both screens.
void main() {
  String? error(String password) =>
      PasswordValidator.getPasswordError(password);

  test('accepts a password meeting every rule', () {
    expect(error('Str0ng!pass'), isNull);
  });

  test('rejects each missing rule', () {
    expect(error(''), 'Password is required');
    expect(error('Sh0rt!'), contains('at least 8'));
    expect(error('Way2Long!${'x' * 20}'), contains('not exceed 20'));
    expect(error('nouppercase1!'), contains('uppercase'));
    expect(error('NOLOWERCASE1!'), contains('lowercase'));
    expect(error('NoDigits!!'), contains('digit'));
    expect(error('NoSpecial12'), contains('special'));
  });
}
