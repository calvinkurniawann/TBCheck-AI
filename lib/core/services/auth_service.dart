import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User model for the authenticated user.
class UserData {
  final String id;
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
      id: json['id']?.toString() ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      jenisKelamin: json['jenis_kelamin'] as String?,
      usia: _toInt(json['usia']),
      tinggiBadan: _toDouble(json['tinggi_badan']),
      beratBadan: _toDouble(json['berat_badan']),
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

/// Service for authentication and local profile caching via Supabase Auth.
class AuthService {
  static const _cachedUserKey = 'cached_user';

  SupabaseClient get _client => Supabase.instance.client;

  Future<String?> getToken() async {
    return _client.auth.currentSession?.accessToken;
  }

  Future<void> _cacheUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedUserKey);
  }

  Future<bool> isLoggedIn() async {
    return _client.auth.currentSession != null;
  }

  Future<UserData?> getSavedUser() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      final user = _fromSupabaseUser(currentUser);
      if (user != null) {
        await _cacheUser(user);
        return user;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_cachedUserKey);
    if (userJson != null) {
      return UserData.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

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
    debugPrint('[Auth] Supabase sign up: $email');

    if (password != passwordConfirmation) {
      throw AuthException('Password tidak cocok');
    }

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'jenis_kelamin': jenisKelamin,
          'usia': usia,
          'tinggi_badan': tinggiBadan,
          'berat_badan': beratBadan,
        }..removeWhere((key, value) => value == null),
      );

      final authUser = response.user;
      if (authUser == null) {
        throw AuthException('Registrasi gagal');
      }

      final user = _fromSupabaseUser(authUser) ??
          UserData(
            id: authUser.id,
            name: name,
            email: email,
            jenisKelamin: jenisKelamin,
            usia: usia,
            tinggiBadan: tinggiBadan,
            beratBadan: beratBadan,
          );
      await _cacheUser(user);
      return user;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_mapSupabaseAuthError(e, action: 'Registrasi'));
    }
  }

  Future<UserData> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[Auth] Supabase sign in: $email');

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        throw AuthException('Login gagal');
      }

      final user = _fromSupabaseUser(authUser) ??
          UserData(
            id: authUser.id,
            name: authUser.email?.split('@').first ?? 'Pengguna',
            email: authUser.email ?? email,
          );
      await _cacheUser(user);
      return user;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_mapSupabaseAuthError(e, action: 'Login'));
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Ignore sign-out failures and clear local cache anyway.
    }
    await clearAuth();
  }

  Future<UserData> getProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw AuthException('Belum login');
    }

    final user = _fromSupabaseUser(currentUser);
    if (user == null) {
      throw AuthException('Profil pengguna tidak ditemukan');
    }

    await _cacheUser(user);
    return user;
  }

  UserData? _fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? '';
    if (user.id.isEmpty && email.isEmpty) return null;

    return UserData(
      id: user.id,
      name: (metadata['name'] as String?) ?? email.split('@').first,
      email: email,
      jenisKelamin: metadata['jenis_kelamin'] as String?,
      usia: _toInt(metadata['usia']),
      tinggiBadan: _toDouble(metadata['tinggi_badan']),
      beratBadan: _toDouble(metadata['berat_badan']),
    );
  }
}

String _mapSupabaseAuthError(Object error, {required String action}) {
  final message = error.toString().toLowerCase();

  if (message.contains('email not confirmed') ||
      message.contains('email_not_confirmed')) {
    return 'Email belum dikonfirmasi. Cek inbox/spam untuk link verifikasi.';
  }

  if (message.contains('invalid login credentials') ||
      message.contains('invalid_credentials')) {
    return 'Email atau password salah.';
  }

  if (message.contains('user not found') || message.contains('user_not_found')) {
    return 'Akun tidak ditemukan. Silakan daftar dulu.';
  }

  return '$action gagal: $error';
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
