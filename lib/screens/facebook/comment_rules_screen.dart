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

String commentActionKey(CommentAction a) => switch (a) {
  CommentAction.publicReply => 'action_public_reply',
  CommentAction.privateMessage => 'action_private_message',
  CommentAction.both => 'action_both',
};

class CommentRulesScreen extends StatelessWidget {
  const CommentRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    return AppScaffold(
      title: context.t('comment_rules'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CommentRuleEditor()),
        ),
        icon: const Icon(AppIcons.add),
        label: Text(context.t('new_rule')),
      ),
      body: data.commentRules.isEmpty
          ? EmptyState(
              icon: AppIcons.rule,
              title: context.t('no_rules'),
              message: context.t('no_rules_hint'),
              actionLabel: context.t('new_rule'),
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const CommentRuleEditor(),
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
                for (final r in data.commentRules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CommentRuleEditor(ruleId: r.id),
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
                                onChanged: (v) => data.upsertCommentRule(
                                  r.copyWith(enabled: v),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final k in r.keywords)
                                StatusChip(label: k, tone: Tone.primary),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.t(commentActionKey(r.action)),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                            ),
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

class CommentRuleEditor extends StatefulWidget {
  const CommentRuleEditor({super.key, this.ruleId});
  final String? ruleId;

  @override
  State<CommentRuleEditor> createState() => _CommentRuleEditorState();
}

class _CommentRuleEditorState extends State<CommentRuleEditor> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _keywords = TextEditingController();
  final _template = TextEditingController();
  CommentAction _action = CommentAction.publicReply;
  bool _enabled = true;
  CommentRule? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.ruleId != null) {
      final l = context.read<AppData>().commentRules.where(
        (r) => r.id == widget.ruleId,
      );
      if (l.isNotEmpty) {
        _existing = l.first;
        _name.text = _existing!.name;
        _keywords.text = _existing!.keywords.join(', ');
        _template.text = _existing!.replyTemplate;
        _action = _existing!.action;
        _enabled = _existing!.enabled;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _keywords.dispose();
    _template.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final kws = _keywords.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    context.read<AppData>().upsertCommentRule(
      CommentRule(
        id: _existing?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}',
        name: _name.text.trim(),
        keywords: kws,
        action: _action,
        replyTemplate: _template.text.trim(),
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
    context.read<AppData>().removeCommentRule(_existing!.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _existing == null ? context.t('new_rule') : context.t('edit_rule'),
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
              validator: (v) => Validators2.req(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _keywords,
              label: context.t('keywords'),
              hint: context.t('keywords_hint'),
              textInputAction: TextInputAction.next,
              validator: (v) => Validators2.req(context, v),
            ),
            const SizedBox(height: 14),
            AppDropdown<CommentAction>(
              label: context.t('action'),
              value: _action,
              items: [
                for (final a in CommentAction.values)
                  DropdownMenuItem(
                    value: a,
                    child: Text(
                      context.t(commentActionKey(a)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _action = v ?? _action),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _template,
              label: context.t('reply_template'),
              maxLines: 4,
              minLines: 3,
              keyboardType: TextInputType.multiline,
              validator: (v) => Validators2.req(context, v),
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

/// Tiny local alias to avoid importing the full validators file twice.
class Validators2 {
  static String? req(BuildContext c, String? v) =>
      (v == null || v.trim().isEmpty) ? c.t('required') : null;
}
