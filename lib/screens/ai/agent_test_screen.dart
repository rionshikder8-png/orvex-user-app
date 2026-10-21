import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/app_data.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_inputs.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/google_button.dart';
import '../../widgets/state_views.dart';

/// Lets the owner try a customer message. A reply is shown only if the backend
/// and AI provider actually produced one.
class AgentTestScreen extends StatefulWidget {
  const AgentTestScreen({super.key});

  @override
  State<AgentTestScreen> createState() => _AgentTestScreenState();
}

class _AgentTestScreenState extends State<AgentTestScreen> {
  final _msg = TextEditingController();
  bool _loading = false;
  String? _reply;
  String? _errorKey;

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_msg.text.trim().isEmpty) {
      setState(() => _errorKey = null);
      showSnack(context, context.t('required'), error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _reply = null;
      _errorKey = null;
    });
    final err = await context.read<AppData>().testAgent(
      _msg.text.trim(),
      (r) => _reply = r,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _errorKey = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.t('agent_test'),
      body: PageBody(
        children: [
          Text(
            context.t('agent_test_hint'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _msg,
            label: context.t('test_message'),
            maxLines: 4,
            minLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 14),
          LoadingButton(
            label: context.t('run_test'),
            loading: _loading,
            onPressed: _run,
          ),
          const SizedBox(height: 18),
          if (_errorKey != null)
            NoticeBanner(
              kind: NoticeKind.warning,
              title: context.t('test_unavailable'),
              message: context.t(_errorKey!),
            ),
          if (_reply != null)
            AppCard(child: Text(_reply!, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }
}
