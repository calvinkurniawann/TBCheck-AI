import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/question_card.dart';
import '../../widgets/radio_option_tile.dart';
import '../../widgets/checkbox_option_tile.dart';
import '../../widgets/primary_button.dart';

class Step2Gejala extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onNext;

  const Step2Gejala({super.key, required this.data, required this.onNext});

  @override
  State<Step2Gejala> createState() => _Step2GejalaState();
}

class _Step2GejalaState extends State<Step2Gejala> {
  late String? _durasiBatuk;
  late String? _frekuensiDemam;
  late String? _keringatMalam;
  late String? _penurunanBB;

  @override
  void initState() {
    super.initState();
    _durasiBatuk = widget.data.durasiBatuk;
    _frekuensiDemam = widget.data.frekuensiDemam;
    _keringatMalam = widget.data.keringatMalam;
    _penurunanBB = widget.data.penurunanBeratBadan;
  }

  void _handleNext() {
    if (_durasiBatuk == null || _frekuensiDemam == null ||
        _keringatMalam == null || _penurunanBB == null) {
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
    widget.data.durasiBatuk = _durasiBatuk;
    widget.data.frekuensiDemam = _frekuensiDemam;
    widget.data.keringatMalam = _keringatMalam;
    widget.data.penurunanBeratBadan = _penurunanBB;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Q1: Durasi Batuk
          QuestionCard(
            icon: Icons.masks_rounded,
            iconColor: AppColors.primaryMediumBlue,
            iconBgColor: AppColors.selectedBlueBg,
            title: 'Sudah berapa lama Anda mengalami batuk?',
            child: Column(children: [
              RadioOptionTile(label: 'Tidak ada', isSelected: _durasiBatuk == 'Tidak ada', onTap: () => setState(() => _durasiBatuk = 'Tidak ada')),
              RadioOptionTile(label: '< 2 minggu', isSelected: _durasiBatuk == '< 2 minggu', onTap: () => setState(() => _durasiBatuk = '< 2 minggu')),
              RadioOptionTile(label: '> 2 minggu', isSelected: _durasiBatuk == '> 2 minggu', onTap: () => setState(() => _durasiBatuk = '> 2 minggu')),
            ]),
          ),
          const SizedBox(height: 28),

          // Q2: Frekuensi Demam
          QuestionCard(
            title: 'Seberapa sering Anda mengalami demam?',
            child: _buildFrequencySelector(
              currentValue: _frekuensiDemam,
              options: ['Tidak pernah', 'Kadang-kadang', 'Sering'],
              onChanged: (val) => setState(() => _frekuensiDemam = val),
            ),
          ),
          const SizedBox(height: 28),

          // Q3: Keringat Malam
          QuestionCard(
            title: 'Keringat malam?',
            icon: Icons.nightlight_round,
            iconColor: AppColors.primaryDarkBlue,
            iconBgColor: AppColors.primaryLightBlue,
            child: Column(children: [
              RadioOptionTile(label: 'Tidak', isSelected: _keringatMalam == 'Tidak', onTap: () => setState(() => _keringatMalam = 'Tidak')),
              RadioOptionTile(label: 'Kadang', isSelected: _keringatMalam == 'Kadang', onTap: () => setState(() => _keringatMalam = 'Kadang')),
              RadioOptionTile(label: 'Sering', isSelected: _keringatMalam == 'Sering', onTap: () => setState(() => _keringatMalam = 'Sering')),
            ]),
          ),
          const SizedBox(height: 28),

          // Q4: Penurunan Berat Badan
          QuestionCard(
            title: 'Penurunan berat badan?',
            icon: Icons.monitor_weight_outlined,
            iconColor: AppColors.accentTeal,
            iconBgColor: AppColors.accentTealLight,
            child: Column(children: [
              CheckboxOptionTile(label: 'Tidak', isSelected: _penurunanBB == 'Tidak', onTap: () => setState(() => _penurunanBB = 'Tidak')),
              CheckboxOptionTile(label: 'Sedikit', isSelected: _penurunanBB == 'Sedikit', onTap: () => setState(() => _penurunanBB = 'Sedikit')),
              CheckboxOptionTile(label: 'Signifikan', isSelected: _penurunanBB == 'Signifikan', onTap: () => setState(() => _penurunanBB = 'Signifikan')),
            ]),
          ),
          const SizedBox(height: 24),

          // Footer info
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
                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primaryMediumBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Jawaban Anda membantu AI memberikan estimasi awal yang lebih akurat sebelum pemeriksaan medis lebih lanjut.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primaryDarkBlue, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: 'Lanjut  →', onPressed: _handleNext),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector({required String? currentValue, required List<String> options, required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: options.map((option) {
          final isSelected = currentValue == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDarkBlue : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primaryDarkBlue : AppColors.borderGray),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppColors.white : AppColors.textGray),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
