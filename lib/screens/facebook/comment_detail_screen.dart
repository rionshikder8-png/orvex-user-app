import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

class CommentDetailScreen extends StatefulWidget {
  const CommentDetailScreen({super.key, required this.commentId});
  final String commentId;

  @override
  State<CommentDetailScreen> createState() => _CommentDetailScreenState();
}

class _CommentDetailScreenState extends State<CommentDetailScreen> {
  final _reply = TextEditingController();
  bool _init = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  /// Facebook operations need the backend, Meta permissions and an approved app.
  /// Without those nothing is posted; the UI says so explicitly.
  Future<void> _post(
    AppData data,
    FbComment c, {
    required bool privateMessage,
  }) async {
    final text = _reply.text.trim();
    if (text.isEmpty) {
      showSnack(context, context.t('required'), error: true);
      return;
    }
    if (data.isDemo || !data.backendConfigured) {
      await infoDialog(
        context,
        title: context.t('backend_required'),
        message:
            '${context.t('backend_not_configured')}\n\n${context.t('private_reply_hint')}',
      );
      return;
    }
    // With a backend, the API call is made by DataApi; the comment status only
    // changes after the backend confirms.
    showSnack(context, context.t('backend_required'));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final found = data.comments.where((c) => c.id == widget.commentId);
    if (found.isEmpty) {
      return AppScaffold(
        title: context.t('comment_details'),
        body: EmptyState(
          icon: AppIcons.comments,
          title: context.t('no_results'),
        ),
      );
    }
    final c = found.first;
    if (!_init) {
      _reply.text = c.draftReply;
      _init = true;
    }
    final scheme = Theme.of(context).colorScheme;
    final perms = data.integrations.where((i) => i.id == 'comments');
    final granted =
        perms.isNotEmpty && perms.first.state == LinkState.connected;

    return AppScaffold(
      title: context.t('comment_details'),
      body: PageBody(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarBadge(text: Fmt.initials(c.author), size: 40),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.author,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            Fmt.dateTime(c.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Chips.comment(context, c.status)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  c.text,
                  style: const TextStyle(height: 1.45, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Text(
                  c.postTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (!granted)
            NoticeBanner(
              kind: NoticeKind.warning,
              title: context.t('permission_status'),
              message: context.t('fb_not_connected_msg'),
            ),
          if (!granted) const SizedBox(height: 14),
          if (c.status == CommentReplyStatus.replied && c.reply.isNotEmpty) ...[
            SectionHeader(title: context.t('public_reply')),
            AppCard(child: Text(c.reply, style: const TextStyle(height: 1.45))),
          ] else if (c.status != CommentReplyStatus.hidden) ...[
            SectionHeader(title: context.t('public_reply')),
            AppTextField(
              controller: _reply,
              label: context.t('write_reply'),
              maxLines: 4,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 6),
            Text(
              context.t('private_reply_hint'),
              style: TextStyle(
                fontSize: 12.5,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            if (c.status == CommentReplyStatus.awaitingApproval &&
                data.moderation.requireApproval) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        data.updateComment(
                          c.copyWith(
                            status: CommentReplyStatus.pending,
                            draftReply: '',
                          ),
                        );
                        showSnack(context, context.t('status_change_local'));
                      },
                      child: Text(context.t('reject')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _post(data, c, privateMessage: false),
                      child: Text(context.t('approve')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ] else
              FilledButton.icon(
                onPressed: () => _post(data, c, privateMessage: false),
                icon: const Icon(AppIcons.comments, size: 18),
                label: Text(context.t('reply_publicly')),
              ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _post(data, c, privateMessage: true),
              icon: const Icon(AppIcons.messenger, size: 18),
              label: Text(context.t('send_private_message')),
            ),
          ] else
            NoticeBanner(message: context.t('reply_hidden')),
        ],
      ),
    );
  }
}
