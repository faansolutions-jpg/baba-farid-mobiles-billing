/// Dio API client for the Baba Farid Mobiles backend.
///
/// Base URL comes from [AppConfig] (`lib/core/config/app_config.dart`,
/// owned by another agent). Per DECISIONS.md decision 4 the configured
/// base URL already ends in `/api/v1`, so this client strips that suffix
/// to obtain the server origin and all request paths below are written
/// in full (`/api/v1/login`, ...).
///
/// Behaviour:
/// * every request carries `Authorization: Bearer <access token>` when
///   a token is available (via [AuthService]);
/// * a 401 triggers one token refresh via
///   [AuthService.refreshToken] and retries the request once;
/// * the backend envelope `{ok, data, error}` is unwrapped — helpers
///   return `data`, and failures throw [ApiException].
library;

import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/services/auth_service.dart';

/// Typed API failure. [statusCode] is the HTTP status when known.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() =>
      'ApiException($statusCode): $message';
}

class ApiClient {
  final Dio dio;

  /// Set (or replaced) by the composition root after the auth service
  /// is built: `client.authService = apiAuthService`. Kept mutable
  /// because [ApiAuthService] itself needs this client to log in.
  AuthService? authService;

  ApiClient({String? baseUrl, this.authService})
      : dio = Dio(BaseOptions(
          baseUrl: _origin(baseUrl ?? AppConfig.apiBaseUrl),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await authService?.accessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Auth calls must never trigger a refresh loop: the real auth
        // paths are /api/v1/login, /api/v1/refresh, /api/v1/logout.
        final path = error.requestOptions.path;
        final isAuthCall = path == '/api/v1/login' ||
            path == '/api/v1/refresh' ||
            path == '/api/v1/logout';
        final alreadyRetried =
            error.requestOptions.extra['retried'] == true;
        if (error.response?.statusCode == 401 &&
            !isAuthCall &&
            !alreadyRetried &&
            authService != null) {
          try {
            await authService!.refreshToken();
            final token = await authService!.accessToken();
            final options = error.requestOptions;
            options.extra['retried'] = true;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            // Refresh failed: fall through to the mapped 401 below.
          }
        }
        handler.reject(error);
      },
    ));
  }

  /// `AppConfig.apiBaseUrl` is `http://host:3000/api/v1` per
  /// DECISIONS.md; Dio needs the origin because paths carry `/api/v1`.
  static String _origin(String baseUrl) {
    var url = baseUrl.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (url.endsWith('/api/v1')) {
      url = url.substring(0, url.length - '/api/v1'.length);
    }
    return url;
  }

  /// Unwraps the `{ok, data, error}` envelope. Non-envelope bodies
  /// are returned as-is.
  dynamic _unwrap(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['ok'] == false) {
        final error = body['error'];
        final message = error is Map
            ? (error['message'] ?? 'Request failed').toString()
            : (error ?? 'Request failed').toString();
        final code =
            error is Map ? error['code']?.toString() : null;
        throw ApiException(
          message,
          statusCode: response.statusCode,
          code: code,
        );
      }
      if (body.containsKey('data')) return body['data'];
    }
    return body;
  }

  Never _mapError(DioException error) {
    if (error is ApiException) throw error;
    final status = error.response?.statusCode;
    final body = error.response?.data;
    String message = error.message ?? 'Network error';
    String? code;
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map) {
        message = (err['message'] ?? message).toString();
        code = err['code']?.toString();
      } else if (err is String) {
        message = err;
      } else if (body['message'] is String) {
        message = body['message'] as String;
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Server did not respond in time. Check your connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server. You are probably offline.';
    }
    throw ApiException(message, statusCode: status, code: code);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      _mapError(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await dio.post(path, data: data);
      return _unwrap(response);
    } on DioException catch (e) {
      _mapError(e);
    }
  }

  Future<dynamic> put(String path, {Object? data}) async {
    try {
      final response = await dio.put(path, data: data);
      return _unwrap(response);
    } on DioException catch (e) {
      _mapError(e);
    }
  }

  Future<dynamic> delete(String path, {Object? data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return _unwrap(response);
    } on DioException catch (e) {
      _mapError(e);
    }
  }
}
