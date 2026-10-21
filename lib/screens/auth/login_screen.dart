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
import 'forgot_password_screen.dart';
import 'google_section.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final res = await context.read<AuthController>().login(
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
      title: context.t('login_title'),
      subtitle: context.t('login_subtitle'),
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
                textInputAction: TextInputAction.done,
                prefixIcon: AppIcons.lock,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.required(context, v),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: Text(context.t('forgot_password')),
                ),
              ),
              const SizedBox(height: 4),
              LoadingButton(
                label: context.t('login'),
                loading: busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
        const GoogleSection(),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(context.t('no_account')),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
              ),
              child: Text(context.t('register')),
            ),
          ],
        ),
      ],
    );
  }
}
