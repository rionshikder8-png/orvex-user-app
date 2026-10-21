import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n.dart';
import '../../services/settings_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;
    Widget option(String code, String label, String native) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(native),
      trailing: s.locale.languageCode == code
          ? Icon(Icons.check_circle, color: scheme.primary)
          : const Icon(Icons.circle_outlined),
      onTap: () => s.setLocale(Locale(code)),
    );
    return AppScaffold(
      title: context.t('language_settings'),
      body: PageBody(
        children: [
          GroupedCard(
            children: [
              option('en', context.t('lang_en'), 'English'),
              option('bn', context.t('lang_bn'), 'বাংলা'),
            ],
          ),
        ],
      ),
    );
  }
}
