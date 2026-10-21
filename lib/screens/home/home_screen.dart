import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../services/auth_controller.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/revenue_chart.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../account/notifications_screen.dart';
import '../ai/ai_agent_screen.dart';
import '../automation/automation_screen.dart';
import '../automation/insights_screen.dart';
import '../courier/courier_screen.dart';
import '../facebook/comments_screen.dart';
import '../integrations/integrations_screen.dart';
import '../inbox/conversation_screen.dart';
import '../orders/order_detail_screen.dart';
import '../products/product_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Switches the bottom navigation tab (1 inbox, 2 orders, 3 products...).
  final ValueChanged<int> onOpenTab;

  String _greeting(BuildContext c) {
    final h = DateTime.now().hour;
    if (h < 12) return c.t('greeting_morning');
    if (h < 17) return c.t('greeting_afternoon');
    return c.t('greeting_evening');
  }

  void _push(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final auth = context.watch<AuthController>();
    final scheme = Theme.of(context).colorScheme;
    final bizName = data.business.name.isNotEmpty
        ? data.business.name
        : (auth.user?.name ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(context),
              style: TextStyle(
                fontSize: 12.5,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(bizName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.t('notifications'),
            onPressed: () => _push(context, const NotificationsScreen()),
            icon: Badge(
              isLabelVisible: data.unreadNotifications > 0,
              label: Text('${data.unreadNotifications}'),
              child: const Icon(AppIcons.notifications),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: DataGate(
        data: data,
        builder: (_) => PageBody(
          onRefresh: data.refresh,
          children: [
            if (data.isDemo) ...[
              const DemoBanner(),
              const SizedBox(height: 14),
            ],
            _AgentCard(
              data: data,
              onManage: () => _push(context, const AiAgentScreen()),
            ),
            const SizedBox(height: 12),
            _ChannelsCard(
              data: data,
              onTap: () => _push(context, const IntegrationsScreen()),
            ),
            const SizedBox(height: 12),
            _TwoColumn(
              children: [
                StatTile(
                  label: context.t('total_orders'),
                  value: '${data.stats.totalOrders}',
                  icon: AppIcons.orders,
                  onTap: () => onOpenTab(2),
                ),
                StatTile(
                  label: context.t('pending_orders'),
                  value: '${data.stats.pendingOrders}',
                  icon: AppIcons.history,
                  onTap: () => onOpenTab(2),
                ),
                StatTile(
                  label: context.t('revenue'),
                  value: Fmt.money(context, data.stats.revenue),
                  caption: context.t('this_month'),
                  icon: AppIcons.chart,
                  onTap: () => _push(context, const InsightsScreen()),
                ),
                StatTile(
                  label: context.t('ai_usage'),
                  value: data.stats.aiReplyLimit > 0
                      ? '${data.stats.aiReplies}/${Fmt.compact(data.stats.aiReplyLimit)}'
                      : '${data.stats.aiReplies}',
                  caption: context.t('ai_replies'),
                  icon: AppIcons.agent,
                  onTap: () => _push(context, const AiAgentScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(title: context.t('quick_actions')),
            _QuickActions(onOpenTab: onOpenTab),
            const SizedBox(height: 22),
            SectionHeader(
              title: context.t('revenue_chart'),
              trailing: Text(
                context.t('last_7_days'),
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            AppCard(child: RevenueChart(series: data.stats.revenueSeries)),
            const SizedBox(height: 22),
            SectionHeader(
              title: context.t('recent_conversations'),
              actionLabel: context.t('view_all'),
              onAction: () => onOpenTab(1),
            ),
            if (data.conversations.isEmpty)
              AppCard(
                child: EmptyState(
                  compact: true,
                  icon: AppIcons.inbox,
                  title: context.t('no_conversations'),
                  message: context.t('no_conversations_hint'),
                ),
              )
            else
              GroupedCard(
                children: [
                  for (final c
                      in (List<Conversation>.of(
                            data.conversations,
                          )..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
                          .take(3))
                    _ConversationRow(
                      c: c,
                      onTap: () => _push(
                        context,
                        ConversationScreen(conversationId: c.id),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 22),
            SectionHeader(
              title: context.t('recent_orders'),
              actionLabel: context.t('view_all'),
              onAction: () => onOpenTab(2),
            ),
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
              GroupedCard(
                children: [
                  for (final o in data.orders.take(3))
                    _OrderRow(
                      o: o,
                      onTap: () =>
                          _push(context, OrderDetailScreen(orderId: o.id)),
                    ),
                ],
              ),
            const SizedBox(height: 22),
            SectionHeader(title: context.t('low_stock_alerts')),
            if (data.lowStockProducts.isEmpty)
              AppCard(
                child: Text(
                  context.t('no_low_stock'),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else
              GroupedCard(
                children: [
                  for (final p in data.lowStockProducts.take(4))
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        p.stock <= 0
                            ? context.t('out_of_stock')
                            : context.t('units_left', {'n': '${p.stock}'}),
                      ),
                      trailing: Chips.stock(context, p.stockLevel),
                      onTap: () =>
                          _push(context, ProductFormScreen(productId: p.id)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({required this.data, required this.onManage});
  final AppData data;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = data.agent.enabled;
    return AppCard(
      onTap: onManage,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(AppIcons.agent, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('agent_status'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  on ? context.t('agent_active') : context.t('agent_paused'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          StatusChip(
            label: on ? context.t('active') : context.t('inactive'),
            tone: on ? Tone.success : Tone.neutral,
          ),
          const SizedBox(width: 6),
          const Icon(AppIcons.chevron, size: 20),
        ],
      ),
    );
  }
}

class _ChannelsCard extends StatelessWidget {
  const _ChannelsCard({required this.data, required this.onTap});
  final AppData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final channels = data.integrations.where((i) => i.id != 'website').toList();
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t('channels'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Flexible(
                child: Text(
                  context.t('channels_summary', {
                    'n': '${data.connectedChannels}',
                    'total': '${data.totalChannels}',
                  }),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in channels)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 72,
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context.t(i.nameKey),
                        style: const TextStyle(fontSize: 13),
                      ),
                      Chips.connection(context, i.state),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  void _push(BuildContext c, Widget w) =>
      Navigator.push(c, MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (
        AppIcons.add,
        context.t('qa_add_product'),
        () => _push(context, const ProductFormScreen()),
      ),
      (
        AppIcons.agent,
        context.t('qa_ai_agent'),
        () => _push(context, const AiAgentScreen()),
      ),
      (
        AppIcons.comments,
        context.t('qa_comments'),
        () => _push(context, const CommentsScreen()),
      ),
      (
        AppIcons.courier,
        context.t('qa_couriers'),
        () => _push(context, const CourierScreen()),
      ),
      (
        AppIcons.insights,
        context.t('qa_insights'),
        () => _push(context, const InsightsScreen()),
      ),
      (
        AppIcons.automation,
        context.t('qa_automation'),
        () => _push(context, const AutomationScreen()),
      ),
      (
        AppIcons.integrations,
        context.t('qa_integrations'),
        () => _push(context, const IntegrationsScreen()),
      ),
      (AppIcons.orders, context.t('qa_new_order'), () => onOpenTab(2)),
    ];
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        const spacing = 8.0;
        final w = (box.maxWidth - spacing * 3) / 4;
        return Wrap(
          spacing: spacing,
          runSpacing: 14,
          children: [
            for (final it in items)
              SizedBox(
                width: w,
                child: InkWell(
                  onTap: it.$3,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Icon(it.$1, color: scheme.primary, size: 22),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        it.$2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.c, required this.onTap});
  final Conversation c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AvatarBadge(text: Fmt.initials(c.customer.name), size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.last?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.stamp(context, c.updatedAt),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Chips.channel(context, c.channel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.o, required this.onTap});
  final Order o;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${o.number}  ${o.customerName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Fmt.money(context, o.total),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chips.order(context, o.status),
          ],
        ),
      ),
    );
  }
}

/// Lays children out in two equal columns; each row is as tall as its tallest
/// tile, so nothing overflows with large text or long Bangla labels.
class _TwoColumn extends StatelessWidget {
  const _TwoColumn({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 12));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
