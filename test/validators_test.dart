import 'package:flutter_test/flutter_test.dart';
import 'package:move_smart/core/utils/validators.dart';

/// Unit tests for the Validators class.
///
/// Member 1 requirement: "Write one Unit Test for the
/// email/password validation logic."
///
/// Run with: flutter test test/validators_test.dart
void main() {
  // ── Email Validator Tests ─────────────────────────────────
  group('Validators.email', () {
    test('returns error when email is empty', () {
      final result = Validators.email('');
      expect(result, 'Email is required');
    });

    test('returns error when email is null', () {
      final result = Validators.email(null);
      expect(result, 'Email is required');
    });

    test('returns error for email without @ symbol', () {
      final result = Validators.email('notanemail');
      expect(result, 'Enter a valid email');
    });

    test('returns error for email without domain', () {
      final result = Validators.email('user@');
      expect(result, 'Enter a valid email');
    });

    test('returns null (valid) for correct email format', () {
      final result = Validators.email('singizwa@gmail.com');
      expect(result, null); // null means valid
    });

    test('returns null (valid) for email with subdomain', () {
      final result = Validators.email('user@mail.example.com');
      expect(result, null);
    });
  });

  // ── Password Validator Tests ──────────────────────────────
  group('Validators.password', () {
    test('returns error when password is empty', () {
      final result = Validators.password('');
      expect(result, 'Password is required');
    });

    test('returns error when password is null', () {
      final result = Validators.password(null);
      expect(result, 'Password is required');
    });

    test('returns error when password is too short (under 6 chars)', () {
      final result = Validators.password('abc');
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns error for exactly 5 characters', () {
      final result = Validators.password('12345');
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns null (valid) for password with exactly 6 characters', () {
      final result = Validators.password('abc123');
      expect(result, null);
    });

    test('returns null (valid) for strong password', () {
      final result = Validators.password('MyStr0ngP@ss!');
      expect(result, null);
    });
  });

  // ── Full Name Validator Tests ─────────────────────────────
  group('Validators.fullName', () {
    test('returns error when name is empty', () {
      final result = Validators.fullName('');
      expect(result, 'Full name is required');
    });

    test('returns error when name is too short', () {
      final result = Validators.fullName('A');
      expect(result, 'Name is too short');
    });

    test('returns null (valid) for normal name', () {
      final result = Validators.fullName('John Doe');
      expect(result, null);
    });
  });
}
