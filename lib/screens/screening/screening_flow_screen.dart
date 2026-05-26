import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/screening_api_service.dart';
import '../../core/utils/symptom_mapper.dart';
import '../../models/screening_data.dart';
import '../../widgets/progress_header.dart';

import 'step1_data_diri.dart';
import 'step2_gejala.dart';
import 'step3_faktor_risiko.dart';
import 'step4_keluhan_tambahan.dart';
import '../result/screening_result_screen.dart';

class ScreeningFlowScreen extends StatefulWidget {
  const ScreeningFlowScreen({super.key});

  @override
  State<ScreeningFlowScreen> createState() => _ScreeningFlowScreenState();
}

class _ScreeningFlowScreenState extends State<ScreeningFlowScreen> {
  final PageController _pageController = PageController();
  final ScreeningData _screeningData = ScreeningData();
  final ScreeningApiService _apiService = ScreeningApiService();
  int _currentStep = 1;
  bool _isSubmitting = false;

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

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Menganalisis Data...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI sedang memproses gejala dan\nfaktor risiko Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentTeal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Map the screening form data to backend codes
      final symptomCodes = SymptomMapper.mapToBackendCodes(_screeningData);
      debugPrint('Mapped symptoms: $symptomCodes');

      // Call the backend API
      final result = await _apiService.submitScreening(
        selectedSymptomCodes: symptomCodes,
      );

      if (!mounted) return;

      // Dismiss loading dialog
      Navigator.of(context).pop();

      // Navigate to result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScreeningResultScreen(
            result: result,
            symptomCodes: symptomCodes,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading
      _showErrorDialog('Gagal terhubung ke server', e.message);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading
      _showErrorDialog('Terjadi Kesalahan', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.riskHigh.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.riskHigh, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textGray,
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Tutup', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _apiService.dispose();
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
          Step2GejalaUtama(data: _screeningData, onNext: _nextStep),
          Step3GejalaSistemik(data: _screeningData, onNext: _nextStep),
          Step4LingkunganRisiko(data: _screeningData, onSubmit: _onSubmit),
        ],
      ),

    );
  }
}
