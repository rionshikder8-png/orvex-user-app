import 'package:flutter/foundation.dart';

import '../core/app_config.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import 'google_auth_service.dart';
import 'session_store.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Result of an auth action, mapped to a localisation key by the UI.
class AuthResult {
  const AuthResult.ok() : errorKey = null, info = null;
  const AuthResult.fail(this.errorKey, {this.info});
  final String? errorKey;
  final String? info;
  bool get success => errorKey == null;
}

/// Owns the platform session. A user is "signed in" only when the backend has
/// returned a session token (or the user explicitly chose the local demo mode).
class AuthController extends ChangeNotifier {
  AuthController({
    required this.api,
    required this.service,
    required this.store,
    required this.google,
  }) {
    api.tokenProvider = store.readToken;
    api.onUnauthorized = _handleUnauthorized;
  }

  final ApiClient api;
  final AuthService service;
  final SessionStore store;
  final GoogleAuthService google;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _sessionExpired = false;
  bool _busy = false;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isDemo => _user?.isDemo ?? false;
  bool get sessionExpired => _sessionExpired;
  bool get busy => _busy;
  bool get needsOnboarding =>
      _user != null && !_user!.isDemo && !_user!.hasBusiness;

  /// Restores a previous session on start-up.
  Future<void> restore() async {
    final token = await store.readToken();
    if (token == null || token.isEmpty) {
      _status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    if (!api.isConfigured) {
      // A stored token without a backend cannot be validated.
      await store.clear();
      _status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    try {
      _user = await service.currentUser();
      _status = AuthStatus.signedIn;
    } on ApiException catch (e) {
      if (e.isSessionExpired) {
        await store.clear();
        _sessionExpired = true;
        _status = AuthStatus.signedOut;
      } else {
        // Temporary failure (offline/server): keep the token, ask to retry.
        _status = AuthStatus.signedOut;
      }
    }
    notifyListeners();
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    if (!api.isConfigured) {
      return const AuthResult.fail('backend_missing_login');
    }
    _setBusy(true);
    try {
      await _accept(await service.login(email.trim(), password));
      return const AuthResult.ok();
    } on ApiException catch (e) {
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    if (!api.isConfigured) {
      return const AuthResult.fail('backend_missing_login');
    }
    _setBusy(true);
    try {
      await _accept(
        await service.register(name.trim(), email.trim(), password),
      );
      return const AuthResult.ok();
    } on ApiException catch (e) {
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  /// Google flow: Google ID token -> backend verification -> platform session.
  Future<AuthResult> loginWithGoogle() async {
    if (!google.isConfigured) {
      return const AuthResult.fail('google_setup_required');
    }
    _setBusy(true);
    try {
      final idToken = await google.getIdToken();
      if (!api.isConfigured) {
        // Selecting a Google account is NOT platform authentication.
        await google.signOut();
        return const AuthResult.fail('google_backend_missing');
      }
      await _accept(await service.loginWithGoogle(idToken));
      return const AuthResult.ok();
    } on GoogleAuthException catch (e) {
      return switch (e.failure) {
        GoogleAuthFailure.notConfigured => const AuthResult.fail(
          'google_setup_required',
        ),
        GoogleAuthFailure.cancelled => const AuthResult.fail(
          'google_cancelled',
        ),
        GoogleAuthFailure.noIdToken => const AuthResult.fail('google_no_token'),
        GoogleAuthFailure.failed => AuthResult.fail(
          'google_failed',
          info: e.detail,
        ),
      };
    } on ApiException catch (e) {
      await google.signOut();
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> forgotPassword(String email) async {
    if (!api.isConfigured) {
      return const AuthResult.fail('backend_not_configured');
    }
    _setBusy(true);
    try {
      await service.forgotPassword(email.trim());
      return const AuthResult.ok();
    } on ApiException catch (e) {
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> resetPassword(String code, String password) async {
    if (!api.isConfigured) {
      return const AuthResult.fail('backend_not_configured');
    }
    _setBusy(true);
    try {
      await service.resetPassword(code.trim(), password);
      return const AuthResult.ok();
    } on ApiException catch (e) {
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  Future<AuthResult> changePassword(String current, String next) async {
    if (!api.isConfigured || isDemo) {
      return const AuthResult.fail('password_update_needs_backend');
    }
    _setBusy(true);
    try {
      await service.changePassword(current, next);
      return const AuthResult.ok();
    } on ApiException catch (e) {
      return AuthResult.fail(_keyFor(e), info: e.message);
    } finally {
      _setBusy(false);
    }
  }

  /// Local-only session with sample data. Nothing is persisted or sent.
  void enterDemo() {
    if (!AppConfig.useDemoData) return;
    _user = const AppUser(
      id: 'demo',
      name: 'Demo Owner',
      email: 'owner@demo-fashion.example',
      hasBusiness: true,
      isDemo: true,
    );
    _sessionExpired = false;
    _status = AuthStatus.signedIn;
    notifyListeners();
  }

  void markBusinessCreated() {
    if (_user != null) {
      _user = _user!.copyWith(hasBusiness: true);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (!isDemo) await service.logout();
    await google.signOut();
    await store.clear();
    _user = null;
    _sessionExpired = false;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  void clearExpiredFlag() {
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> _accept(AuthSession s) async {
    await store.writeToken(s.token);
    _user = s.user;
    _sessionExpired = false;
    _status = AuthStatus.signedIn;
  }

  void _handleUnauthorized() {
    if (_status != AuthStatus.signedIn || isDemo) return;
    store.clear();
    _user = null;
    _sessionExpired = true;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  String _keyFor(ApiException e) => switch (e.type) {
    ApiErrorType.offline => 'offline_msg',
    ApiErrorType.notConfigured => 'backend_not_configured',
    _ => 'error_generic',
  };
}
