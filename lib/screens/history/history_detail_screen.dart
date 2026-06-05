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
    final gejalaCodes = symptomCodes
        .where((code) => code.startsWith('G'))
        .toList();
    final riskCodes = symptomCodes
        .where((code) => code.startsWith('R') || code.startsWith('K'))
        .toList();
    final gejalaLabels = gejalaCodes.map(SymptomMapper.codeToLabel).toList();
    final riskLabels = riskCodes.map(SymptomMapper.codeToLabel).toList();

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
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderGray, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: history.riskBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    history.riskIcon,
                    color: history.riskColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  history.riskLabel,
                  style: AppTextStyles.heading3.copyWith(
                    color: history.riskColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(history.timeAgo, style: AppTextStyles.bodyRegular),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Skor CF',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            history.cfScoreRaw.toStringAsFixed(4),
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Persentase Risiko',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${history.riskScore.toStringAsFixed(1)}%',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryMediumBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Saran AI',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'AI-Powered',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Berdasarkan gejala yang Anda alami, kami menyarankan pemeriksaan lanjutan untuk memastikan kondisi kesehatan Anda. Periksakan diri ke tenaga kesehatan jika gejala memburuk.',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.primaryDarkBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Detail Gejala Terdeteksi',
                      style: AppTextStyles.heading3,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Gejala (${gejalaLabels.length})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 12),
                if (gejalaLabels.isEmpty)
                  Text(
                    'Tidak ada gejala terdeteksi pada pemeriksaan ini.',
                    style: AppTextStyles.bodyRegular,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: gejalaLabels
                        .map(
                          (label) => _DetailTag(
                            label: label,
                            color: AppColors.riskHighBg,
                            textColor: AppColors.riskHigh,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.shield_sharp,
                      color: AppColors.warningOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text('Faktor Risiko', style: AppTextStyles.heading3),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Faktor Risiko (${riskLabels.length})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 12),
                if (riskLabels.isEmpty)
                  Text(
                    'Tidak ada faktor risiko yang terdeteksi.',
                    style: AppTextStyles.bodyRegular,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: riskLabels
                        .map(
                          (label) => _DetailTag(
                            label: label,
                            color: AppColors.warningOrangeBg,
                            textColor: AppColors.warningOrange,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _DetailTag({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
