/// Translated, user-facing exception thrown by the API client.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}

/// Thrown when the device has no connectivity or the host is unreachable.
class NetworkException extends ApiException {
  const NetworkException([String? message])
    : super(
        code: 'NETWORK_ERROR',
        message: message ?? 'Internet aloqasi yo\'q yoki server javob bermayapti',
      );
}

/// Thrown when an authenticated endpoint is hit without a valid token.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
    : super(
        code: 'UNAUTHORIZED',
        message: message ?? 'Tizimga qayta kiring',
        statusCode: 401,
      );
}
