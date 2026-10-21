import 'package:flutter/material.dart';

import '../core/brand.dart';
import '../core/l10n.dart';
import '../models/models.dart';

enum Tone { neutral, success, warning, danger, info, primary }

/// Compact status label used for orders, stock, connections and more.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = Tone.neutral,
    this.icon,
  });

  final String label;
  final Tone tone;
  final IconData? icon;

  static Color colorFor(BuildContext context, Tone tone) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (tone) {
      case Tone.success:
        return dark ? const Color(0xFF5FD3A5) : Brand.success;
      case Tone.warning:
        return dark ? const Color(0xFFF2C46B) : Brand.warning;
      case Tone.danger:
        return dark ? const Color(0xFFFF8A8A) : Brand.danger;
      case Tone.info:
        return dark ? const Color(0xFF7FB6F0) : Brand.info;
      case Tone.primary:
        return Theme.of(context).colorScheme.primary;
      case Tone.neutral:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = colorFor(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Domain-specific mappings from enums to localised, toned chips.
class Chips {
  Chips._();

  static Widget order(BuildContext c, OrderStatus s) {
    final (key, tone) = switch (s) {
      OrderStatus.pending => ('os_pending', Tone.warning),
      OrderStatus.confirmed => ('os_confirmed', Tone.info),
      OrderStatus.processing => ('os_processing', Tone.info),
      OrderStatus.shipped => ('os_shipped', Tone.primary),
      OrderStatus.delivered => ('os_delivered', Tone.success),
      OrderStatus.cancelled => ('os_cancelled', Tone.danger),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget payment(BuildContext c, PaymentStatus s) {
    final (key, tone) = switch (s) {
      PaymentStatus.paid => ('pay_paid', Tone.success),
      PaymentStatus.unpaid => ('pay_unpaid', Tone.danger),
      PaymentStatus.cod => ('pay_cod', Tone.warning),
      PaymentStatus.refunded => ('pay_refunded', Tone.neutral),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget stock(BuildContext c, StockLevel s) {
    final (key, tone) = switch (s) {
      StockLevel.inStock => ('in_stock', Tone.success),
      StockLevel.low => ('low_stock', Tone.warning),
      StockLevel.out => ('out_of_stock', Tone.danger),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget product(BuildContext c, ProductStatus s) {
    final (key, tone) = switch (s) {
      ProductStatus.published => ('status_published', Tone.success),
      ProductStatus.draft => ('status_draft', Tone.neutral),
      ProductStatus.archived => ('status_archived', Tone.neutral),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget connection(BuildContext c, LinkState s) {
    final (key, tone) = switch (s) {
      LinkState.connected => ('connected', Tone.success),
      LinkState.notConnected => ('not_connected', Tone.neutral),
      LinkState.error => ('needs_attention', Tone.danger),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget comment(BuildContext c, CommentReplyStatus s) {
    final (key, tone) = switch (s) {
      CommentReplyStatus.pending => ('reply_pending', Tone.warning),
      CommentReplyStatus.awaitingApproval => ('reply_approval', Tone.info),
      CommentReplyStatus.replied => ('reply_sent', Tone.success),
      CommentReplyStatus.hidden => ('reply_hidden', Tone.neutral),
      CommentReplyStatus.failed => ('reply_failed', Tone.danger),
    };
    return StatusChip(label: c.t(key), tone: tone);
  }

  static Widget channel(BuildContext c, Channel ch) => StatusChip(
    label: c.t(
      ch == Channel.messenger ? 'channel_messenger' : 'channel_whatsapp',
    ),
    tone: ch == Channel.messenger ? Tone.info : Tone.success,
  );

  static Widget demo(BuildContext c) => StatusChip(
    label: c.t('demo_data'),
    tone: Tone.warning,
    icon: Icons.science_outlined,
  );
}
