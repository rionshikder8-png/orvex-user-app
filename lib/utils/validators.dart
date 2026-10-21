import 'package:flutter/widgets.dart';

import '../core/l10n.dart';

/// Form validators returning localised messages.
class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phone = RegExp(r'^\+?[0-9]{10,15}$');

  static String? required(BuildContext c, String? v) =>
      (v == null || v.trim().isEmpty) ? c.t('required') : null;

  static String? name(BuildContext c, String? v) =>
      (v == null || v.trim().length < 2) ? c.t('name_required') : null;

  static String? email(BuildContext c, String? v) =>
      (v == null || !_email.hasMatch(v.trim())) ? c.t('invalid_email') : null;

  static String? optionalEmail(BuildContext c, String? v) =>
      (v == null || v.trim().isEmpty) ? null : email(c, v);

  static String? password(BuildContext c, String? v) =>
      (v == null || v.length < 8) ? c.t('password_short') : null;

  static String? confirm(BuildContext c, String? v, String original) =>
      v != original ? c.t('password_mismatch') : null;

  static String? phone(BuildContext c, String? v) {
    if (v == null || v.trim().isEmpty) return c.t('required');
    final cleaned = v.replaceAll(RegExp(r'[\s\-()]'), '');
    return _phone.hasMatch(cleaned) ? null : c.t('phone_invalid');
  }

  static String? price(BuildContext c, String? v) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null) return c.t('invalid_number');
    return n > 0 ? null : c.t('invalid_price');
  }

  static String? stock(BuildContext c, String? v) {
    final n = int.tryParse((v ?? '').trim());
    return (n == null || n < 0) ? c.t('invalid_stock') : null;
  }

  static String? optionalDomain(BuildContext c, String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(
      r'^(https?://)?([a-z0-9-]+\.)+[a-z]{2,}(/.*)?$',
      caseSensitive: false,
    ).hasMatch(v.trim());
    return ok ? null : c.t('required');
  }
}
