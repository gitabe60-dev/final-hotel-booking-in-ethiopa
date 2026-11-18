/// api_service.dart  
/// Two Dio instances — mirrors the web frontend exactly:
///   _api      → baseURL: /api/v1      (guest JWT stored as 'token')
///   _adminApi → baseURL: /api/admin   (admin JWT stored as 'admin_token')
library;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _api;
  late final Dio _adminApi;

  void init() {
    // ── Guest API  /api/v1 ────────────────────────────────────────────────
    _api = Dio(BaseOptions(
      baseUrl:        ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers:        {'Content-Type': 'application/json'},
    ));
    _api.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(opts);
      },
      onError: (err, handler) {
        if (err.response?.statusCode == 401) {
          final url = err.requestOptions.path;
          final isAuth = url.contains('/auth/');
          if (!isAuth) {
            SharedPreferences.getInstance().then((p) {
              p.remove('token');
              p.remove('user');
            });
          }
        }
        handler.next(err);
      },
    ));

    // ── Admin API  /api/admin ─────────────────────────────────────────────
    _adminApi = Dio(BaseOptions(
      baseUrl:        ApiConstants.adminBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers:        {'Content-Type': 'application/json'},
    ));
    _adminApi.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('admin_token');
        if (token != null && token.isNotEmpty) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(opts);
      },
      onError: (err, handler) {
        if (err.response?.statusCode == 401) {
          SharedPreferences.getInstance().then((p) => p.remove('admin_token'));
        }
        handler.next(err);
      },
    ));
  }

  Dio get dio      => _api;
  Dio get adminDio => _adminApi;

  // ── Guest API helpers ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? params}) async {
    try {
      final r = await _api.get(path, queryParameters: params);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final r = await _api.post(path, data: data);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final r = await _api.put(path, data: data);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final r = await _api.delete(path);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  // ── Admin API helpers ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> adminGet(String path,
      {Map<String, dynamic>? params}) async {
    try {
      final r = await _adminApi.get(path, queryParameters: params);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> adminPost(String path, {dynamic data}) async {
    try {
      final r = await _adminApi.post(path, data: data);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> adminPut(String path, {dynamic data}) async {
    try {
      final r = await _adminApi.put(path, data: data);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  Future<Map<String, dynamic>> adminDelete(String path) async {
    try {
      final r = await _adminApi.delete(path);
      return _check(r.data);
    } on DioException catch (e) { throw _parse(e); }
  }

  // ── Check success:false even on HTTP 200 ─────────────────────────────────
  // The Go backend always returns { success, message, data }.
  // If success == false, treat it as an error regardless of HTTP status.
  Map<String, dynamic> _check(dynamic body) {
    if (body is Map<String, dynamic>) {
      final success = body['success'];
      if (success == false) {
        final msg = body['message'] as String? ?? 'Request failed.';
        throw ApiException(msg, statusCode: 400);
      }
      return body;
    }
    return body as Map<String, dynamic>;
  }

  // ── Error parser ──────────────────────────────────────────────────────────
  ApiException _parse(DioException e) {
    final data = e.response?.data;
    String? msg;
    if (data is Map) msg = data['message'] as String?;
    return ApiException(
      msg ?? _statusMsg(e.response?.statusCode) ?? 'Connection failed. Check server is running.',
      statusCode: e.response?.statusCode,
    );
  }

  String? _statusMsg(int? code) {
    switch (code) {
      case 400: return 'Invalid request. Check your input.';
      case 401: return 'Invalid email or password.';
      case 403: return 'Your account is not active.';
      case 404: return 'Not found.';
      case 409: return 'Account already exists.';
      case 422: return 'Validation error.';
      case 500: return 'Server error. Please try again.';
      default:  return null;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  const ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}
