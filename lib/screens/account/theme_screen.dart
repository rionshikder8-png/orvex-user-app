import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/settings_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    Widget option(ThemeMode m, String label, IconData icon) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: scheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: s.themeMode == m
          ? Icon(Icons.check_circle, color: scheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => s.setThemeMode(m),
    );
    return AppScaffold(
      title: context.t('theme_settings'),
      body: PageBody(
        children: [
          GroupedCard(
            children: [
              option(
                ThemeMode.light,
                context.t('theme_light'),
                Icons.light_mode_outlined,
              ),
              option(
                ThemeMode.dark,
                context.t('theme_dark'),
                Icons.dark_mode_outlined,
              ),
              option(
                ThemeMode.system,
                context.t('theme_system'),
                Icons.brightness_auto_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
