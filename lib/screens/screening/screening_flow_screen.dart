import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/screening_data.dart';
import '../../widgets/progress_header.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'step1_data_diri.dart';
import 'step2_gejala.dart';
import 'step3_faktor_risiko.dart';
import 'step4_keluhan_tambahan.dart';

class ScreeningFlowScreen extends StatefulWidget {
  const ScreeningFlowScreen({super.key});

  @override
  State<ScreeningFlowScreen> createState() => _ScreeningFlowScreenState();
}

class _ScreeningFlowScreenState extends State<ScreeningFlowScreen> {
  final PageController _pageController = PageController();
  final ScreeningData _screeningData = ScreeningData();
  int _currentStep = 1;

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSubmit() {
    // Show success dialog with screening data summary
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.riskLowBg, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.riskLow, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Berhasil!', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Data screening Anda telah berhasil dikumpulkan. Sistem AI akan menganalisis data Anda.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textGray, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Kembali ke Beranda', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      appBar: ProgressHeader(
        currentStep: _currentStep,
        onBack: _previousStep,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentStep = index + 1),
        children: [
          Step1DataDiri(data: _screeningData, onNext: _nextStep),
          Step2Gejala(data: _screeningData, onNext: _nextStep),
          Step3FaktorRisiko(data: _screeningData, onNext: _nextStep),
          Step4KeluhanTambahan(data: _screeningData, onSubmit: _onSubmit),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
