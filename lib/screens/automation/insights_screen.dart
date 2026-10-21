import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/revenue_chart.dart';
import '../../widgets/state_views.dart';

/// Sales and order statistics derived from the data already loaded. Empty
/// states are shown when there is nothing to chart.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    final s = data.stats;

    // Units sold per product from order line items (excluding cancelled orders).
    final sold = <String, int>{};
    for (final o in data.orders.where(
      (o) => o.status != OrderStatus.cancelled,
    )) {
      for (final it in o.items) {
        sold[it.name] = (sold[it.name] ?? 0) + it.quantity;
      }
    }
    final top = sold.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSold = top.isEmpty ? 1 : top.first.value;

    final byStatus = <OrderStatus, int>{};
    for (final o in data.orders) {
      byStatus[o.status] = (byStatus[o.status] ?? 0) + 1;
    }

    final aiLimit = s.aiReplyLimit;

    return AppScaffold(
      title: context.t('insights'),
      body: PageBody(
        onRefresh: data.refresh,
        children: [
          if (data.isDemo) ...[const DemoBanner(), const SizedBox(height: 12)],
          SectionHeader(title: context.t('sales_summary')),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: context.t('revenue'),
                  value: Fmt.money(context, s.revenue),
                  caption: context.t('this_month'),
                  icon: AppIcons.chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: context.t('total_orders'),
                  value: '${s.totalOrders}',
                  icon: AppIcons.orders,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionHeader(
            title: context.t('revenue_chart'),
            trailing: Text(
              context.t('last_7_days'),
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            ),
          ),
          AppCard(child: RevenueChart(series: s.revenueSeries, height: 200)),
          const SizedBox(height: 22),
          SectionHeader(title: context.t('order_statistics')),
          if (data.orders.isEmpty)
            AppCard(
              child: EmptyState(
                compact: true,
                icon: AppIcons.orders,
                title: context.t('no_orders'),
                message: context.t('no_orders_hint'),
              ),
            )
          else
            AppCard(
              child: Column(
                children: [
                  for (final st in OrderStatus.values)
                    if ((byStatus[st] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                context.t(_statusKey(st)),
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: byStatus[st]! / data.orders.length,
                                  minHeight: 8,
                                  backgroundColor: Theme.of(context)
                                      .dividerColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${byStatus[st]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          SectionHeader(title: context.t('product_performance')),
          if (top.isEmpty)
            AppCard(
              child: EmptyState(
                compact: true,
                icon: AppIcons.products,
                title: context.t('chart_empty_title'),
                message: context.t('chart_empty_msg'),
              ),
            )
          else
            AppCard(
              child: Column(
                children: [
                  for (final e in top.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                context.t('units_sold', {'n': '${e.value}'}),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value / maxSold,
                              minHeight: 6,
                              backgroundColor: Theme.of(context).dividerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          SectionHeader(title: context.t('ai_usage')),
          AppCard(
            child: aiLimit <= 0 && s.aiReplies == 0
                ? EmptyState(
                    compact: true,
                    icon: AppIcons.agent,
                    title: context.t('chart_empty_title'),
                    message: context.t('chart_empty_msg'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.t('ai_replies'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            aiLimit > 0
                                ? '${s.aiReplies} / $aiLimit'
                                : '${s.aiReplies}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: aiLimit > 0
                              ? (s.aiReplies / aiLimit).clamp(0, 1).toDouble()
                              : 0,
                          minHeight: 8,
                          backgroundColor: Theme.of(context).dividerColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

String _statusKey(OrderStatus s) => switch (s) {
  OrderStatus.pending => 'os_pending',
  OrderStatus.confirmed => 'os_confirmed',
  OrderStatus.processing => 'os_processing',
  OrderStatus.shipped => 'os_shipped',
  OrderStatus.delivered => 'os_delivered',
  OrderStatus.cancelled => 'os_cancelled',
};
