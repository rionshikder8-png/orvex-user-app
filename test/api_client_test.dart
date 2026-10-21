import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orvex_user_app/services/api_client.dart';
import 'package:orvex_user_app/services/api_exception.dart';

void main() {
  test('throws notConfigured without a base URL', () async {
    final api = ApiClient(baseUrl: '');
    expect(api.isConfigured, isFalse);
    expect(
      () => api.get('/x'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.type,
          'type',
          ApiErrorType.notConfigured,
        ),
      ),
    );
  });

  test('sends bearer token and parses json', () async {
    String? auth;
    final api = ApiClient(
      baseUrl: 'https://api.test/v1/',
      client: MockClient((req) async {
        auth = req.headers['Authorization'];
        expect(req.url.toString(), 'https://api.test/v1/ping');
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
      tokenProvider: () async => 'abc',
    );
    final res = await api.get('/ping');
    expect(res['ok'], true);
    expect(auth, 'Bearer abc');
  });

  test('401 on an authenticated call triggers onUnauthorized', () async {
    var called = false;
    final api = ApiClient(
      baseUrl: 'https://api.test',
      client: MockClient(
        (_) async => http.Response('{"message":"expired"}', 401),
      ),
      tokenProvider: () async => 'abc',
      onUnauthorized: () => called = true,
    );
    await expectLater(
      api.get('/me'),
      throwsA(
        isA<ApiException>().having((e) => e.isSessionExpired, 'expired', true),
      ),
    );
    expect(called, isTrue);
  });

  test('maps socket errors to offline and 5xx to server', () async {
    final offline = ApiClient(
      baseUrl: 'https://api.test',
      client: MockClient((_) async => throw const SocketException('x')),
    );
    await expectLater(
      offline.get('/a'),
      throwsA(isA<ApiException>().having((e) => e.isOffline, 'offline', true)),
    );

    final server = ApiClient(
      baseUrl: 'https://api.test',
      client: MockClient((_) async => http.Response('', 503)),
    );
    await expectLater(
      server.get('/a'),
      throwsA(
        isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.server),
      ),
    );
  });
}
