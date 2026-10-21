import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_config.dart';
import '../../core/l10n.dart';
import '../../services/auth_controller.dart';
import '../../services/settings_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/state_views.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = context.watch<AuthController>();
    final settings = context.watch<SettingsController>();

    final points = [
      (AppIcons.inbox, context.t('welcome_point_1')),
      (AppIcons.agent, context.t('welcome_point_2')),
      (AppIcons.orders, context.t('welcome_point_3')),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Flexible(child: BrandLockup(size: 34)),
                      const SizedBox(width: 8),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        segments: const [
                          ButtonSegment(value: 'en', label: Text('EN')),
                          ButtonSegment(value: 'bn', label: Text('বাং')),
                        ],
                        selected: {settings.locale.languageCode},
                        onSelectionChanged: (s) =>
                            settings.setLocale(Locale(s.first)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  if (auth.sessionExpired) ...[
                    NoticeBanner(
                      kind: NoticeKind.warning,
                      title: context.t('session_expired_title'),
                      message: context.t('session_expired_msg'),
                    ),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    context.t('welcome_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.t('welcome_subtitle'),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 15.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 26),
                  for (final p in points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(p.$1, size: 19, color: scheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              p.$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterScreen(),
                      ),
                    ),
                    child: Text(context.t('get_started')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                    ),
                    child: Text(context.t('have_account')),
                  ),
                  if (AppConfig.useDemoData) ...[
                    const SizedBox(height: 18),
                    AppCard(
                      onTap: auth.enterDemo,
                      child: Row(
                        children: [
                          Icon(Icons.science_outlined, color: scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t('explore_demo'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.t('explore_demo_hint'),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(AppIcons.chevron),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
