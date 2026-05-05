import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/primary_button.dart';

class Step4KeluhanTambahan extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onSubmit;

  const Step4KeluhanTambahan({
    super.key,
    required this.data,
    required this.onSubmit,
  });

  @override
  State<Step4KeluhanTambahan> createState() => _Step4KeluhanTambahanState();
}

class _Step4KeluhanTambahanState extends State<Step4KeluhanTambahan> {
  late TextEditingController _keluhanController;

  @override
  void initState() {
    super.initState();
    _keluhanController = TextEditingController(
      text: widget.data.keluhanTambahan ?? '',
    );
  }

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    widget.data.keluhanTambahan = _keluhanController.text.trim().isEmpty
        ? null
        : _keluhanController.text.trim();
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS ANALISIS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentTeal,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentTealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Terakhir',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Langkah 4 dari 4',
            style: AppTextStyles.heading1.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 24),

          // Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.selectedBlueBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primaryMediumBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluhan Tambahan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          Text(
                            'Detail medis tambahan opsional',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Text area
                Text(
                  'Tuliskan keluhan lain yang Anda rasakan (opsional)',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGray),
                  ),
                  child: TextField(
                    controller: _keluhanController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Contoh: sesak napas, mudah lelah, nyeri dada, dll',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textLightGray,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgInfoBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryLightBlue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.primaryMediumBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Memberikan analisis yang lebih lengkap. Informasi Anda bersifat rahasia aman dan hanya digunakan untuk analisis.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDarkBlue,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Warning box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningOrangeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: AppColors.warningOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mengapa ini penting?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dengan mengisi "Analisis Sekarang", Anda menyetujui bahwa informasi diberikan konteks khusus bagi AI untuk memberikan penjelasan dan analisis risiko saran yang lebih spesifik. Ini adalah alat bantu informasi dan bukan pengganti diagnosis medis profesional.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'Analisis Sekarang',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentTeal,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
