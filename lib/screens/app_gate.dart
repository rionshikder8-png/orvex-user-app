import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_data.dart';
import '../services/auth_controller.dart';
import 'auth/welcome_screen.dart';
import 'main_shell.dart';
import 'onboarding/onboarding_screen.dart';

/// Chooses the root screen from the session state and (re)loads app data when
/// a session starts. This is the only place that decides signed-in vs out, so
/// logout and session expiry automatically return the user to the welcome flow.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  String? _loadedFor;

  void _maybeLoad(AuthController auth, AppData data) {
    final key = auth.status == AuthStatus.signedIn
        ? '${auth.user?.id}|${auth.isDemo}'
        : null;
    if (key != null && key != _loadedFor) {
      _loadedFor = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) data.load(demoSession: auth.isDemo);
      });
    } else if (key == null) {
      _loadedFor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final data = context.read<AppData>();
    _maybeLoad(auth, data);

    switch (auth.status) {
      case AuthStatus.unknown:
      case AuthStatus.signedOut:
        return const WelcomeScreen();
      case AuthStatus.signedIn:
        if (auth.needsOnboarding) return const OnboardingScreen();
        return const MainShell();
    }
  }
}
