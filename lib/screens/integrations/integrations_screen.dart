import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import 'integration_detail_screen.dart';

IconData integrationIcon(String id) => switch (id) {
  'messenger' => AppIcons.messenger,
  'whatsapp' => AppIcons.phone,
  'comments' => AppIcons.comments,
  _ => AppIcons.web,
};

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('integrations'),
      body: DataGate(
        data: data,
        builder: (_) => PageBody(
          onRefresh: data.refresh,
          children: [
            if (data.isDemo) ...[
              const DemoBanner(),
              const SizedBox(height: 12),
            ],
            NoticeBanner(message: context.t('backend_confirmation_needed')),
            const SizedBox(height: 14),
            for (final i in data.integrations)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          IntegrationDetailScreen(integrationId: i.id),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          integrationIcon(i.id),
                          color: scheme.primary,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t(i.nameKey),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (i.accountLabel.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  i.accountLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (i.id != 'website')
                        Flexible(
                          flex: 0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 110),
                            child: Chips.connection(context, i.state),
                          ),
                        ),
                      const SizedBox(width: 2),
                      const Icon(AppIcons.chevron, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
