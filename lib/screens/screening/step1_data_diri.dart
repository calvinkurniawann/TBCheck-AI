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

class _Step1DataDiriState extends State<Step1DataDiri> with SingleTickerProviderStateMixin {
  late TextEditingController _usiaController;
  late TextEditingController _tinggiController;
  late TextEditingController _beratController;
  String? _jenisKelamin;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _usiaController = TextEditingController(
      text: widget.data.usia?.toString() ?? '',
    );
    _tinggiController = TextEditingController(
      text: widget.data.tinggiBadan?.toString() ?? '',
    );
    _beratController = TextEditingController(
      text: widget.data.beratBadan?.toString() ?? '',
    );
    _jenisKelamin = widget.data.jenisKelamin;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _usiaController.dispose();
    _tinggiController.dispose();
    _beratController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final usia = int.tryParse(_usiaController.text);
    if (usia == null || usia <= 0 || usia > 120) {
      _showError('Masukkan usia yang valid (1-120)');
      return;
    }
    if (_jenisKelamin == null) {
      _showError('Pilih jenis kelamin');
      return;
    }
    final tinggi = double.tryParse(_tinggiController.text);
    if (tinggi == null || tinggi <= 0) {
      _showError('Masukkan tinggi badan yang valid');
      return;
    }
    final berat = double.tryParse(_beratController.text);
    if (berat == null || berat <= 0) {
      _showError('Masukkan berat badan yang valid');
      return;
    }

    widget.data.usia = usia;
    widget.data.jenisKelamin = _jenisKelamin;
    widget.data.tinggiBadan = tinggi;
    widget.data.beratBadan = berat;
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

  String get _bmiPreview {
    final t = double.tryParse(_tinggiController.text);
    final b = double.tryParse(_beratController.text);
    if (t != null && b != null && t > 0 && b > 0) {
      final hm = t / 100;
      final bmi = b / (hm * hm);
      String cat;
      if (bmi < 18.5) {
        cat = 'Kurus';
      } else if (bmi < 25) {
        cat = 'Normal';
      } else if (bmi < 30) {
        cat = 'Gemuk';
      } else {
        cat = 'Obesitas';
      }
      return '${bmi.toStringAsFixed(1)} ($cat)';
    }
    return '-';
  }

  Color get _bmiColor {
    final t = double.tryParse(_tinggiController.text);
    final b = double.tryParse(_beratController.text);
    if (t != null && b != null && t > 0 && b > 0) {
      final hm = t / 100;
      final bmi = b / (hm * hm);
      if (bmi < 18.5) return AppColors.warningOrange;
      if (bmi < 25) return AppColors.riskLow;
      if (bmi < 30) return AppColors.riskMedium;
      return AppColors.riskHigh;
    }
    return AppColors.textLightGray;
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
                    'Lengkapi profil Anda untuk memulai skrining awal kesehatan paru.',
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

            Text('Usia', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _usiaController,
              hint: 'Contoh: 25',
              suffix: 'Tahun',
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),

            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

            Text('Tinggi Badan', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _tinggiController,
              hint: 'Contoh: 170',
              suffix: 'cm',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                LengthLimitingTextInputFormatter(5),
              ],
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            Text('Berat Badan', style: AppTextStyles.heading3.copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            _buildInputField(
              controller: _beratController,
              hint: 'Contoh: 65',
              suffix: 'kg',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                LengthLimitingTextInputFormatter(5),
              ],
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bmiColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _bmiColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _bmiColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.monitor_weight_outlined,
                      color: _bmiColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI (Body Mass Index)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _bmiPreview,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _bmiColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            PrimaryButton(
              label: 'Lanjut  →',
              onPressed: _handleNext,
            ),

            const SizedBox(height: 16),

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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required String suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textLightGray,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
              suffix,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
