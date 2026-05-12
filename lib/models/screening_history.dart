import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum RiskLevel { rendah, sedang, tinggi }

class ScreeningHistory {
  final String id;
  final DateTime date;
  final RiskLevel riskLevel;
  final double riskScore;
  final int gejalaTerdeteksi;
  final int faktorRisiko;

  const ScreeningHistory({
    required this.id,
    required this.date,
    required this.riskLevel,
    required this.riskScore,
    required this.gejalaTerdeteksi,
    required this.faktorRisiko,
  });

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.rendah:
        return 'Risiko Rendah';
      case RiskLevel.sedang:
        return 'Risiko Sedang';
      case RiskLevel.tinggi:
        return 'Risiko Tinggi';
    }
  }

  Color get riskColor {
    switch (riskLevel) {
      case RiskLevel.rendah:
        return AppColors.riskLow;
      case RiskLevel.sedang:
        return AppColors.riskMedium;
      case RiskLevel.tinggi:
        return AppColors.riskHigh;
    }
  }

  Color get riskBgColor {
    switch (riskLevel) {
      case RiskLevel.rendah:
        return AppColors.riskLowBg;
      case RiskLevel.sedang:
        return AppColors.riskMediumBg;
      case RiskLevel.tinggi:
        return AppColors.riskHighBg;
    }
  }

  IconData get riskIcon {
    switch (riskLevel) {
      case RiskLevel.rendah:
        return Icons.check_circle_rounded;
      case RiskLevel.sedang:
        return Icons.warning_rounded;
      case RiskLevel.tinggi:
        return Icons.dangerous_rounded;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  static List<ScreeningHistory> mockData() {
    final now = DateTime.now();
    return [
      ScreeningHistory(
        id: '1',
        date: now.subtract(const Duration(days: 2)),
        riskLevel: RiskLevel.rendah,
        riskScore: 15.0,
        gejalaTerdeteksi: 1,
        faktorRisiko: 0,
      ),
      ScreeningHistory(
        id: '2',
        date: now.subtract(const Duration(days: 8)),
        riskLevel: RiskLevel.sedang,
        riskScore: 45.0,
        gejalaTerdeteksi: 3,
        faktorRisiko: 2,
      ),
      ScreeningHistory(
        id: '3',
        date: now.subtract(const Duration(days: 21)),
        riskLevel: RiskLevel.rendah,
        riskScore: 10.0,
        gejalaTerdeteksi: 0,
        faktorRisiko: 1,
      ),
      ScreeningHistory(
        id: '4',
        date: now.subtract(const Duration(days: 45)),
        riskLevel: RiskLevel.tinggi,
        riskScore: 78.0,
        gejalaTerdeteksi: 5,
        faktorRisiko: 3,
      ),
    ];
  }
}
