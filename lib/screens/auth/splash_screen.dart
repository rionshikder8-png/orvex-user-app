import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/auth_controller.dart';
import '../../widgets/brand_logo.dart';
import '../app_gate.dart';

/// Shows the brand while the stored session is restored, then hands over to
/// [AppGate].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthController>();
    await Future.wait([
      auth.restore(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const AppGate();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 76),
                const SizedBox(height: 20),
                const Text(
                  'Orvex Ai',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('splash_tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
                const SizedBox(height: 12),
                Text(
                  context.t('checking_session'),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
