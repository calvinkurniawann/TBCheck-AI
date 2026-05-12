import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/multi_select_chip.dart';
import '../../widgets/primary_button.dart';

class Step3GejalaSistemik extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onNext;

  const Step3GejalaSistemik({super.key, required this.data, required this.onNext});

  @override
  State<Step3GejalaSistemik> createState() => _Step3GejalaSistemikState();
}

class _Step3GejalaSistemikState extends State<Step3GejalaSistemik>
    with SingleTickerProviderStateMixin {
  late List<String> _selected;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  static const _options = [
    MultiSelectOption(
      label: 'Demam lama / meriang (> 3 minggu)',
      value: 'demam_lama',
      icon: Icons.thermostat_outlined,
    ),
    MultiSelectOption(
      label: 'Penurunan berat badan drastis',
      value: 'penurunan_bb',
      icon: Icons.trending_down_rounded,
    ),
    MultiSelectOption(
      label: 'Penurunan nafsu makan',
      value: 'nafsu_makan_turun',
      icon: Icons.no_food_rounded,
    ),
    MultiSelectOption(
      label: 'Lemah / Lemas (Malaise)',
      value: 'malaise',
      icon: Icons.battery_1_bar_rounded,
    ),
    MultiSelectOption(
      label: 'Sesak napas / nyeri dada',
      value: 'sesak_napas',
      icon: Icons.air_rounded,
    ),
    MultiSelectOption(
      label: 'Keringat malam tanpa aktivitas',
      value: 'keringat_malam',
      icon: Icons.nightlight_round,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.data.gejalaSistemik);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleNext() {
    widget.data.gejalaSistemik = List<String>.from(_selected);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInstructions(),
            const SizedBox(height: 20),
            _buildSelectedCounter(),
            const SizedBox(height: 16),
            MultiSelectChip(
              options: _options,
              selectedValues: _selected,
              onChanged: (vals) => setState(() => _selected = vals),
            ),
            const SizedBox(height: 20),
            _buildNoneOption(),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Lanjut  →', onPressed: _handleNext),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.riskMedium,
            AppColors.riskMedium.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.monitor_heart_outlined, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 14),
          const Text(
            'Gejala Sistemik',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih semua gejala yang Anda alami saat ini atau dalam beberapa minggu terakhir.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.white.withValues(alpha: 0.85), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgInfoBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLightBlue),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primaryMediumBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ketuk untuk memilih gejala yang sesuai. Anda dapat memilih lebih dari satu, atau lewati jika tidak ada.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryDarkBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Gejala yang dialami',
          style: AppTextStyles.heading3.copyWith(fontSize: 14),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _selected.isEmpty
                ? AppColors.bgLightGray
                : AppColors.primaryDarkBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_selected.length} dipilih',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _selected.isEmpty ? AppColors.textGray : AppColors.primaryDarkBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoneOption() {
    final isNone = _selected.isEmpty;
    return GestureDetector(
      onTap: () => setState(() => _selected.clear()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isNone ? AppColors.riskLow.withValues(alpha: 0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNone ? AppColors.riskLow : AppColors.borderGray,
            width: isNone ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: isNone ? AppColors.riskLow : AppColors.iconGray,
            ),
            const SizedBox(width: 8),
            Text(
              'Tidak ada gejala di atas',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: isNone ? FontWeight.w600 : FontWeight.w400,
                color: isNone ? AppColors.riskLow : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
