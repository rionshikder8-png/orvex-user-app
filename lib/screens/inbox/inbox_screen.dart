import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/brand.dart';
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
import 'conversation_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _query = '';
  Channel? _channel;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final q = _query.trim().toLowerCase();
    final list = data.conversations.where((c) {
      if (_channel != null && c.channel != _channel) return false;
      if (q.isEmpty) return true;
      return c.customer.name.toLowerCase().contains(q) ||
          (c.last?.text.toLowerCase().contains(q) ?? false);
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      appBar: AppBar(title: Text(context.t('inbox'))),
      body: DataGate(
        data: data,
        builder: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(
                children: [
                  if (data.isDemo) ...[
                    const DemoBanner(),
                    const SizedBox(height: 10),
                  ],
                  AppSearchField(
                    hint: context.t('search_conversations'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilterChips<Channel?>(
                      options: {
                        null: context.t('all'),
                        Channel.messenger: context.t('channel_messenger'),
                        Channel.whatsapp: context.t('channel_whatsapp'),
                      },
                      selected: _channel,
                      onSelected: (v) => setState(() => _channel = v),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data.conversations.isEmpty
                  ? EmptyState(
                      icon: AppIcons.inbox,
                      title: context.t('no_conversations'),
                      message: context.t('no_conversations_hint'),
                      actionLabel: context.t('connect_channels'),
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const IntegrationsScreen(),
                        ),
                      ),
                    )
                  : list.isEmpty
                  ? EmptyState(
                      icon: AppIcons.search,
                      title: context.t('no_results'),
                      message: context.t('no_results_hint'),
                    )
                  : RefreshIndicator(
                      onRefresh: data.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _ConversationTile(c: list[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.c});
  final Conversation c;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = c.unreadCount > 0;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        context.read<AppData>().markConversationRead(c.id);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ConversationScreen(conversationId: c.id),
          ),
        );
      },
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarBadge(text: Fmt.initials(c.customer.name), size: 44),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: c.channel == Channel.messenger
                        ? Brand.messenger
                        : Brand.whatsapp,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Fmt.stamp(context, c.updatedAt),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: unread
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.last?.text ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: unread
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight: unread
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${c.unreadCount}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chips.channel(context, c.channel),
                    if (c.humanHandled)
                      StatusChip(
                        label: context.t('handover_on'),
                        tone: Tone.warning,
                        icon: AppIcons.handover,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
