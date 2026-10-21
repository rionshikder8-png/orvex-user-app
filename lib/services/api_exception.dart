enum ApiErrorType {
  notConfigured,
  offline,
  timeout,
  unauthorized,
  validation,
  server,
  unknown,
}

/// A clear, typed error from the API layer. UI code decides how to present it.
class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  bool get isSessionExpired => type == ApiErrorType.unauthorized;
  bool get isNotConfigured => type == ApiErrorType.notConfigured;
  bool get isOffline => type == ApiErrorType.offline;

  @override
  String toString() => 'ApiException($type, $statusCode): $message';
}
