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
import '../onboarding/onboarding_screen.dart' show kTones;
import 'agent_test_screen.dart';
import 'knowledge_screen.dart';

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _instructions;
  late AgentSettings _s;

  @override
  void initState() {
    super.initState();
    _s = context.read<AppData>().agent;
    _name = TextEditingController(text: _s.name);
    _instructions = TextEditingController(text: _s.instructions);
  }

  @override
  void dispose() {
    _name.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _push(Widget w) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => w));

  void _save() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AppData>().saveAgentLocal(
      _s.copyWith(
        name: _name.text.trim(),
        instructions: _instructions.text.trim(),
      ),
    );
    showSnack(context, context.t('settings_saved_local'));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppData>();
    final scheme = Theme.of(context).colorScheme;
    final sub = data.subscription;
    final limit = data.stats.aiReplyLimit;
    final used = data.stats.aiReplies;

    return AppScaffold(
      title: context.t('ai_agent'),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            if (data.isDemo) ...[
              const DemoBanner(),
              const SizedBox(height: 12),
            ],
            NoticeBanner(
              kind: NoticeKind.warning,
              title: context.t('backend_required'),
              message: context.t('agent_needs_backend'),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(AppIcons.agent, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusChip(
                              label: _s.enabled
                                  ? context.t('active')
                                  : context.t('inactive'),
                              tone: _s.enabled ? Tone.success : Tone.neutral,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SwitchRow(
                    title: context.t('agent_enabled'),
                    subtitle: context.t('agent_enabled_desc'),
                    value: _s.enabled,
                    onChanged: (v) =>
                        setState(() => _s = _s.copyWith(enabled: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(title: context.t('agent_settings')),
            AppTextField(
              controller: _name,
              label: context.t('agent_name'),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.t('required')
                  : null,
            ),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: context.t('primary_language'),
              value: _s.language,
              items: [
                DropdownMenuItem(
                  value: 'bn',
                  child: Text(context.t('lang_bn')),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text(context.t('lang_en')),
                ),
              ],
              onChanged: (v) => setState(() => _s = _s.copyWith(language: v)),
            ),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: context.t('response_tone'),
              value: kTones.contains(_s.tone) ? _s.tone : kTones.first,
              items: [
                for (final t in kTones)
                  DropdownMenuItem(value: t, child: Text(context.t(t))),
              ],
              onChanged: (v) => setState(() => _s = _s.copyWith(tone: v)),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _instructions,
              label: context.t('business_instructions'),
              hint: context.t('business_instructions_hint'),
              maxLines: 6,
              minLines: 4,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            SectionHeader(title: context.t('automation_prefs')),
            AppCard(
              child: Column(
                children: [
                  SwitchRow(
                    title: context.t('auto_collect_orders'),
                    value: _s.collectOrders,
                    onChanged: (v) =>
                        setState(() => _s = _s.copyWith(collectOrders: v)),
                  ),
                  SwitchRow(
                    title: context.t('auto_suggest_products'),
                    value: _s.suggestProducts,
                    onChanged: (v) =>
                        setState(() => _s = _s.copyWith(suggestProducts: v)),
                  ),
                  SwitchRow(
                    title: context.t('auto_handover_unsure'),
                    value: _s.handoverWhenUnsure,
                    onChanged: (v) =>
                        setState(() => _s = _s.copyWith(handoverWhenUnsure: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LoadingButton(label: context.t('save_settings'), onPressed: _save),
            const SizedBox(height: 22),
            SectionHeader(title: context.t('product_knowledge')),
            GroupedCard(
              children: [
                NavRow(
                  icon: AppIcons.products,
                  title: context.t('product_knowledge'),
                  subtitle: context.t('products_indexed', {
                    'n':
                        '${data.products.where((p) => p.status == ProductStatus.published).length}',
                  }),
                ),
                NavRow(
                  icon: AppIcons.book,
                  title: context.t('faq_knowledge'),
                  subtitle: '${data.knowledge.length}',
                  onTap: () => _push(const KnowledgeScreen()),
                ),
                NavRow(
                  icon: AppIcons.agent,
                  title: context.t('agent_test'),
                  subtitle: context.t('agent_test_hint'),
                  onTap: () => _push(const AgentTestScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SectionHeader(title: context.t('usage_info')),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.t('ai_replies'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        limit > 0 ? '$used / $limit' : '$used',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: limit > 0
                          ? (used / limit).clamp(0, 1).toDouble()
                          : 0,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).dividerColor,
                    ),
                  ),
                  if (sub == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        context.t('chart_empty_msg'),
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
