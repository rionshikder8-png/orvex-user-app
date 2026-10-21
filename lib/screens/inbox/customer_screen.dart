import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../orders/order_detail_screen.dart';

/// Customer details plus orders linked by phone number.
class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key, required this.conversationId});
  final String conversationId;

  String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final matches = data.conversations.where((x) => x.id == conversationId);
    if (matches.isEmpty) {
      return AppScaffold(
        title: context.t('customer_details'),
        body: EmptyState(icon: AppIcons.inbox, title: context.t('no_results')),
      );
    }
    final c = matches.first;
    final cust = c.customer;
    final related = data.orders
        .where(
          (o) =>
              cust.phone.isNotEmpty && _digits(o.phone) == _digits(cust.phone),
        )
        .toList();
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: context.t('customer_details'),
      body: PageBody(
        children: [
          Center(child: AvatarBadge(text: Fmt.initials(cust.name), size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              cust.name,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          Center(child: Chips.channel(context, c.channel)),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  label: context.t('phone'),
                  value: cust.phone.isEmpty ? '-' : cust.phone,
                ),
                if (cust.email.isNotEmpty)
                  InfoRow(label: context.t('email'), value: cust.email),
                InfoRow(
                  label: context.t('orders_count'),
                  value: '${cust.totalOrders}',
                ),
                InfoRow(
                  label: context.t('total_spent'),
                  value: Fmt.money(context, cust.totalSpent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(title: context.t('related_orders')),
          if (related.isEmpty)
            AppCard(
              child: Text(
                context.t('no_related_orders'),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          else
            GroupedCard(
              children: [
                for (final o in related)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      o.number,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(Fmt.money(context, o.total)),
                    trailing: Chips.order(context, o.status),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => OrderDetailScreen(orderId: o.id),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
