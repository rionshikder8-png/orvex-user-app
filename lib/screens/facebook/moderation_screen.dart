import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final m = data.moderation;
    final integ = data.integrations.where((i) => i.id == 'comments');
    final perms = integ.isEmpty ? <String, bool>{} : integ.first.permissions;
    final connected =
        integ.isNotEmpty && integ.first.state == LinkState.connected;
    final keys = ['perm_comments', 'perm_messaging', 'perm_moderate'];
    return AppScaffold(
      title: context.t('moderation_settings'),
      body: PageBody(
        children: [
          NoticeBanner(message: context.t('not_saved_notice')),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                SwitchRow(
                  title: context.t('approval_mode'),
                  subtitle: context.t('approval_mode_desc'),
                  value: m.requireApproval,
                  onChanged: (v) =>
                      data.setModeration(m.copyWith(requireApproval: v)),
                ),
                SwitchRow(
                  title: context.t('hide_spam'),
                  value: m.hideSpam,
                  onChanged: (v) => data.setModeration(m.copyWith(hideSpam: v)),
                ),
                SwitchRow(
                  title: context.t('hide_abusive'),
                  value: m.hideAbusive,
                  onChanged: (v) =>
                      data.setModeration(m.copyWith(hideAbusive: v)),
                ),
                SwitchRow(
                  title: context.t('flag_negative'),
                  value: m.flagNegative,
                  onChanged: (v) =>
                      data.setModeration(m.copyWith(flagNegative: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: context.t('permission_status')),
          AppCard(
            child: Column(
              children: [
                for (final k in keys)
                  InfoRow(
                    label: context.t(k),
                    value: '',
                    valueWidget: StatusChip(
                      label: (connected && (perms[k] ?? false))
                          ? context.t('granted')
                          : context.t('not_granted'),
                      tone: (connected && (perms[k] ?? false))
                          ? Tone.success
                          : Tone.neutral,
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

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('activity_logs'),
      body: data.commentLogs.isEmpty
          ? EmptyState(
              icon: AppIcons.history,
              title: context.t('no_logs'),
              message: context.t('no_logs_hint'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (data.isDemo) ...[
                  const DemoBanner(),
                  const SizedBox(height: 12),
                ],
                GroupedCard(
                  children: [
                    for (final l in data.commentLogs)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        leading: Icon(
                          AppIcons.history,
                          color: scheme.primary,
                          size: 20,
                        ),
                        title: Text(
                          l.message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          Fmt.dateTime(l.at),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
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
