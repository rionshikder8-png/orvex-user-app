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
import '../integrations/integrations_screen.dart';
import 'comment_detail_screen.dart';
import 'comment_rules_screen.dart';
import 'moderation_screen.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  CommentReplyStatus? _status;
  String _query = '';

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final integ = data.integrations.where((i) => i.id == 'comments');
    final info = integ.isEmpty ? null : integ.first;
    final connected = info?.state == LinkState.connected;
    final q = _query.trim().toLowerCase();
    final list = data.comments.where((c) {
      if (_status != null && c.status != _status) return false;
      if (q.isEmpty) return true;
      return c.text.toLowerCase().contains(q) ||
          c.author.toLowerCase().contains(q);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return AppScaffold(
      title: context.t('fb_comments'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(AppIcons.more),
          onSelected: (v) {
            switch (v) {
              case 'rules':
                _push(const CommentRulesScreen());
              case 'moderation':
                _push(const ModerationScreen());
              case 'logs':
                _push(const ActivityLogsScreen());
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'rules',
              child: Text(context.t('comment_rules')),
            ),
            PopupMenuItem(
              value: 'moderation',
              child: Text(context.t('moderation_settings')),
            ),
            PopupMenuItem(
              value: 'logs',
              child: Text(context.t('activity_logs')),
            ),
          ],
        ),
      ],
      body: DataGate(
        data: data,
        builder: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (data.isDemo) ...[
              const DemoBanner(),
              const SizedBox(height: 12),
            ],
            if (!connected) ...[
              NoticeBanner(
                kind: NoticeKind.warning,
                title: context.t('fb_not_connected_title'),
                message: context.t('fb_not_connected_msg'),
                trailing: TextButton(
                  onPressed: () => _push(const IntegrationsScreen()),
                  child: Text(context.t('connect')),
                ),
              ),
              const SizedBox(height: 12),
            ],
            AppCard(
              child: Column(
                children: [
                  SwitchRow(
                    title: context.t('approval_mode'),
                    subtitle: context.t('approval_mode_desc'),
                    value: data.moderation.requireApproval,
                    onChanged: (v) => data.setModeration(
                      data.moderation.copyWith(requireApproval: v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () => _push(const CommentRulesScreen()),
                    icon: const Icon(AppIcons.rule, size: 18),
                    label: Text(
                      context.t('comment_rules'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () => _push(const ActivityLogsScreen()),
                    icon: const Icon(AppIcons.history, size: 18),
                    label: Text(
                      context.t('activity_logs'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppSearchField(
              hint: context.t('search'),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            FilterChips<CommentReplyStatus?>(
              options: {
                null: context.t('all'),
                CommentReplyStatus.pending: context.t('reply_pending'),
                CommentReplyStatus.awaitingApproval: context.t(
                  'reply_approval',
                ),
                CommentReplyStatus.replied: context.t('reply_sent'),
                CommentReplyStatus.hidden: context.t('reply_hidden'),
              },
              selected: _status,
              onSelected: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 14),
            if (data.comments.isEmpty)
              SizedBox(
                height: 280,
                child: EmptyState(
                  icon: AppIcons.comments,
                  title: context.t('no_comments'),
                  message: context.t('no_comments_hint'),
                ),
              )
            else if (list.isEmpty)
              SizedBox(
                height: 240,
                child: EmptyState(
                  icon: AppIcons.search,
                  title: context.t('no_results'),
                  message: context.t('no_results_hint'),
                ),
              )
            else
              for (final c in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CommentTile(c: c),
                ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.c});
  final FbComment c;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CommentDetailScreen(commentId: c.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarBadge(text: Fmt.initials(c.author), size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                Fmt.stamp(context, c.createdAt),
                style: TextStyle(
                  fontSize: 11.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            c.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(height: 1.35),
          ),
          const SizedBox(height: 4),
          Text(
            c.postTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Chips.comment(context, c.status),
        ],
      ),
    );
  }
}
