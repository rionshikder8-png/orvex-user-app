import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_chip.dart';
import '../../utils/validators.dart';

class IntegrationDetailScreen extends StatefulWidget {
  const IntegrationDetailScreen({super.key, required this.integrationId});
  final String integrationId;

  @override
  State<IntegrationDetailScreen> createState() =>
      _IntegrationDetailScreenState();
}

class _IntegrationDetailScreenState extends State<IntegrationDetailScreen> {
  final _domain = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _init = false;

  @override
  void dispose() {
    _domain.dispose();
    super.dispose();
  }

  List<String> _steps() => switch (widget.integrationId) {
    'messenger' => [
      'setup_messenger_1',
      'setup_messenger_2',
      'setup_messenger_3',
      'setup_messenger_4',
    ],
    'whatsapp' => [
      'setup_whatsapp_1',
      'setup_whatsapp_2',
      'setup_whatsapp_3',
      'setup_whatsapp_4',
    ],
    'comments' => ['setup_comments_1', 'setup_comments_2', 'setup_comments_3'],
    _ => ['setup_web_1', 'setup_web_2'],
  };

  Future<void> _connect(AppData data, IntegrationInfo i) async {
    final name = context.t(i.nameKey);
    final ok = await confirmDialog(
      context,
      title: context.t('connect_confirm_title', {'name': name}),
      message: context.t('connect_confirm_msg'),
      confirmLabel: context.t('connect'),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final res = await data.startConnect(i.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.errorKey != null) {
      await infoDialog(
        context,
        title: context.t('backend_required'),
        message: context.t(res.errorKey!),
      );
      return;
    }
    // The backend returned an authorisation URL. Opening it requires a URL
    // launcher; the URL is shown so the owner can complete the flow in a browser.
    await infoDialog(context, title: name, message: res.url!);
  }

  Future<void> _disconnect(AppData data, IntegrationInfo i) async {
    final name = context.t(i.nameKey);
    final ok = await confirmDialog(
      context,
      title: context.t('disconnect_confirm_title', {'name': name}),
      message: context.t('disconnect_confirm_msg'),
      confirmLabel: context.t('disconnect'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final err = await data.disconnect(i.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      await infoDialog(
        context,
        title: context.t('backend_required'),
        message: context.t(err),
      );
    } else {
      showSnack(context, context.t('settings_saved'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final found = data.integrations.where((i) => i.id == widget.integrationId);
    if (found.isEmpty) {
      return AppScaffold(
        title: context.t('integrations'),
        body: EmptyState(
          icon: AppIcons.integrations,
          title: context.t('no_results'),
        ),
      );
    }
    final i = found.first;
    if (!_init) {
      _domain.text = data.business.website;
      _init = true;
    }
    final scheme = Theme.of(context).colorScheme;
    final isWebsite = i.id == 'website';
    final connected = i.state == LinkState.connected;

    return AppScaffold(
      title: context.t(i.nameKey),
      body: PageBody(
        children: [
          if (data.isDemo) ...[const DemoBanner(), const SizedBox(height: 12)],
          if (!isWebsite)
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    label: context.t('status'),
                    value: '',
                    valueWidget: Chips.connection(context, i.state),
                  ),
                  if (i.accountLabel.isNotEmpty)
                    InfoRow(
                      label: context.t('workspace'),
                      value: i.accountLabel,
                    ),
                ],
              ),
            ),
          if (i.state == LinkState.error) ...[
            const SizedBox(height: 12),
            NoticeBanner(
              kind: NoticeKind.danger,
              title: context.t('connection_error'),
              message: i.errorMessage.isNotEmpty
                  ? '${i.errorMessage} ${context.t('connection_error_msg')}'
                  : context.t('connection_error_msg'),
            ),
          ],
          if (i.permissions.isNotEmpty) ...[
            const SizedBox(height: 18),
            SectionHeader(title: context.t('permission_status')),
            AppCard(
              child: Column(
                children: [
                  for (final e in i.permissions.entries)
                    InfoRow(
                      label: context.t(e.key),
                      value: '',
                      valueWidget: StatusChip(
                        label: e.value
                            ? context.t('granted')
                            : context.t('not_granted'),
                        tone: e.value ? Tone.success : Tone.neutral,
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (isWebsite) ...[
            const SizedBox(height: 4),
            Form(
              key: _form,
              child: AppTextField(
                controller: _domain,
                label: context.t('domain'),
                hint: 'example.com',
                keyboardType: TextInputType.url,
                prefixIcon: AppIcons.web,
                validator: (v) => Validators.optionalDomain(context, v),
              ),
            ),
            const SizedBox(height: 12),
            LoadingButton(
              label: context.t('save_domain'),
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                data.saveBusinessLocal(
                  data.business.copyWith(website: _domain.text.trim()),
                );
                showSnack(context, context.t('settings_saved_local'));
              },
            ),
          ],
          const SizedBox(height: 20),
          SectionHeader(title: context.t('setup_instructions')),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('setup_steps_title'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (var n = 0; n < _steps().length; n++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${n + 1}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.t(_steps()[n]),
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!isWebsite) ...[
            const SizedBox(height: 20),
            if (connected)
              OutlinedButton(
                onPressed: _busy ? null : () => _disconnect(data, i),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                ),
                child: Text(context.t('disconnect')),
              )
            else
              LoadingButton(
                label: i.state == LinkState.error
                    ? context.t('reconnect')
                    : context.t('connect'),
                loading: _busy,
                onPressed: () => _connect(data, i),
              ),
          ],
        ],
      ),
    );
  }
}
