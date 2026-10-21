import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();

/// Single place that talks HTTP to the future PHP backend.
///
/// * Adds the platform session token (never a Google token) as a Bearer header.
/// * Maps network and HTTP failures to [ApiException].
/// * Calls [onUnauthorized] on 401 so the app can end the session cleanly.
class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.tokenProvider,
    this.onUnauthorized,
  }) : _client = client ?? http.Client(),
       baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).trim();

  final http.Client _client;
  final String baseUrl;
  TokenProvider? tokenProvider;
  void Function()? onUnauthorized;

  bool get isConfigured => baseUrl.isNotEmpty;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth && tokenProvider != null) {
      final t = await tokenProvider!();
      if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
  }) async {
    if (!isConfigured) {
      throw const ApiException(
        ApiErrorType.notConfigured,
        'API base URL is not configured.',
      );
    }
    final uri = _uri(path, query);
    final headers = await _headers(auth: auth);
    final encoded = body == null ? null : jsonEncode(body);
    try {
      final http.Response res;
      switch (method) {
        case 'GET':
          res = await _client
              .get(uri, headers: headers)
              .timeout(AppConfig.requestTimeout);
        case 'POST':
          res = await _client
              .post(uri, headers: headers, body: encoded)
              .timeout(AppConfig.requestTimeout);
        case 'PUT':
          res = await _client
              .put(uri, headers: headers, body: encoded)
              .timeout(AppConfig.requestTimeout);
        case 'PATCH':
          res = await _client
              .patch(uri, headers: headers, body: encoded)
              .timeout(AppConfig.requestTimeout);
        case 'DELETE':
          res = await _client
              .delete(uri, headers: headers)
              .timeout(AppConfig.requestTimeout);
        default:
          throw ArgumentError('Unsupported method $method');
      }
      return _handle(res, auth: auth);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout, 'The request timed out.');
    } on SocketException {
      throw const ApiException(ApiErrorType.offline, 'No internet connection.');
    } on http.ClientException {
      throw const ApiException(
        ApiErrorType.offline,
        'Could not reach the server.',
      );
    } on HandshakeException {
      throw const ApiException(
        ApiErrorType.server,
        'Secure connection failed.',
      );
    }
  }

  dynamic _handle(http.Response res, {required bool auth}) {
    final code = res.statusCode;
    dynamic json;
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(utf8.decode(res.bodyBytes));
      } catch (_) {
        json = null;
      }
    }
    if (code >= 200 && code < 300) return json;

    final msg = (json is Map && json['message'] is String)
        ? json['message'] as String
        : 'Request failed ($code).';
    if (code == 401 && auth) {
      onUnauthorized?.call();
      throw ApiException(ApiErrorType.unauthorized, msg, statusCode: code);
    }
    if (code == 401 || code == 403) {
      throw ApiException(ApiErrorType.unauthorized, msg, statusCode: code);
    }
    if (code == 400 || code == 409 || code == 422) {
      throw ApiException(ApiErrorType.validation, msg, statusCode: code);
    }
    if (code >= 500) {
      throw ApiException(ApiErrorType.server, msg, statusCode: code);
    }
    throw ApiException(ApiErrorType.unknown, msg, statusCode: code);
  }

  void close() => _client.close();
}
