import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orvex_user_app/services/auth_controller.dart';

import 'helpers.dart';

void main() {
  test('login without a backend fails honestly and does not sign in', () async {
    final env = TestEnv();
    final res = await env.auth.login('a@b.co', 'password1');
    expect(res.success, isFalse);
    expect(res.errorKey, 'backend_missing_login');
    expect(env.auth.status, isNot(AuthStatus.signedIn));
  });

  test('Google sign-in without a client ID reports setup required', () async {
    final env = TestEnv();
    final res = await env.auth.loginWithGoogle();
    expect(res.success, isFalse);
    expect(res.errorKey, 'google_setup_required');
    expect(env.auth.status, isNot(AuthStatus.signedIn));
  });

  test('successful backend login stores the platform token', () async {
    final env = TestEnv(
      baseUrl: 'https://api.test',
      client: MockClient((req) async {
        expect(req.url.path, '/auth/login');
        return http.Response(
          jsonEncode({
            'token': 'platform-token',
            'user': {
              'id': '1',
              'name': 'Rahim',
              'email': 'r@x.co',
              'has_business': true,
            },
          }),
          200,
        );
      }),
    );
    final res = await env.auth.login('r@x.co', 'password1');
    expect(res.success, isTrue);
    expect(env.auth.status, AuthStatus.signedIn);
    expect(await env.store.readToken(), 'platform-token');
    expect(env.auth.needsOnboarding, isFalse);
  });

  test('backend response without a token is rejected', () async {
    final env = TestEnv(
      baseUrl: 'https://api.test',
      client: MockClient(
        (_) async => http.Response(jsonEncode({'user': {}}), 200),
      ),
    );
    final res = await env.auth.login('r@x.co', 'password1');
    expect(res.success, isFalse);
    expect(env.auth.status, isNot(AuthStatus.signedIn));
  });

  test('expired session on restore clears token and flags expiry', () async {
    final env = TestEnv(
      baseUrl: 'https://api.test',
      client: MockClient(
        (_) async => http.Response('{"message":"expired"}', 401),
      ),
    );
    await env.store.writeToken('old');
    await env.auth.restore();
    expect(env.auth.status, AuthStatus.signedOut);
    expect(env.auth.sessionExpired, isTrue);
    expect(await env.store.readToken(), isNull);
  });

  test('demo session is local and logout clears it', () async {
    final env = TestEnv();
    env.auth.enterDemo();
    expect(env.auth.isDemo, isTrue);
    expect(env.auth.status, AuthStatus.signedIn);
    expect(await env.store.readToken(), isNull);
    await env.auth.logout();
    expect(env.auth.status, AuthStatus.signedOut);
  });
}
