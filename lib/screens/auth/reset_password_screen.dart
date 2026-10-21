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

/// Reset-password UI, ready for the backend `POST /auth/reset-password`.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    final res = await context.read<AuthController>().resetPassword(
      _code.text,
      _password.text,
    );
    if (!mounted) return;
    setState(() {
      if (res.success) {
        _done = true;
      } else {
        _error = res.errorKey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return AuthScaffold(
      title: context.t('reset_title'),
      subtitle: context.t('reset_subtitle'),
      children: [
        if (_done) ...[
          NoticeBanner(
            kind: NoticeKind.success,
            message: context.t('reset_success'),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
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
                  controller: _code,
                  label: context.t('reset_code'),
                  textInputAction: TextInputAction.next,
                  prefixIcon: AppIcons.shield,
                  validator: (v) => Validators.required(context, v),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _password,
                  label: context.t('new_password'),
                  obscure: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: AppIcons.lock,
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
                  label: context.t('reset_password'),
                  loading: busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
