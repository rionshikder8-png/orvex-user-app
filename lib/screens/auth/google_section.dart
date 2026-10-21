import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/auth_controller.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';

/// "or" divider, the Google button and an honest setup-required notice.
/// Used by both login and registration.
class GoogleSection extends StatefulWidget {
  const GoogleSection({super.key});

  @override
  State<GoogleSection> createState() => _GoogleSectionState();
}

class _GoogleSectionState extends State<GoogleSection> {
  bool _loading = false;
  String? _error;

  Future<void> _go() async {
    final auth = context.read<AuthController>();
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await auth.loginWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!res.success) {
      setState(() => _error = res.errorKey);
      if (res.errorKey == 'google_cancelled') {
        showSnack(context, context.t('google_cancelled'));
        setState(() => _error = null);
      } else if (res.errorKey == 'google_setup_required') {
        // The inline notice below explains what is missing.
      }
    } else {
      // Pop auth screens; AppGate now shows onboarding or the dashboard.
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();
    final configured = auth.google.isConfigured;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                context.t('or'),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        GoogleButton(onPressed: _go, loading: _loading),
        if (!configured || _error != null) ...[
          const SizedBox(height: 12),
          NoticeBanner(
            kind: _error == null || _error == 'google_setup_required'
                ? NoticeKind.warning
                : NoticeKind.danger,
            title: !configured || _error == 'google_setup_required'
                ? context.t('google_setup_required')
                : null,
            message: !configured || _error == 'google_setup_required'
                ? context.t('google_setup_msg')
                : context.t(_error!),
          ),
        ],
      ],
    );
  }
}
