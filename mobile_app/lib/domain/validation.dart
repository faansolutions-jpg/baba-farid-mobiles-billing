/// Input validators for Baba Farid Mobiles.
///
/// Each validator returns `null` when the value is valid, or a short
/// English error message when it is not. The `isValid*` boolean helpers
/// are for use in pure-logic code (rules, repositories).
library;

import 'rules.dart';

/// Pakistani mobile number.
///
/// Accepts: `03XX-XXXXXXX`, `03XXXXXXXXX`, `+92 3XX XXXXXXX`,
/// `923XXXXXXXXX`. Spaces and a single `-` are ignored.
bool isValidPhone(String? value) {
  if (value == null) return false;
  final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
  return RegExp(r'^(\+92|92|0)?3\d{9}$').hasMatch(cleaned);
}

/// Pakistani CNIC: `xxxxx-xxxxxxx-x`.
bool isValidCnic(String? value) {
  if (value == null) return false;
  return RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(value.trim());
}

/// IMEI: 15 digits with a valid Luhn check digit (see [validateImei]).
bool isValidImei(String? value) {
  if (value == null) return false;
  return validateImei(value);
}

/// Normalises a Pakistani phone to `03XXXXXXXXX` form, or returns null
/// when the input is not a valid Pakistani mobile.
String? normalizePhone(String? value) {
  if (!isValidPhone(value)) return null;
  var cleaned = value!.replaceAll(RegExp(r'[\s-]'), '');
  if (cleaned.startsWith('+92')) cleaned = '0${cleaned.substring(3)}';
  if (cleaned.startsWith('92')) cleaned = '0${cleaned.substring(2)}';
  return cleaned;
}

class Validators {
  const Validators._();

  /// Value must be present and non-blank.
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Pakistani mobile number (see [isValidPhone]).
  static String? phone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }
    if (!isValidPhone(value)) return 'Enter a valid Pakistani mobile (03XX-XXXXXXX)';
    return null;
  }

  /// Pakistani CNIC `xxxxx-xxxxxxx-x`. Optional unless [required].
  static String? cnic(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'CNIC is required' : null;
    }
    if (!isValidCnic(value)) return 'Enter CNIC as xxxxx-xxxxxxx-x';
    return null;
  }

  /// Amount must be a positive whole-PKR integer (> 0).
  static String? positiveAmount(int? value, {String field = 'Amount'}) {
    if (value == null) return '$field is required';
    if (value <= 0) return '$field must be greater than 0';
    return null;
  }

  /// Amount must be zero or more (whole PKR).
  static String? nonNegativeAmount(int? value, {String field = 'Amount'}) {
    if (value == null) return '$field is required';
    if (value < 0) return '$field cannot be negative';
    return null;
  }

  /// IMEI: 15 digits with a valid check digit.
  static String? imei(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'IMEI is required' : null;
    }
    if (!isValidImei(value)) return 'Enter a valid 15-digit IMEI';
    return null;
  }

  /// Quantity must be a positive integer.
  static String? quantity(int? value) {
    if (value == null) return 'Quantity is required';
    if (value <= 0) return 'Quantity must be at least 1';
    return null;
  }

  /// Simple email check (optional field unless [required]).
  static String? email(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email is required' : null;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
