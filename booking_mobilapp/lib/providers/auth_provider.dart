/// auth_provider.dart
///
/// Mirrors the web frontend auth service exactly:
///   - Guest login  → POST /api/v1/auth/login         → stores 'token'
///   - Admin login  → POST /api/admin/login            → stores 'admin_token'
///   - Register     → POST /api/v1/auth/register       → stores 'token'
///   - OTP          → POST /api/v1/auth/otp/send|verify
///   - Logout       → POST /api/v1/auth/logout         → clears both tokens
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_endpoints.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status  = AuthStatus.unknown;
  User?      _user;
  String?    _token;
  String?    _error;
  bool       _loading = false;

  AuthStatus get status       => _status;
  User?      get user         => _user;
  String?    get token        => _token;
  String?    get error        => _error;
  bool       get loading      => _loading;
  bool       get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Bootstrap: restore saved session ──────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final tok   = prefs.getString('token') ?? prefs.getString('admin_token');
    final raw   = prefs.getString('user');
    if (tok != null && raw != null) {
      try {
        _user   = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        _token  = tok;
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUEST REGISTER  — POST /api/v1/auth/register
  // Same as web: authService.register(...)
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    required String password,
    String? nationality,
  }) async {
    _setLoading(true);
    try {
      final res = await ApiService.instance.post(
        ApiEndpoints.register,
        data: {
          'first_name': firstName,
          'last_name':  lastName,
          if (email != null && email.isNotEmpty)       'email':    email,
          if (phone != null && phone.isNotEmpty)       'phone':    phone,
          'password': password,
          if (nationality != null && nationality.isNotEmpty) 'nationality': nationality,
        },
      );
      // Response: { data: { user: {...}, token: "..." } }
      final data    = res['data'] as Map<String, dynamic>;
      final token   = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final role    = _extractRoleFromJwt(token) ?? 'user';
      userMap['role'] = role;
      await _persistGuestSession(User.fromJson(userMap), token);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN  — tries admin first (if credentials match admin pattern), then guest
  //
  // Backend routes:
  //   Guest: POST /api/v1/auth/login     → { data: { user, token } }
  //   Admin: POST /api/admin/login       → { data: { admin, token } }
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _error = null;

    // ── Step 1: Always try Admin API first ──────────────────────────────────
    // Admin credentials only work on /api/admin/login; guest credentials only
    // work on /api/v1/auth/login. Trying admin first avoids a double round-trip
    // for admin users, and the guest fallback handles all guest logins.
    try {
      final res   = await ApiService.instance.adminPost(
        ApiEndpoints.adminLogin,
        data: {'email': email, 'password': password},
      );
      final data  = res['data'] as Map<String, dynamic>;
      final admin = data['admin'] as Map<String, dynamic>;
      final token = data['token'] as String;

      final fullName  = admin['full_name'] as String? ?? '';
      final parts     = fullName.trim().split(RegExp(r'\s+'));
      final firstName = parts.isNotEmpty ? parts.first : 'Admin';
      final lastName  = parts.length > 1 ? parts.skip(1).join(' ') : '';

      final user = User(
        id:        admin['id'] as int? ?? 0,
        firstName: firstName,
        lastName:  lastName,
        email:     admin['email'] as String?,
        phone:     admin['phone'] as String?,
        role:      admin['role'] as String? ?? 'super_admin',
      );

      await _persistAdminSession(user, token);
      _setLoading(false);
      return true;
    } on ApiException catch (adminErr) {
      // Admin login only fails with wrong credentials (401) or inactive (403).
      // Any other error (network, 500) surfaces immediately.
      final code = adminErr.statusCode ?? 0;
      if (code != 401 && code != 400 && code != 422 && code != 403) {
        _error = adminErr.message;
        notifyListeners();
        _setLoading(false);
        return false;
      }
      // Otherwise fall through to guest login
    }

    // ── Step 2: Guest API: POST /api/v1/auth/login ──────────────────────────
    try {
      final res     = await ApiService.instance.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data    = res['data'] as Map<String, dynamic>;
      final token   = data['token'] as String;
      final userMap = data['user'] as Map<String, dynamic>;
      final role    = _extractRoleFromJwt(token) ?? 'user';
      userMap['role'] = role;
      await _persistGuestSession(User.fromJson(userMap), token);
      _setLoading(false);
      return true;
    } on ApiException catch (guestErr) {
      _error = guestErr.message;
      notifyListeners();
      _setLoading(false);
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OTP SEND  — POST /api/v1/auth/otp/send
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> sendOtp(String phone, {String purpose = 'login'}) async {
    _setLoading(true);
    try {
      await ApiService.instance.post(
        ApiEndpoints.otpSend,
        data: {'phone': phone, 'purpose': purpose},
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message; notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OTP VERIFY  — POST /api/v1/auth/otp/verify
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String phone, String otp,
      {String purpose = 'login'}) async {
    _setLoading(true);
    try {
      final res  = await ApiService.instance.post(
        ApiEndpoints.otpVerify,
        data: {'phone': phone, 'otp': otp, 'purpose': purpose},
      );
      final data = res['data'] as Map<String, dynamic>;
      if (data['user'] != null && data['token'] != null) {
        final token   = data['token'] as String;
        final userMap = data['user'] as Map<String, dynamic>;
        final role    = _extractRoleFromJwt(token) ?? 'user';
        userMap['role'] = role;
        await _persistGuestSession(User.fromJson(userMap), token);
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message; notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD  — POST /api/v1/auth/forgot-password
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> forgotPassword({String? email, String? phone}) async {
    _setLoading(true);
    try {
      await ApiService.instance.post(
        ApiEndpoints.forgotPassword,
        data: {
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message; notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET PASSWORD  — POST /api/v1/auth/reset-password
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> resetPassword(
      String phone, String otp, String newPassword) async {
    _setLoading(true);
    try {
      await ApiService.instance.post(
        ApiEndpoints.resetPassword,
        data: {'phone': phone, 'otp': otp, 'password': newPassword},
      );
      return true;
    } on ApiException catch (e) {
      _error = e.message; notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE GUEST PROFILE  — PUT /api/v1/guest/profile
  // Same as web: guestService.updateProfile(...)
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? nationality,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      final res = await ApiService.instance.put(
        ApiEndpoints.guestProfile,
        data: {
          'first_name': firstName,
          'last_name':  lastName,
          if (phone != null && phone.isNotEmpty)             'phone':       phone,
          if (nationality != null && nationality.isNotEmpty) 'nationality': nationality,
        },
      );
      // Response: { data: { user: {...} } }  OR just { data: {...user fields} }
      final raw     = res['data'];
      final userMap = raw is Map && raw.containsKey('user')
          ? raw['user'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      final updated = User.fromJson(userMap);
      _user = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(updated.toJson()));
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message; notifyListeners(); return false;
    } finally { _setLoading(false); }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGOUT  — POST /api/v1/auth/logout  (clears BOTH tokens)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await ApiService.instance.post(ApiEndpoints.logout);
    } catch (_) {} // stateless JWT — ignore errors
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('admin_token');
    await prefs.remove('user');
    _user   = null;
    _token  = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session persistence helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Guest session: stores 'token' (mirrors web localStorage.setItem('token'))
  Future<void> _persistGuestSession(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user',  jsonEncode(user.toJson()));
    await prefs.remove('admin_token'); // clear admin token on guest login
    _user   = user;
    _token  = token;
    _status = AuthStatus.authenticated;
    _error  = null;
    notifyListeners();
  }

  /// Admin session: stores 'admin_token' (mirrors web localStorage.setItem('admin_token'))
  Future<void> _persistAdminSession(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
    await prefs.setString('user',        jsonEncode(user.toJson()));
    await prefs.remove('token'); // clear guest token on admin login
    _user   = user;
    _token  = token;
    _status = AuthStatus.authenticated;
    _error  = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    if (v) _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Decode JWT and extract role field ─────────────────────────────────────
  // The Go backend stores role in JWT payload as "role": "user" / "super_admin" etc.
  // The /api/v1/auth/login user object does NOT include role, so we decode JWT.
  String? _extractRoleFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      // JWT payload is base64url encoded — pad to multiple of 4
      var payload = parts[1];
      final pad   = payload.length % 4;
      if (pad != 0) payload += '=' * (4 - pad);
      // Replace base64url chars
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64Decode(payload));
      final map     = jsonDecode(decoded) as Map<String, dynamic>;
      return map['role'] as String?;
    } catch (_) {
      return null;
    }
  }
}
