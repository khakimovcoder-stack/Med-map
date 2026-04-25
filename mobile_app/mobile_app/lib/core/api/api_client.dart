import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';

/// Riverpod provider for the secure storage singleton.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Riverpod provider for a configured Dio HTTP client.
/// Adds the auth bearer token, unwraps the standard envelope, and translates errors.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  ApiClient(this._storage) : dio = _createDio() {
    dio.interceptors.add(_AuthInterceptor(_storage));
    dio.interceptors.add(_EnvelopeInterceptor());
  }

  final SecureStorage _storage;
  final Dio dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get<dynamic>(path, queryParameters: query);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
  }) async {
    try {
      final response = await dio.post<dynamic>(path, data: body);
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _translate(e);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Server javobi noto\'g\'ri formatda',
    );
  }

  ApiException _translate(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException();
    }
    final response = e.response;
    if (response == null) {
      return NetworkException(e.message);
    }
    final data = response.data;
    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        final code = err['code']?.toString() ?? 'UNKNOWN';
        final message = err['message']?.toString() ?? 'Noma\'lum xatolik';
        final details = err['details'];
        if (response.statusCode == 401) {
          return UnauthorizedException(message);
        }
        return ApiException(
          code: code,
          message: message,
          statusCode: response.statusCode,
          details: details is Map<String, dynamic> ? details : null,
        );
      }
    }
    return ApiException(
      code: 'HTTP_${response.statusCode}',
      message: 'Server xatosi: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);
  final SecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Unwraps the standard `{success, data, meta}` envelope into just `data`,
/// while still leaving `meta` accessible by storing it on response.extra.
class _EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map && data['success'] == true) {
      response.extra = {
        ...response.extra,
        if (data['meta'] != null) 'meta': data['meta'],
      };
      response.data = {
        'data': data['data'],
        'meta': data['meta'],
      };
    }
    handler.next(response);
  }
}
