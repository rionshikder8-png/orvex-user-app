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
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final res = await context.read<AuthController>().forgotPassword(
      _email.text,
    );
    if (!mounted) return;
    setState(() {
      if (res.success) {
        _sent = true;
      } else {
        _error = res.errorKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return AuthScaffold(
      title: context.t('forgot_title'),
      subtitle: context.t('forgot_subtitle'),
      children: [
        if (_sent) ...[
          NoticeBanner(
            kind: NoticeKind.success,
            message: context.t('reset_link_sent'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ResetPasswordScreen(),
              ),
            ),
            child: Text(context.t('have_reset_code')),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('back_to_login')),
          ),
        ] else
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
                  textInputAction: TextInputAction.done,
                  prefixIcon: AppIcons.email,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => Validators.email(context, v),
                ),
                const SizedBox(height: 20),
                LoadingButton(
                  label: context.t('send_reset_link'),
                  loading: busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ResetPasswordScreen(),
                    ),
                  ),
                  child: Text(context.t('have_reset_code')),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
