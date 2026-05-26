import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

/// Screening result returned from the backend API.
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
      cfScoreRaw: (json['cf_score_raw'] as num).toDouble(),
      cfScorePercentage: (json['cf_score_percentage'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      aiAdvice: json['ai_advice'] as String,
    );
  }
}

/// History item returned from the backend API.
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
    return ScreeningHistoryItem(
      id: json['id'] as int,
      selectedSymptoms: List<String>.from(json['selected_symptoms'] ?? []),
      cfScoreRaw: (json['cf_score_raw'] as num).toDouble(),
      cfScorePercentage: (json['cf_score_percentage'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Count symptoms that start with 'G' (gejala)
  int get gejalaTerdeteksi =>
      selectedSymptoms.where((s) => s.startsWith('G')).length;

  /// Count symptoms that start with 'R' (risiko) or 'K' (komorbid)
  int get faktorRisiko =>
      selectedSymptoms.where((s) => s.startsWith('R') || s.startsWith('K')).length;
}

/// Service class handling all API communication with the Laravel backend.
class ScreeningApiService {
  final http.Client _client;

  ScreeningApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Submit screening data to the backend for risk calculation.
  Future<ScreeningResult> submitScreening({
    required List<String> selectedSymptomCodes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.screeningCalculate}');
    final headers = await _authHeaders();

    debugPrint('[API] POST $uri');
    debugPrint('[API] Symptoms: $selectedSymptomCodes');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'selected_symptoms': selectedSymptomCodes,
        }),
      );

      debugPrint('[API] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          return ScreeningResult.fromJson(json['data'] as Map<String, dynamic>);
        }
        throw ApiException('Server returned success=false');
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  /// Fetch screening history for a user from the backend.
  Future<List<ScreeningHistoryItem>> getHistory() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/screening/history');
    final headers = await _authHeaders();

    debugPrint('[API] GET $uri');

    try {
      final response = await _client.get(
        uri,
        headers: headers,
      );

      debugPrint('[API] Response ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true) {
          final list = json['data'] as List<dynamic>;
          return list
              .map((item) =>
                  ScreeningHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw ApiException('Server returned success=false');
      } else {
        throw ApiException(
          'HTTP ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}
