
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

  try {
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
          ChangeNotifierProvider<SettingsController>.value(
            value: settings,
          ),
          Provider<ApiClient>.value(value: api),
        ],
        child: const OrvexApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('ORVEX STARTUP ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ORVEX could not start',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A startup error occurred. Please share this '
                      'screen with the developer.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
