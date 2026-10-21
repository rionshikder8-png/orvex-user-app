import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../services/auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/state_views.dart';

const List<String> kBusinessTypes = [
  'type_fashion',
  'type_electronics',
  'type_grocery',
  'type_beauty',
  'type_home',
  'type_other',
];

const List<String> kTones = [
  'tone_friendly',
  'tone_professional',
  'tone_concise',
  'tone_persuasive',
];

/// 3 steps: business, AI agent, completion.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _businessForm = GlobalKey<FormState>();
  final _agentForm = GlobalKey<FormState>();
  int _step = 0;

  final _name = TextEditingController();
  final _website = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _desc = TextEditingController();
  String _type = 'type_fashion';
  String _bizLang = 'bn';

  final _agentName = TextEditingController(text: 'Orvex Assistant');
  final _instructions = TextEditingController();
  String _agentLang = 'bn';
  String _tone = 'tone_friendly';
  bool _collect = true;
  bool _suggest = true;
  bool _handover = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    if (user != null) _email.text = user.email;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _website,
      _email,
      _phone,
      _desc,
      _agentName,
      _instructions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (_step == 0 && !_businessForm.currentState!.validate()) return;
    if (_step == 1 && !_agentForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_step == 1) _save();
    setState(() => _step++);
  }

  /// Keeps the profile in memory for this session. It is not claimed as saved on
  /// the server: the completion screen says it will sync later.
  void _save() {
    final data = context.read<AppData>();
    data.saveBusinessLocal(
      BusinessProfile(
        name: _name.text.trim(),
        type: _type,
        website: _website.text.trim(),
        contactEmail: _email.text.trim(),
        contactPhone: _phone.text.trim(),
        description: _desc.text.trim(),
        defaultLanguage: _bizLang,
      ),
    );
    data.saveAgentLocal(
      AgentSettings(
        enabled: false,
        name: _agentName.text.trim(),
        language: _agentLang,
        tone: _tone,
        instructions: _instructions.text.trim(),
        collectOrders: _collect,
        suggestProducts: _suggest,
        handoverWhenUnsure: _handover,
      ),
    );
  }

  void _finish() => context.read<AuthController>().markBusinessCreated();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = [
      context.t('step_business'),
      context.t('step_agent'),
      context.t('step_done'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const BrandLockup(size: 28),
        leading: _step > 0 && _step < 2
            ? IconButton(
                icon: const Icon(AppIcons.back),
                onPressed: () => setState(() => _step--),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('onboarding_title'),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.t('step_of', {
                      'current': '${_step + 1}',
                      'total': '3',
                    }),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StepIndicator(current: _step, labels: labels),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _step == 2
                      ? FilledButton(
                          onPressed: _finish,
                          child: Text(context.t('go_dashboard')),
                        )
                      : Row(
                          children: [
                            if (_step > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _step--),
                                  child: Text(context.t('back')),
                                ),
                              ),
                            if (_step > 0) const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: _next,
                                child: Text(
                                  _step == 1
                                      ? context.t('finish_setup')
                                      : context.t('next'),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _businessStep(context);
      case 1:
        return _agentStep(context);
      default:
        return _doneStep(context);
    }
  }

  Widget _businessStep(BuildContext context) {
    return Form(
      key: _businessForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _name,
            label: context.t('business_name'),
            textInputAction: TextInputAction.next,
            prefixIcon: AppIcons.business,
            validator: (v) => Validators.required(context, v),
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: context.t('business_type'),
            value: _type,
            items: [
              for (final t in kBusinessTypes)
                DropdownMenuItem(value: t, child: Text(context.t(t))),
            ],
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _website,
            label: '${context.t('website_domain')} (${context.t('optional')})',
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            prefixIcon: AppIcons.web,
            validator: (v) => Validators.optionalDomain(context, v),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _email,
            label: context.t('contact_email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: AppIcons.email,
            validator: (v) => Validators.email(context, v),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _phone,
            label: context.t('contact_phone'),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            prefixIcon: AppIcons.phone,
            validator: (v) => Validators.phone(context, v),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _desc,
            label:
                '${context.t('business_description')} (${context.t('optional')})',
            maxLines: 4,
            minLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: context.t('default_language'),
            value: _bizLang,
            items: [
              DropdownMenuItem(value: 'bn', child: Text(context.t('lang_bn'))),
              DropdownMenuItem(value: 'en', child: Text(context.t('lang_en'))),
            ],
            onChanged: (v) => setState(() => _bizLang = v ?? _bizLang),
          ),
        ],
      ),
    );
  }

  Widget _agentStep(BuildContext context) {
    return Form(
      key: _agentForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _agentName,
            label: context.t('agent_name'),
            textInputAction: TextInputAction.next,
            prefixIcon: AppIcons.agent,
            validator: (v) => Validators.required(context, v),
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: context.t('primary_language'),
            value: _agentLang,
            items: [
              DropdownMenuItem(value: 'bn', child: Text(context.t('lang_bn'))),
              DropdownMenuItem(value: 'en', child: Text(context.t('lang_en'))),
            ],
            onChanged: (v) => setState(() => _agentLang = v ?? _agentLang),
          ),
          const SizedBox(height: 14),
          AppDropdown<String>(
            label: context.t('response_tone'),
            value: _tone,
            items: [
              for (final t in kTones)
                DropdownMenuItem(value: t, child: Text(context.t(t))),
            ],
            onChanged: (v) => setState(() => _tone = v ?? _tone),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _instructions,
            label:
                '${context.t('business_instructions')} (${context.t('optional')})',
            hint: context.t('business_instructions_hint'),
            maxLines: 5,
            minLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 18),
          Text(
            context.t('sales_automation'),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          SwitchRow(
            title: context.t('auto_collect_orders'),
            value: _collect,
            onChanged: (v) => setState(() => _collect = v),
          ),
          SwitchRow(
            title: context.t('auto_suggest_products'),
            value: _suggest,
            onChanged: (v) => setState(() => _suggest = v),
          ),
          SwitchRow(
            title: context.t('auto_handover_unsure'),
            value: _handover,
            onChanged: (v) => setState(() => _handover = v),
          ),
        ],
      ),
    );
  }

  Widget _doneStep(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(AppIcons.check, size: 36, color: scheme.primary),
          ),
          const SizedBox(height: 22),
          Text(
            context.t('setup_complete'),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('setup_complete_msg'),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
          ),
          const SizedBox(height: 20),
          NoticeBanner(message: context.t('not_saved_notice')),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= current
                        ? scheme.primary
                        : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: i == current
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i <= current
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (i < labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
