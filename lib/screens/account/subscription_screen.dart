import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final sub = data.subscription;
    final scheme = Theme.of(context).colorScheme;
    final current = sub == null
        ? null
        : data.plans.where((p) => p.id == sub.planId).firstOrNull;

    Widget usage(String label, int used, int limit) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13.5)),
              ),
              Text(
                '$used / ${Fmt.compact(limit)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: limit > 0 ? (used / limit).clamp(0, 1).toDouble() : 0,
              minHeight: 6,
              backgroundColor: Theme.of(context).dividerColor,
            ),
          ),
        ],
      ),
    );

    return AppScaffold(
      title: context.t('subscription'),
      body: data.plans.isEmpty && sub == null
          ? EmptyState(
              icon: AppIcons.subscription,
              title: context.t('backend_required'),
              message: context.t('upgrade_request_msg'),
            )
          : PageBody(
              children: [
                if (data.isDemo) ...[
                  const DemoBanner(),
                  const SizedBox(height: 12),
                ],
                if (sub != null) ...[
                  SectionHeader(title: context.t('current_plan')),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                current == null
                                    ? sub.planId
                                    : context.t(current.nameKey),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const StatusChipActive(),
                          ],
                        ),
                        if (sub.renewsAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              Fmt.dateTime(sub.renewsAt!),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        const Divider(height: 26),
                        Text(
                          context.t('usage_limits'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (current != null) ...[
                          usage(
                            context.t('conversations_limit'),
                            sub.usedConversations,
                            current.conversations,
                          ),
                          usage(
                            context.t('ai_replies_limit'),
                            sub.usedAiReplies,
                            current.aiReplies,
                          ),
                          usage(
                            context.t('team_limit'),
                            sub.usedSeats,
                            current.teamSeats,
                          ),
                          usage(
                            context.t('products_limit'),
                            sub.usedProducts,
                            current.products,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                SectionHeader(title: context.t('plans')),
                for (final p in data.plans)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PlanCard(plan: p, isCurrent: p.id == sub?.planId),
                  ),
              ],
            ),
    );
  }
}

class StatusChipActive extends StatelessWidget {
  const StatusChipActive({super.key});
  @override
  Widget build(BuildContext context) =>
      StatusChip(label: context.t('active'), tone: Tone.success);
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrent});
  final Plan plan;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feats = [
      '${Fmt.compact(plan.conversations)} ${context.t('conversations_limit')}',
      '${Fmt.compact(plan.aiReplies)} ${context.t('ai_replies_limit')}',
      '${plan.teamSeats} ${context.t('team_limit')}',
      '${Fmt.compact(plan.products)} ${context.t('products_limit')}',
    ];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent ? scheme.primary : Theme.of(context).dividerColor,
          width: isCurrent ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t(plan.nameKey),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                if (isCurrent)
                  StatusChip(
                    label: context.t('current_plan'),
                    tone: Tone.primary,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.money(context, plan.priceMonthly),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    context.t('per_month'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final f in feats)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(AppIcons.check, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            if (!isCurrent) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => infoDialog(
                  context,
                  title: context.t('upgrade_request_title'),
                  message: context.t('upgrade_request_msg'),
                ),
                child: Text(context.t('upgrade_plan')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
