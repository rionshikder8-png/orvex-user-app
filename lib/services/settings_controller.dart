import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language and theme preferences. Stored with shared_preferences because they
/// are not sensitive.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    final lang = _prefs?.getString(_langKey);
    if (lang == 'bn' || lang == 'en') _locale = Locale(lang!);
    final theme = _prefs?.getString(_themeKey);
    _themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.light, // white/light is the default
    };
  }

  static const _langKey = 'pref_language';
  static const _themeKey = 'pref_theme';
  final SharedPreferences? _prefs;

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> setLocale(Locale l) async {
    if (l == _locale) return;
    _locale = l;
    notifyListeners();
    await _prefs?.setString(_langKey, l.languageCode);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    if (m == _themeMode) return;
    _themeMode = m;
    notifyListeners();
    await _prefs?.setString(_themeKey, m.name);
  }
}
