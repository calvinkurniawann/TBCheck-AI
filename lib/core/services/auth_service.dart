import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

/// User model for the authenticated user.
class UserData {
  final int id;
  final String name;
  final String email;
  final String? jenisKelamin;
  final int? usia;
  final double? tinggiBadan;
  final double? beratBadan;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    this.jenisKelamin,
    this.usia,
    this.tinggiBadan,
    this.beratBadan,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      jenisKelamin: json['jenis_kelamin'] as String?,
      usia: json['usia'] as int?,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'jenis_kelamin': jenisKelamin,
        'usia': usia,
        'tinggi_badan': tinggiBadan,
        'berat_badan': beratBadan,
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

/// Service for authentication: login, register, profile management.
/// Stores token + user data in SharedPreferences.
class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // ─── Token Management ───

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> _saveAuth(String token, UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserData?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserData.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Register ───

  Future<UserData> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? jenisKelamin,
    int? usia,
    double? tinggiBadan,
    double? beratBadan,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/register');
    debugPrint('[Auth] POST $uri');

    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
        if (usia != null) 'usia': usia,
        if (tinggiBadan != null) 'tinggi_badan': tinggiBadan,
        if (beratBadan != null) 'berat_badan': beratBadan,
      };

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('[Auth] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final user = UserData.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;
        await _saveAuth(token, user);
        return user;
      } else if (response.statusCode == 422) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = (errors.values.first as List).first as String;
          throw AuthException(firstError);
        }
        throw AuthException(json['message'] as String? ?? 'Validasi gagal');
      } else {
        throw AuthException('Registrasi gagal (${response.statusCode})');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Gagal terhubung ke server: $e');
    }
  }

  // ─── Login ───

  Future<UserData> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/login');
    debugPrint('[Auth] POST $uri');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('[Auth] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        final user = UserData.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;
        await _saveAuth(token, user);
        return user;
      } else if (response.statusCode == 422) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final errors = json['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = (errors.values.first as List).first as String;
          throw AuthException(firstError);
        }
        throw AuthException(json['message'] as String? ?? 'Login gagal');
      } else {
        throw AuthException('Login gagal (${response.statusCode})');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Gagal terhubung ke server: $e');
    }
  }

  // ─── Logout ───

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _client.post(
          Uri.parse('${ApiConfig.baseUrl}/api/logout'),
          headers: _authHeaders(token),
        );
      } catch (_) {
        // Ignore network errors during logout
      }
    }
    await clearAuth();
  }

  // ─── Profile ───

  Future<UserData> getProfile() async {
    final token = await getToken();
    if (token == null) throw AuthException('Belum login');

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/profile');
    final response = await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = UserData.fromJson(json['data'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    } else if (response.statusCode == 401) {
      await clearAuth();
      throw AuthException('Sesi telah berakhir, silakan login ulang');
    } else {
      throw AuthException('Gagal memuat profil');
    }
  }

  void dispose() {
    _client.close();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
