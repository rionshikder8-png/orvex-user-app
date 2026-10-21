import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('notifications'),
      actions: [
        if (data.unreadNotifications > 0)
          TextButton(
            onPressed: data.markNotificationsRead,
            child: Text(context.t('mark_all_read')),
          ),
      ],
      body: data.notifications.isEmpty
          ? EmptyState(
              icon: AppIcons.notifications,
              title: context.t('no_notifications'),
              message: context.t('no_notifications_hint'),
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
                    for (final n in data.notifications)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: n.read ? Colors.transparent : scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${n.body}\n${Fmt.dateTime(n.at)}',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
