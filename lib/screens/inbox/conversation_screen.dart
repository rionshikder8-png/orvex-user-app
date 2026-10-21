import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/state_views.dart';
import 'customer_screen.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;
  String? _sendError;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(AppData data) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _sendError = null;
    });
    // Messages are only added to the thread when the backend confirms delivery.
    final err = await data.sendReply(widget.conversationId, text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sendError = err;
      if (err == null) _controller.clear();
    });
  }

  Future<void> _toggleHandover(AppData data, Conversation c) async {
    final takeOver = !c.humanHandled;
    final ok = await confirmDialog(
      context,
      title: takeOver
          ? context.t('handover_take')
          : context.t('handover_release'),
      message: context.t('handover_hint'),
    );
    if (!ok || !mounted) return;
    data.setHandover(c.id, takeOver);
    if (data.isDemo || !data.backendConfigured) {
      showSnack(context, context.t('status_change_local'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final matches = data.conversations.where(
      (c) => c.id == widget.conversationId,
    );
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: AppIcons.inbox, title: context.t('no_results')),
      );
    }
    final c = matches.first;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CustomerScreen(conversationId: c.id),
            ),
          ),
          child: Row(
            children: [
              AvatarBadge(text: Fmt.initials(c.customer.name), size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      context.t(
                        c.channel == Channel.messenger
                            ? 'channel_messenger'
                            : 'channel_whatsapp',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: context.t('customer_details'),
            icon: const Icon(AppIcons.info),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CustomerScreen(conversationId: c.id),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _HandoverBar(c: c, onToggle: () => _toggleHandover(data, c)),
            Expanded(
              child: c.messages.isEmpty
                  ? EmptyState(
                      icon: AppIcons.inbox,
                      title: context.t('no_conversations'),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      itemCount: c.messages.length,
                      itemBuilder: (_, i) {
                        final m = c.messages[c.messages.length - 1 - i];
                        return _Bubble(message: m);
                      },
                    ),
            ),
            if (_sendError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: NoticeBanner(
                  kind: NoticeKind.danger,
                  title: context.t('send_failed'),
                  message: context.t(_sendError!),
                ),
              ),
            _Composer(
              controller: _controller,
              sending: _sending,
              onSend: () => _send(data),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandoverBar extends StatelessWidget {
  const _HandoverBar({required this.c, required this.onToggle});
  final Conversation c;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: AdaptiveRow(
        gap: 8,
        trailingWidthHint: 170,
        leading: Icon(
          c.humanHandled ? AppIcons.handover : AppIcons.agent,
          size: 18,
          color: scheme.primary,
        ),
        content: Text(
          c.humanHandled ? context.t('handover_on') : context.t('handover_off'),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        trailing: [
          TextButton(
            onPressed: onToggle,
            child: Text(
              c.humanHandled
                  ? context.t('handover_release')
                  : context.t('handover_take'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = message.sender != SenderType.customer;
    final bg = mine ? scheme.primary : Theme.of(context).cardTheme.color;
    final fg = mine ? scheme.onPrimary : scheme.onSurface;
    final who = switch (message.sender) {
      SenderType.customer => null,
      SenderType.ai => context.t('sender_ai'),
      SenderType.agent => context.t('sender_agent'),
    };
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
            border: mine
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (who != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    who,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: fg.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              Text(message.text, style: TextStyle(color: fg, height: 1.35)),
              const SizedBox(height: 3),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  Fmt.time(message.sentAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: fg.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: context.t('type_message'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: context.t('send'),
            onPressed: sending ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
            icon: sending
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(AppIcons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
