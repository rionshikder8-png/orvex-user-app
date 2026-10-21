import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:orvex_user_app/core/l10n.dart';
import 'package:orvex_user_app/core/theme.dart';
import 'package:orvex_user_app/services/api_client.dart';
import 'package:orvex_user_app/services/app_data.dart';
import 'package:orvex_user_app/services/auth_controller.dart';
import 'package:orvex_user_app/services/auth_service.dart';
import 'package:orvex_user_app/services/data_api.dart';
import 'package:orvex_user_app/services/google_auth_service.dart';
import 'package:orvex_user_app/services/session_store.dart';
import 'package:orvex_user_app/services/settings_controller.dart';
import 'package:provider/provider.dart';

class TestEnv {
  TestEnv({String baseUrl = '', http.Client? client})
    : api = ApiClient(baseUrl: baseUrl, client: client) {
    store = MemorySessionStore();
    auth = AuthController(
      api: api,
      service: AuthService(api),
      store: store,
      google: GoogleAuthService(),
    );
    data = AppData(DataApi(api));
    settings = SettingsController(null);
  }

  final ApiClient api;
  late final MemorySessionStore store;
  late final AuthController auth;
  late final AppData data;
  late final SettingsController settings;
}

/// Wraps [home] with the same providers and localisation as the real app.
Widget wrap(
  TestEnv env,
  Widget home, {
  Locale locale = const Locale('en'),
  bool dark = false,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: env.auth),
      ChangeNotifierProvider.value(value: env.data),
      ChangeNotifierProvider.value(value: env.settings),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: home,
    ),
  );
}
