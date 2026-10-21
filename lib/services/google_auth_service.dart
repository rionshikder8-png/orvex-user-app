import 'package:google_sign_in/google_sign_in.dart';

import '../core/app_config.dart';

enum GoogleAuthFailure { notConfigured, cancelled, noIdToken, failed }

class GoogleAuthException implements Exception {
  const GoogleAuthException(this.failure, [this.detail]);
  final GoogleAuthFailure failure;
  final String? detail;
  @override
  String toString() => 'GoogleAuthException($failure, $detail)';
}

/// Obtains a Google **ID token** using the supported `google_sign_in` 7.x API.
///
/// The ID token is only an input for the Orvex backend. It is never treated as
/// proof of platform authentication: the backend must verify it and return its
/// own session token.
class GoogleAuthService {
  GoogleAuthService();

  bool _initialised = false;

  bool get isConfigured => AppConfig.isGoogleConfigured;

  Future<void> _ensureInitialised() async {
    if (_initialised) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );
    _initialised = true;
  }

  /// Starts the Google account chooser and returns the ID token.
  Future<String> getIdToken() async {
    if (!isConfigured) {
      throw const GoogleAuthException(GoogleAuthFailure.notConfigured);
    }
    try {
      await _ensureInitialised();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const GoogleAuthException(
          GoogleAuthFailure.failed,
          'Authenticate is not supported here.',
        );
      }
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const GoogleAuthException(GoogleAuthFailure.noIdToken);
      }
      return idToken;
    } on GoogleAuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const GoogleAuthException(GoogleAuthFailure.cancelled);
      }
      throw GoogleAuthException(
        GoogleAuthFailure.failed,
        e.description ?? e.code.name,
      );
    } catch (e) {
      throw GoogleAuthException(GoogleAuthFailure.failed, e.toString());
    }
  }

  Future<void> signOut() async {
    if (!_initialised) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
