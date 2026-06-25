import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../presentation/widgets/no_internet_dialog.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  // Shared by concurrent requests so simultaneous failures only ever
  // surface one dialog; everyone waiting resumes together on Retry.
  Completer<void>? _retryGate;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 45),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (e, handler) async {
          final issue = _connectionIssue(e);
          if (issue == null) {
            handler.next(e);
            return;
          }
          await _waitForRetry(issue);
          try {
            // Retrying via fetch() re-enters this same interceptor on
            // failure, so a still-offline/still-asleep retry naturally
            // reshows the appropriate dialog.
            final response = await dio.fetch(e.requestOptions);
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );

    if (AppConfig.instance.isDev) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// `null` means the failure isn't connectivity-related (e.g. a 4xx/5xx
  /// from a live server) and should just propagate normally.
  ConnectionIssue? _connectionIssue(DioException e) {
    // Connection/TCP-level failures: device genuinely has no route to the
    // server (Wi-Fi off, DNS failure, etc).
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.error is SocketException) {
      return ConnectionIssue.offline;
    }
    // The server was reached but didn't respond in time — typically a
    // Render free-tier instance cold-starting after idling, not a real
    // connectivity problem.
    if (e.type == DioExceptionType.receiveTimeout) {
      return ConnectionIssue.serverWaking;
    }
    return null;
  }

  Future<void> _waitForRetry(ConnectionIssue issue) {
    if (_retryGate != null) return _retryGate!.future;
    final gate = Completer<void>();
    _retryGate = gate;
    NoInternetDialog.show(
      issue: issue,
      onRetry: () {
        _retryGate = null;
        gate.complete();
      },
    );
    return gate.future;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      dio.post(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      dio.patch(path, data: data);

  Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'jwt_token');

  Future<bool> hasToken() async =>
      await _storage.read(key: 'jwt_token') != null;
}
