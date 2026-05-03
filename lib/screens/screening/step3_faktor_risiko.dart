import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/question_card.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/primary_button.dart';

class Step3FaktorRisiko extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onNext;

  const Step3FaktorRisiko({super.key, required this.data, required this.onNext});

  @override
  State<Step3FaktorRisiko> createState() => _Step3FaktorRisikoState();
}

class _Step3FaktorRisikoState extends State<Step3FaktorRisiko> {
  String? _kontakTBC; // 'Ya' / 'Tidak'
  String? _lingkungan;
  String? _merokok; // 'Ya' / 'Tidak'

  @override
  void initState() {
    super.initState();
    _kontakTBC = widget.data.kontakPasienTBC == null ? null : (widget.data.kontakPasienTBC! ? 'Ya' : 'Tidak');
    _lingkungan = widget.data.lingkunganTempatTinggal;
    _merokok = widget.data.merokok == null ? null : (widget.data.merokok! ? 'Ya' : 'Tidak');
  }

  void _handleNext() {
    if (_kontakTBC == null || _lingkungan == null || _merokok == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mohon jawab semua pertanyaan'),
          backgroundColor: AppColors.riskHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    widget.data.kontakPasienTBC = _kontakTBC == 'Ya';
    widget.data.lingkunganTempatTinggal = _lingkungan;
    widget.data.merokok = _merokok == 'Ya';
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
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
                  decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.white, size: 24),
                ),
                const SizedBox(height: 14),
                const Text('Analisis Lingkungan', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 4),
                Text('Faktor Risiko', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.white.withValues(alpha: 0.85))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Q1: Kontak TBC
          QuestionCard(
            title: 'Apakah Anda pernah kontak dengan posen TBC?',
            subtitle: 'Termasuk tinggal serumah atau rutin berja sama dalam 6 bulan terakhir.',
            child: ChipSelector(
              options: const [
                ChipOption(label: 'Ya', value: 'Ya', icon: Icons.check_circle_outline),
                ChipOption(label: 'Tidak', value: 'Tidak', icon: Icons.cancel_outlined),
              ],
              selectedValue: _kontakTBC,
              onSelected: (val) => setState(() => _kontakTBC = val),
            ),
          ),
          const SizedBox(height: 24),

          // Q2: Lingkungan
          QuestionCard(
            title: 'Lingkungan tempat tinggal',
            child: Column(
              children: [
                _buildEnvOption('Tidak padat', Icons.home_rounded, _lingkungan == 'Tidak padat', () => setState(() => _lingkungan = 'Tidak padat')),
                _buildEnvOption('Cukup padat', Icons.holiday_village_rounded, _lingkungan == 'Cukup padat', () => setState(() => _lingkungan = 'Cukup padat')),
                _buildEnvOption('Padat & Kumuh', Icons.location_city_rounded, _lingkungan == 'Padat & Kumuh', () => setState(() => _lingkungan = 'Padat & Kumuh')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Q3: Merokok - Insight box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights_rounded, color: AppColors.accentTeal, size: 18),
                    const SizedBox(width: 8),
                    Text('INSIGHT KESEHATAN', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accentTeal, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Apakah Anda merokok?', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
                const SizedBox(height: 12),
                ChipSelector(
                  options: [
                    ChipOption(label: 'Ya', value: 'Ya', icon: Icons.check, selectedColor: AppColors.accentTeal),
                    ChipOption(label: 'Tidak', value: 'Tidak', icon: Icons.close, selectedColor: AppColors.accentTeal),
                  ],
                  selectedValue: _merokok,
                  onSelected: (val) => setState(() => _merokok = val),
                ),
                const SizedBox(height: 12),
                Text(
                  'Merokok dapat meningkatkan risiko komplikasi TBC hingga 3 kali lipat dibandingkan non-perokok.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.white.withValues(alpha: 0.7), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          PrimaryButton(label: 'Lanjut  →', onPressed: _handleNext),
          const SizedBox(height: 16),
          Center(child: Text('Simpan sebagai draf', style: AppTextStyles.caption.copyWith(color: AppColors.primaryMediumBlue, decoration: TextDecoration.underline))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnvOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBlueBg : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryMediumBlue : AppColors.borderGray, width: isSelected ? 1.8 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryMediumBlue.withValues(alpha: 0.1) : AppColors.bgLightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: isSelected ? AppColors.primaryMediumBlue : AppColors.iconGray),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.primaryDarkBlue : AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
