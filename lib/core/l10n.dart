import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'strings_bn.dart';
import 'strings_en.dart';

/// Lightweight English / Bangla localisation backed by plain maps.
/// Usage: `context.t('login')` or `context.t('welcome_name', {'name': 'Rahim'})`.
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const List<Locale> supportedLocales = [Locale('en'), Locale('bn')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizations(const Locale('en'));

  String tr(String key, [Map<String, String>? args]) {
    final Map<String, String> table = locale.languageCode == 'bn'
        ? stringsBn
        : stringsEn;
    String value = table[key] ?? stringsEn[key] ?? key;
    if (kDebugMode && table[key] == null && stringsEn[key] == null) {
      debugPrint('Missing translation key: $key');
    }
    args?.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'bn';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizedContext on BuildContext {
  String t(String key, [Map<String, String>? args]) =>
      AppLocalizations.of(this).tr(key, args);
}
