import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_config.dart';

/// Screening result returned from Supabase RPC.
class ScreeningResult {
  final double cfScoreRaw;
  final double cfScorePercentage;
  final String riskLevel;
  final String aiAdvice;

  const ScreeningResult({
    required this.cfScoreRaw,
    required this.cfScorePercentage,
    required this.riskLevel,
    required this.aiAdvice,
  });

  factory ScreeningResult.fromJson(Map<String, dynamic> json) {
    return ScreeningResult(
      cfScoreRaw: _toDouble(json['cf_score_raw']) ?? 0,
      cfScorePercentage: _toDouble(json['cf_score_percentage']) ?? 0,
      riskLevel: (json['risk_level'] as String?) ?? 'Rendah',
      aiAdvice: (json['ai_advice'] as String?) ?? '',
    );
  }
}

/// History item returned from Supabase.
class ScreeningHistoryItem {
  final int id;
  final List<String> selectedSymptoms;
  final double cfScoreRaw;
  final double cfScorePercentage;
  final String riskLevel;
  final DateTime createdAt;

  const ScreeningHistoryItem({
    required this.id,
    required this.selectedSymptoms,
    required this.cfScoreRaw,
    required this.cfScorePercentage,
    required this.riskLevel,
    required this.createdAt,
  });

  factory ScreeningHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawSymptoms = json['selected_symptoms'];
    final symptoms = rawSymptoms is List
        ? rawSymptoms.map((item) => item.toString()).toList()
        : <String>[];

    return ScreeningHistoryItem(
      id: _toInt(json['id']) ?? 0,
      selectedSymptoms: symptoms,
      cfScoreRaw: _toDouble(json['cf_score_raw']) ?? 0,
      cfScorePercentage: _toDouble(json['cf_score_percentage']) ?? 0,
      riskLevel: _normalizeRiskLevel(json['risk_level']?.toString() ?? 'Rendah'),
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  /// Count symptoms that start with 'G' (gejala)
  int get gejalaTerdeteksi =>
      selectedSymptoms.where((s) => s.startsWith('G')).length;

  /// Count symptoms that start with 'R' (risiko) or 'K' (komorbid)
  int get faktorRisiko =>
      selectedSymptoms.where((s) => s.startsWith('R') || s.startsWith('K')).length;
}

/// Service class handling screening calculation and history in Supabase.
class ScreeningApiService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Submit screening data to a Supabase RPC function.
  Future<ScreeningResult> submitScreening({
    required List<String> selectedSymptomCodes,
  }) async {
    debugPrint('[Supabase] RPC ${SupabaseConfig.screeningRpc}');
    debugPrint('[Supabase] Symptoms: $selectedSymptomCodes');

    try {
      final response = await _client.rpc(
        SupabaseConfig.screeningRpc,
        params: {'selected_symptoms': selectedSymptomCodes},
      );

      final data = _extractResultData(response);
      if (data == null) {
        throw ApiException(
          'RPC ${SupabaseConfig.screeningRpc} tidak mengembalikan data hasil.',
        );
      }

      final result = ScreeningResult.fromJson(data);
      await _saveHistory(selectedSymptomCodes: selectedSymptomCodes, result: result);
      return result;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Gagal menghitung screening di Supabase: $e. Pastikan RPC "${SupabaseConfig.screeningRpc}" sudah dibuat.',
      );
    }
  }

  /// Fetch screening history for the current authenticated user.
  Future<List<ScreeningHistoryItem>> getHistory() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw ApiException('Belum login');
    }

    debugPrint('[Supabase] GET ${SupabaseConfig.historyTable} for ${authUser.id}');

    try {
      final response = await _client
          .from(SupabaseConfig.historyTable)
          .select('id, selected_symptoms, cf_score_raw, cf_score_percentage, risk_level, created_at')
          .eq('user_id', authUser.id)
          .order('created_at', ascending: false);

      final rows = response as List<dynamic>;
      return rows
          .map((item) => ScreeningHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiException('Gagal memuat riwayat dari Supabase: $e');
    }
  }

  Future<void> _saveHistory({
    required List<String> selectedSymptomCodes,
    required ScreeningResult result,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      return;
    }

    await _client.from(SupabaseConfig.historyTable).insert({
      'user_id': authUser.id,
      'selected_symptoms': selectedSymptomCodes,
      'cf_score_raw': result.cfScoreRaw,
      'cf_score_percentage': result.cfScorePercentage,
      'risk_level': result.riskLevel,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {}
}

Map<String, dynamic>? _extractResultData(dynamic response) {
  if (response is Map<String, dynamic>) {
    if (response['data'] is Map<String, dynamic>) {
      return response['data'] as Map<String, dynamic>;
    }
    return response;
  }

  if (response is List && response.isNotEmpty && response.first is Map<String, dynamic>) {
    return response.first as Map<String, dynamic>;
  }

  return null;
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

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String _normalizeRiskLevel(String value) {
  final lower = value.toLowerCase();
  if (lower == 'tinggi') return 'Tinggi';
  if (lower == 'sedang') return 'Sedang';
  return 'Rendah';
}

/// Custom exception for Supabase errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
