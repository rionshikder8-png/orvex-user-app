import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../utils/format.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';

String roleKey(TeamRole r) => switch (r) {
  TeamRole.owner => 'role_owner',
  TeamRole.manager => 'role_manager',
  TeamRole.support => 'role_support',
};

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  Future<void> _invite(BuildContext context) async {
    final email = TextEditingController();
    final form = GlobalKey<FormState>();
    TeamRole role = TeamRole.support;
    final ok = await showAppSheet<bool>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ctx.t('invite_member'),
                    style: Theme.of(ctx).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ctx.t('invite_hint'),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: email,
                    label: ctx.t('email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => Validators.email(ctx, v),
                  ),
                  const SizedBox(height: 12),
                  AppDropdown<TeamRole>(
                    label: ctx.t('role'),
                    value: role,
                    items: [
                      for (final r in [TeamRole.manager, TeamRole.support])
                        DropdownMenuItem(
                          value: r,
                          child: Text(ctx.t(roleKey(r))),
                        ),
                    ],
                    onChanged: (v) => setS(() => role = v ?? role),
                  ),
                  const SizedBox(height: 16),
                  LoadingButton(
                    label: ctx.t('invite_member'),
                    onPressed: () {
                      if (form.currentState!.validate()) {
                        Navigator.pop(ctx, true);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (ok == true && context.mounted) {
      // Listed as pending only. The backend sends the real invitation.
      context.read<AppData>().addPendingMember(
        TeamMember(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          name: email.text.trim(),
          email: email.text.trim(),
          role: role,
          pending: true,
        ),
      );
      showSnack(context, context.t('invite_hint'));
    }
    email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('team_members'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _invite(context),
        icon: const Icon(AppIcons.add),
        label: Text(context.t('invite_member')),
      ),
      body: data.team.isEmpty
          ? EmptyState(
              icon: AppIcons.team,
              title: context.t('team_members'),
              message: context.t('invite_hint'),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                if (data.isDemo) ...[
                  const DemoBanner(),
                  const SizedBox(height: 12),
                ],
                GroupedCard(
                  children: [
                    for (final m in data.team)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: AvatarBadge(
                          text: Fmt.initials(m.name),
                          size: 40,
                        ),
                        title: Text(
                          m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          m.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: m.pending
                            ? StatusChip(
                                label: context.t('reply_pending'),
                                tone: Tone.warning,
                              )
                            : StatusChip(
                                label: context.t(roleKey(m.role)),
                                tone: Tone.neutral,
                              ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
