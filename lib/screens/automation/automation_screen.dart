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
import 'insights_screen.dart';

String triggerKey(RuleTrigger t) => switch (t) {
  RuleTrigger.keyword => 'trigger_keyword',
  RuleTrigger.newOrder => 'trigger_new_order',
  RuleTrigger.lowStock => 'trigger_low_stock',
  RuleTrigger.noReply => 'trigger_no_reply',
};

String ruleActionKey(RuleAction a) => switch (a) {
  RuleAction.aiReply => 'act_ai_reply',
  RuleAction.notifyTeam => 'act_notify_team',
  RuleAction.tagConversation => 'act_tag',
  RuleAction.handover => 'act_handover',
};

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('automation'),
      actions: [
        IconButton(
          tooltip: context.t('insights'),
          icon: const Icon(AppIcons.insights),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const InsightsScreen()),
          ),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const AutomationEditor()),
        ),
        icon: const Icon(AppIcons.add),
        label: Text(context.t('create_rule')),
      ),
      body: data.automations.isEmpty
          ? EmptyState(
              icon: AppIcons.automation,
              title: context.t('no_rules'),
              message: context.t('no_rules_hint'),
              actionLabel: context.t('create_rule'),
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AutomationEditor(),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              children: [
                if (data.isDemo) ...[
                  const DemoBanner(),
                  const SizedBox(height: 12),
                ],
                for (final r in data.automations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => AutomationEditor(ruleId: r.id),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Switch(
                                value: r.enabled,
                                onChanged: (v) => data.upsertAutomation(
                                  r.copyWith(enabled: v),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${context.t('trigger')}: ${context.t(triggerKey(r.trigger))}',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.t('action')}: ${context.t(ruleActionKey(r.action))}',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StatusChip(
                            label: r.enabled
                                ? context.t('enabled')
                                : context.t('disabled'),
                            tone: r.enabled ? Tone.success : Tone.neutral,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class AutomationEditor extends StatefulWidget {
  const AutomationEditor({super.key, this.ruleId});
  final String? ruleId;

  @override
  State<AutomationEditor> createState() => _AutomationEditorState();
}

class _AutomationEditorState extends State<AutomationEditor> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _value = TextEditingController();
  RuleTrigger _trigger = RuleTrigger.keyword;
  RuleAction _action = RuleAction.aiReply;
  bool _enabled = true;
  AutomationRule? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.ruleId != null) {
      final l = context.read<AppData>().automations.where(
        (r) => r.id == widget.ruleId,
      );
      if (l.isNotEmpty) {
        _existing = l.first;
        _name.text = _existing!.name;
        _value.text = _existing!.conditionValue;
        _trigger = _existing!.trigger;
        _action = _existing!.action;
        _enabled = _existing!.enabled;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppData>().upsertAutomation(
      AutomationRule(
        id: _existing?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: _name.text.trim(),
        trigger: _trigger,
        action: _action,
        conditionValue: _value.text.trim(),
        enabled: _enabled,
      ),
    );
    showSnack(context, context.t('settings_saved_local'));
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: context.t('delete_rule_title'),
      message: context.t('delete_rule_msg'),
      confirmLabel: context.t('delete'),
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<AppData>().removeAutomation(_existing!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final needsValue = _trigger != RuleTrigger.newOrder;
    return AppScaffold(
      title: _existing == null
          ? context.t('create_rule')
          : context.t('edit_rule'),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            NoticeBanner(message: context.t('not_saved_notice')),
            const SizedBox(height: 16),
            AppTextField(
              controller: _name,
              label: context.t('rule_name'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.t('required')
                  : null,
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.t('rule_conditions')),
            AppDropdown<RuleTrigger>(
              label: context.t('trigger'),
              value: _trigger,
              items: [
                for (final t in RuleTrigger.values)
                  DropdownMenuItem(
                    value: t,
                    child: Text(
                      context.t(triggerKey(t)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _trigger = v ?? _trigger),
            ),
            if (needsValue) ...[
              const SizedBox(height: 14),
              AppTextField(
                controller: _value,
                label: context.t('condition_value'),
                hint: context.t('condition_value_hint'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.t('required')
                    : null,
              ),
            ],
            const SizedBox(height: 18),
            SectionHeader(title: context.t('rule_actions')),
            AppDropdown<RuleAction>(
              label: context.t('action'),
              value: _action,
              items: [
                for (final a in RuleAction.values)
                  DropdownMenuItem(
                    value: a,
                    child: Text(
                      context.t(ruleActionKey(a)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _action = v ?? _action),
            ),
            const SizedBox(height: 8),
            SwitchRow(
              title: context.t('enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 16),
            LoadingButton(label: context.t('save'), onPressed: _save),
            if (_existing != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(context.t('delete')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
