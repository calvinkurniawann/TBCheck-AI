import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/primary_button.dart';

class Step1DataDiri extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onNext;

  const Step1DataDiri({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<Step1DataDiri> createState() => _Step1DataDiriState();
}

class _Step1DataDiriState extends State<Step1DataDiri> {
  late TextEditingController _umurController;
  String? _jenisKelamin;

  @override
  void initState() {
    super.initState();
    _umurController = TextEditingController(
      text: widget.data.umur?.toString() ?? '',
    );
    _jenisKelamin = widget.data.jenisKelamin;
  }

  @override
  void dispose() {
    _umurController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final umur = int.tryParse(_umurController.text);
    if (umur == null || umur <= 0) {
      _showError('Masukkan umur yang valid');
      return;
    }
    if (_jenisKelamin == null) {
      _showError('Pilih jenis kelamin');
      return;
    }

    widget.data.umur = umur;
    widget.data.jenisKelamin = _jenisKelamin;
    widget.onNext();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.riskHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDarkBlue,
                  AppColors.primaryDarkBlue.withValues(alpha: 0.85),
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
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Data Diri',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan lengkapi informasi profil Anda untuk memulai deteksi awal kesehatan paru.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Umur field
          Text('Umur', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _umurController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 25',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textLightGray,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AppColors.borderGray),
                    ),
                  ),
                  child: Text(
                    'Tahun',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Jenis kelamin
          Text('Jenis Kelamin', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
          const SizedBox(height: 8),
          ChipSelector(
            options: const [
              ChipOption(
                label: 'Laki-laki',
                value: 'Laki-laki',
                icon: Icons.male_rounded,
              ),
              ChipOption(
                label: 'Perempuan',
                value: 'Perempuan',
                icon: Icons.female_rounded,
              ),
            ],
            selectedValue: _jenisKelamin,
            onSelected: (val) => setState(() => _jenisKelamin = val),
          ),

          const SizedBox(height: 24),

          // Lanjut button
          PrimaryButton(
            label: 'Lanjut  →',
            onPressed: _handleNext,
          ),

          const SizedBox(height: 16),

          // Butuh bantuan
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.help_outline_rounded, size: 16),
              label: const Text('Butuh Bantuan?'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryMediumBlue,
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
