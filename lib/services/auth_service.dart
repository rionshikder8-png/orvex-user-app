import '../core/api_endpoints.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Talks to the backend auth endpoints. Every method returns data only when the
/// backend confirms success; failures surface as [ApiException].
class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<AuthSession> login(String email, String password) async {
    final res = await _api.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      auth: false,
    );
    return _session(res);
  }

  Future<AuthSession> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await _api.post(
      ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password},
      auth: false,
    );
    return _session(res);
  }

  /// Sends the Google ID token to the backend. The backend verifies it against
  /// Google, creates or finds the platform account and returns its own session.
  Future<AuthSession> loginWithGoogle(String idToken) async {
    final res = await _api.post(
      ApiEndpoints.google,
      body: {'id_token': idToken},
      auth: false,
    );
    return _session(res);
  }

  Future<AppUser> currentUser() async {
    final res = await _api.get(ApiEndpoints.me);
    if (res is Map) {
      final data = res['user'] is Map ? res['user'] : res;
      return AppUser.fromJson(Map<String, dynamic>.from(data as Map));
    }
    throw const ApiException(ApiErrorType.server, 'Unexpected response.');
  }

  Future<void> forgotPassword(String email) => _api.post(
    ApiEndpoints.forgotPassword,
    body: {'email': email},
    auth: false,
  );

  Future<void> resetPassword(String code, String newPassword) => _api.post(
    ApiEndpoints.resetPassword,
    body: {'code': code, 'password': newPassword},
    auth: false,
  );

  Future<void> changePassword(String current, String next) => _api.post(
    ApiEndpoints.changePassword,
    body: {'current_password': current, 'new_password': next},
  );

  Future<void> logout() async {
    try {
      await _api.post(ApiEndpoints.logout);
    } on ApiException {
      // Local logout must succeed even if the server cannot be reached.
    }
  }

  AuthSession _session(dynamic res) {
    if (res is Map &&
        res['token'] is String &&
        (res['token'] as String).isNotEmpty) {
      return AuthSession.fromJson(Map<String, dynamic>.from(res));
    }
    throw const ApiException(
      ApiErrorType.server,
      'The server did not return a session.',
    );
  }
}
