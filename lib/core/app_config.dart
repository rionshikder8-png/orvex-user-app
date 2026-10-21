/// Build-time configuration. Values are supplied with `--dart-define` so that
/// nothing environment specific (and nothing secret) is committed to source.
///
/// Example:
/// flutter run \
///   --dart-define=API_BASE_URL=https://api.example.com/v1 \
///   --dart-define=GOOGLE_SERVER_CLIENT_ID=1234-abc.apps.googleusercontent.com
class AppConfig {
  AppConfig._();

  /// Base URL of the future PHP backend. Empty means "not configured yet".
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// OAuth 2.0 **Web application** client ID from Google Cloud. The backend
  /// verifies Google ID tokens against this audience. This is a public
  /// identifier, not a secret. Never put a client secret in the app.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// When true the app shows clearly labelled demo data wherever the backend
  /// returns nothing or is not configured. Set `--dart-define=USE_DEMO_DATA=false`
  /// to disable demo data completely.
  static const bool useDemoData = bool.fromEnvironment(
    'USE_DEMO_DATA',
    defaultValue: true,
  );

  static const Duration requestTimeout = Duration(seconds: 20);

  static bool get isApiConfigured => apiBaseUrl.trim().isNotEmpty;
  static bool get isGoogleConfigured => googleServerClientId.trim().isNotEmpty;

  static const String appName = 'Orvex Ai';
  static const String androidApplicationId = 'com.orvex.user';
}
