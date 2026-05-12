import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/screening_data.dart';
import '../../widgets/chip_selector.dart';
import '../../widgets/question_card.dart';
import '../../widgets/primary_button.dart';

class Step2GejalaUtama extends StatefulWidget {
  final ScreeningData data;
  final VoidCallback onNext;

  const Step2GejalaUtama({super.key, required this.data, required this.onNext});

  @override
  State<Step2GejalaUtama> createState() => _Step2GejalaUtamaState();
}

class _Step2GejalaUtamaState extends State<Step2GejalaUtama>
    with SingleTickerProviderStateMixin {
  String? _batukLama;
  String? _batukDarah;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    if (widget.data.batukLama != null) {
      _batukLama = widget.data.batukLama! ? 'Ya' : 'Tidak';
    }
    if (widget.data.batukDarah != null) {
      _batukDarah = widget.data.batukDarah! ? 'Ya' : 'Tidak';
    }
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

  bool get _showBatukDarah => _batukLama == 'Ya';

  void _handleNext() {
    if (_batukLama == null) {
      _showError('Mohon jawab pertanyaan batuk');
      return;
    }
    if (_showBatukDarah && _batukDarah == null) {
      _showError('Mohon jawab pertanyaan batuk darah');
      return;
    }
    widget.data.batukLama = _batukLama == 'Ya';
    widget.data.batukDarah = _showBatukDarah ? (_batukDarah == 'Ya') : false;
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
    return FadeTransition(
      opacity: _fadeIn,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildBatukLamaCard(),
            _buildConditionalBatukDarah(),
            const SizedBox(height: 24),
            _buildInfoBox(),
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
            AppColors.accentTeal,
            AppColors.accentTeal.withValues(alpha: 0.85),
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
            child: const Icon(Icons.coronavirus_outlined, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 14),
          const Text(
            'Gejala Utama',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Pertanyaan ini fokus pada gejala batuk yang merupakan indikator utama TBC.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.white.withValues(alpha: 0.85), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBatukLamaCard() {
    return QuestionCard(
      icon: Icons.sick_outlined,
      iconColor: AppColors.warningOrange,
      iconBgColor: AppColors.warningOrangeBg,
      title: 'Apakah Anda mengalami batuk terus-menerus atau berdahak selama ≥ 3 minggu?',
      subtitle: 'Batuk yang tidak kunjung sembuh merupakan gejala khas TBC paru.',
      child: ChipSelector(
        options: const [
          ChipOption(label: 'Ya', value: 'Ya', icon: Icons.check_circle_outline),
          ChipOption(label: 'Tidak', value: 'Tidak', icon: Icons.cancel_outlined),
        ],
        selectedValue: _batukLama,
        onSelected: (val) {
          setState(() {
            _batukLama = val;
            if (val == 'Tidak') _batukDarah = null;
          });
        },
      ),
    );
  }

  Widget _buildConditionalBatukDarah() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: _showBatukDarah
          ? Padding(
              padding: const EdgeInsets.only(top: 20),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.riskHighBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.riskHigh.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bloodtype_outlined, color: AppColors.riskHigh, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Batuk Darah (Hemoptisis)', style: AppTextStyles.heading3.copyWith(fontSize: 14, color: AppColors.riskHigh)),
                                const SizedBox(height: 2),
                                Text('Pernahkah batuk Anda disertai darah?', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ChipSelector(
                        options: [
                          ChipOption(label: 'Ya', value: 'Ya', icon: Icons.check_circle_outline, selectedColor: AppColors.riskHigh),
                          ChipOption(label: 'Tidak', value: 'Tidak', icon: Icons.cancel_outlined, selectedColor: AppColors.riskLow),
                        ],
                        selectedValue: _batukDarah,
                        onSelected: (val) => setState(() => _batukDarah = val),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildInfoBox() {
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
          const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primaryMediumBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Batuk berkepanjangan (≥ 3 minggu) yang disertai dahak atau darah merupakan salah satu tanda utama tuberkulosis.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryDarkBlue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
