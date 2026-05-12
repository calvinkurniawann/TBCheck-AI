import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/multi_select_chip.dart';


class Step4LingkunganRisiko extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onSubmit;

  const Step4LingkunganRisiko({super.key, required this.data, required this.onSubmit});

  @override
  State<Step4LingkunganRisiko> createState() => _Step4LingkunganRisikoState();
}

class _Step4LingkunganRisikoState extends State<Step4LingkunganRisiko>
    with SingleTickerProviderStateMixin {
  late List<String> _lingkungan;
  late List<String> _gayaHidup;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  static const _lingkunganOptions = [
    MultiSelectOption(
      label: 'Tinggal serumah dengan penderita TBC',
      value: 'serumah_tbc',
      icon: Icons.home_rounded,
    ),
    MultiSelectOption(
      label: 'Kontak intensif di luar rumah dengan penderita TBC',
      value: 'kontak_luar',
      icon: Icons.groups_rounded,
    ),
    MultiSelectOption(
      label: 'Rumah tanpa ventilasi / pengap / kurang cahaya',
      value: 'ventilasi_buruk',
      icon: Icons.air_rounded,
    ),
    MultiSelectOption(
      label: 'Tinggal di pemukiman padat / kumuh',
      value: 'pemukiman_padat',
      icon: Icons.location_city_rounded,
    ),
  ];

  static const _gayaHidupOptions = [
    MultiSelectOption(
      label: 'Perokok / Mantan perokok',
      value: 'perokok',
      icon: Icons.smoking_rooms_rounded,
    ),
    MultiSelectOption(
      label: 'Konsumsi alkohol',
      value: 'alkohol',
      icon: Icons.local_bar_rounded,
    ),
    MultiSelectOption(
      label: 'Gizi buruk',
      value: 'gizi_buruk',
      icon: Icons.no_food_rounded,
    ),
    MultiSelectOption(
      label: 'Riwayat penyakit penurun imun (HIV/Diabetes)',
      value: 'riwayat_imun',
      icon: Icons.health_and_safety_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lingkungan = List<String>.from(widget.data.faktorLingkungan);
    _gayaHidup = List<String>.from(widget.data.gayaHidupKomorbid);
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

  void _handleSubmit() {
    widget.data.faktorLingkungan = List<String>.from(_lingkungan);
    widget.data.gayaHidupKomorbid = List<String>.from(_gayaHidup);
    widget.onSubmit();
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
            _buildSectionLabel('Lingkungan & Riwayat Kontak', Icons.place_rounded, _lingkungan.length),
            const SizedBox(height: 12),
            MultiSelectChip(
              options: _lingkunganOptions,
              selectedValues: _lingkungan,
              onChanged: (vals) => setState(() => _lingkungan = vals),
            ),
            const SizedBox(height: 28),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSectionLabel('Gaya Hidup & Komorbid', Icons.fitness_center_rounded, _gayaHidup.length),
            const SizedBox(height: 12),
            MultiSelectChip(
              options: _gayaHidupOptions,
              selectedValues: _gayaHidup,
              onChanged: (vals) => setState(() => _gayaHidup = vals),
            ),
            const SizedBox(height: 24),
            _buildWarningBox(),
            const SizedBox(height: 16),
            _buildDisclaimerBox(),
            const SizedBox(height: 28),
            _buildSubmitButton(),
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
          colors: [AppColors.riskHigh, AppColors.riskHigh.withValues(alpha: 0.85)],
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
            child: const Icon(Icons.shield_outlined, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 14),
          const Text(
            'Lingkungan & Faktor Risiko',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih faktor risiko yang sesuai dengan kondisi Anda. Langkah terakhir sebelum analisis.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.white.withValues(alpha: 0.85), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryDarkBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.primaryDarkBlue.withValues(alpha: 0.1)
                : AppColors.bgLightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: count > 0 ? AppColors.primaryDarkBlue : AppColors.textGray,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderGray, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bgLightGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, size: 16, color: AppColors.iconGray),
          ),
        ),
        Expanded(child: Divider(color: AppColors.borderGray, thickness: 1)),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningOrangeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warningOrange),
              const SizedBox(width: 8),
              Text(
                'Mengapa ini penting?',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warningOrange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Faktor lingkungan dan gaya hidup berperan penting dalam penularan TBC. Informasi ini membantu AI memberikan analisis risiko yang lebih akurat.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textDark, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgInfoBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLightBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryMediumBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dengan menekan "Analisis Sekarang", Anda menyetujui bahwa ini adalah alat bantu informasi dan bukan pengganti diagnosis medis profesional.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryDarkBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _handleSubmit,
        icon: const Icon(Icons.search_rounded, size: 20),
        label: const Text(
          'Analisis Sekarang',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 4,
        ),
      ),
    );
  }
}
