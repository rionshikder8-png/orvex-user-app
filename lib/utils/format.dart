import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../core/l10n.dart';

class Fmt {
  Fmt._();

  /// Formats a BDT amount, e.g. "৳ 1,850" with locale digits kept ASCII for
  /// readability in tables.
  static String money(BuildContext context, double v) {
    final f = NumberFormat.decimalPattern('en');
    final s = v == v.roundToDouble()
        ? f.format(v.round())
        : v.toStringAsFixed(2);
    return '${context.t('currency')} $s';
  }

  static String compact(num v) => NumberFormat.compact(locale: 'en').format(v);

  static String time(DateTime d) => DateFormat('h:mm a', 'en').format(d);

  /// Relative stamp: time today, "Yesterday", or a short date.
  static String stamp(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff <= 0) return time(d);
    if (diff == 1) return context.t('yesterday');
    return DateFormat('d MMM', 'en').format(d);
  }

  static String dateTime(DateTime d) =>
      DateFormat('d MMM, h:mm a', 'en').format(d);

  static String initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
