import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../models/models.dart';
import '../../services/app_data.dart';
import '../../services/auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import '../onboarding/onboarding_screen.dart' show kBusinessTypes;

/// Account profile and business profile. Edits are local until the backend is
/// connected, which the screen states.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _bName;
  late final TextEditingController _bEmail;
  late final TextEditingController _bPhone;
  late final TextEditingController _bWeb;
  late final TextEditingController _bDesc;
  late String _type;
  late String _lang;

  @override
  void initState() {
    super.initState();
    final b = context.read<AppData>().business;
    _bName = TextEditingController(text: b.name);
    _bEmail = TextEditingController(text: b.contactEmail);
    _bPhone = TextEditingController(text: b.contactPhone);
    _bWeb = TextEditingController(text: b.website);
    _bDesc = TextEditingController(text: b.description);
    _type = kBusinessTypes.contains(b.type) ? b.type : 'type_other';
    _lang = b.defaultLanguage == 'en' ? 'en' : 'bn';
  }

  @override
  void dispose() {
    for (final c in [_bName, _bEmail, _bPhone, _bWeb, _bDesc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppData>().saveBusinessLocal(
      BusinessProfile(
        name: _bName.text.trim(),
        type: _type,
        website: _bWeb.text.trim(),
        contactEmail: _bEmail.text.trim(),
        contactPhone: _bPhone.text.trim(),
        description: _bDesc.text.trim(),
        defaultLanguage: _lang,
      ),
    );
    showSnack(context, context.t('settings_saved_local'));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    return AppScaffold(
      title: context.t('profile_settings'),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    label: context.t('full_name'),
                    value: user?.name ?? '',
                  ),
                  InfoRow(label: context.t('email'), value: user?.email ?? ''),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(title: context.t('business_profile')),
            NoticeBanner(message: context.t('not_saved_notice')),
            const SizedBox(height: 14),
            AppTextField(
              controller: _bName,
              label: context.t('business_name'),
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
              controller: _bEmail,
              label: context.t('contact_email'),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: AppIcons.email,
              validator: (v) => Validators.optionalEmail(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _bPhone,
              label: context.t('contact_phone'),
              keyboardType: TextInputType.phone,
              prefixIcon: AppIcons.phone,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? null
                  : Validators.phone(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _bWeb,
              label:
                  '${context.t('website_domain')} (${context.t('optional')})',
              keyboardType: TextInputType.url,
              prefixIcon: AppIcons.web,
              validator: (v) => Validators.optionalDomain(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _bDesc,
              label:
                  '${context.t('business_description')} (${context.t('optional')})',
              maxLines: 4,
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: context.t('default_language'),
              value: _lang,
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
              onChanged: (v) => setState(() => _lang = v ?? _lang),
            ),
            const SizedBox(height: 20),
            LoadingButton(label: context.t('save'), onPressed: _save),
          ],
        ),
      ),
    );
  }
}
