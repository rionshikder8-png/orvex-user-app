import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final res = await context.read<AuthController>().changePassword(
      _current.text,
      _next.text,
    );
    if (!mounted) return;
    if (res.success) {
      showSnack(context, context.t('settings_saved'));
      Navigator.pop(context);
    } else {
      setState(() => _error = res.errorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return AppScaffold(
      title: context.t('password_settings'),
      body: Form(
        key: _form,
        child: PageBody(
          children: [
            if (_error != null) ...[
              NoticeBanner(
                kind: NoticeKind.danger,
                message: context.t(_error!),
              ),
              const SizedBox(height: 14),
            ],
            AppTextField(
              controller: _current,
              label: context.t('current_password'),
              obscure: true,
              prefixIcon: AppIcons.lock,
              validator: (v) => Validators.required(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _next,
              label: context.t('new_password'),
              obscure: true,
              prefixIcon: AppIcons.lock,
              validator: (v) => Validators.password(context, v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirm,
              label: context.t('confirm_password'),
              obscure: true,
              prefixIcon: AppIcons.lock,
              validator: (v) => Validators.confirm(context, v, _next.text),
            ),
            const SizedBox(height: 20),
            LoadingButton(
              label: context.t('update_password'),
              loading: busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
