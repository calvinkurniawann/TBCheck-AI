import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/symptom_mapper.dart';
import '../../models/screening_history.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScreeningHistory history;

  const HistoryDetailScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final symptomCodes = history.selectedSymptoms ?? const <String>[];
    final symptomLabels = symptomCodes.map(SymptomMapper.codeToLabel).toList();

    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      appBar: AppBar(
        title: const Text('Detail Skrining'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          tooltip: 'Kembali',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: history.riskBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    history.riskIcon,
                    color: history.riskColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.riskLabel,
                        style: AppTextStyles.heading3.copyWith(
                          color: history.riskColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${history.timeAgo} • Skor: ${history.riskScore.toStringAsFixed(0)}%',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Jawaban', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          if (symptomLabels.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Text(
                'Jawaban skrining tidak tersedia untuk riwayat ini.',
                style: AppTextStyles.bodyRegular,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: symptomLabels
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgLightGray,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: Text(
                          label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          Text('Ringkasan', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Row(
              children: [
                _SummaryChip(
                  icon: Icons.coronavirus_outlined,
                  label: '${history.gejalaTerdeteksi} gejala',
                ),
                const SizedBox(width: 12),
                _SummaryChip(
                  icon: Icons.warning_amber_rounded,
                  label: '${history.faktorRisiko} risiko',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgLightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.iconGray),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
