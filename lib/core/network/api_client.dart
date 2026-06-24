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
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.instance.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) async {
        if (!_isConnectivityError(e)) {
          handler.next(e);
          return;
        }
        await _waitForRetry();
        try {
          // Retrying via fetch() re-enters this same interceptor on
          // failure, so a still-offline retry naturally reshows the dialog.
          final response = await dio.fetch(e.requestOptions);
          handler.resolve(response);
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ));

    if (AppConfig.instance.isDev) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
  }

  bool _isConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.error is SocketException;
  }

  Future<void> _waitForRetry() {
    if (_retryGate != null) return _retryGate!.future;
    final gate = Completer<void>();
    _retryGate = gate;
    NoInternetDialog.show(
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
