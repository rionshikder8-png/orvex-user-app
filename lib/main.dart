import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/api_client.dart';
import 'services/app_data.dart';
import 'services/auth_controller.dart';
import 'services/auth_service.dart';
import 'services/data_api.dart';
import 'services/google_auth_service.dart';
import 'services/session_store.dart';
import 'services/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final api = ApiClient();
  final auth = AuthController(
    api: api,
    service: AuthService(api),
    store: SecureSessionStore(),
    google: GoogleAuthService(),
  );
  final data = AppData(DataApi(api));
  final settings = SettingsController(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: auth),
        ChangeNotifierProvider<AppData>.value(value: data),
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        Provider<ApiClient>.value(value: api),
      ],
      child: const OrvexApp(),
    ),
  );
}
