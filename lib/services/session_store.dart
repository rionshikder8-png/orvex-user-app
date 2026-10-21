import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the platform session token in the Android Keystore-backed secure
/// storage. Nothing else sensitive is persisted by the app.
abstract class SessionStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'orvex_session_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      // A corrupted keystore entry must not crash start-up.
      return null;
    }
  }

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }
}

/// In-memory store used by tests.
class MemorySessionStore implements SessionStore {
  String? _token;
  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> writeToken(String token) async => _token = token;
  @override
  Future<void> clear() async => _token = null;
}
