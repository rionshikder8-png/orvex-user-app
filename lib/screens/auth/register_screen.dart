import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/auth_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';
import 'auth_scaffold.dart';
import 'google_section.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final res = await context.read<AuthController>().register(
      _name.text,
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    if (res.success) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      setState(() => _error = res.errorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return AuthScaffold(
      title: context.t('register_title'),
      subtitle: context.t('register_subtitle'),
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                NoticeBanner(
                  kind: NoticeKind.danger,
                  message: context.t(_error!),
                ),
                const SizedBox(height: 14),
              ],
              AppTextField(
                controller: _name,
                label: context.t('full_name'),
                textInputAction: TextInputAction.next,
                prefixIcon: AppIcons.profile,
                autofillHints: const [AutofillHints.name],
                validator: (v) => Validators.name(context, v),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _email,
                label: context.t('email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: AppIcons.email,
                autofillHints: const [AutofillHints.email],
                validator: (v) => Validators.email(context, v),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _password,
                label: context.t('password'),
                obscure: true,
                textInputAction: TextInputAction.next,
                prefixIcon: AppIcons.lock,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => Validators.password(context, v),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confirm,
                label: context.t('confirm_password'),
                obscure: true,
                textInputAction: TextInputAction.done,
                prefixIcon: AppIcons.lock,
                onSubmitted: (_) => _submit(),
                validator: (v) =>
                    Validators.confirm(context, v, _password.text),
              ),
              const SizedBox(height: 20),
              LoadingButton(
                label: context.t('register'),
                loading: busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
        const GoogleSection(),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(context.t('has_account'))),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              ),
              child: Text(context.t('login')),
            ),
          ],
        ),
      ],
    );
  }
}
