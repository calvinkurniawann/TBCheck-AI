import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/screening_api_service.dart';
import '../../core/utils/symptom_mapper.dart';
import '../clinic/clinic_screen.dart';

/// Screen displayed after Supabase returns screening results.
/// Shows CF score, risk level, detected symptoms, and AI-generated advice.
class ScreeningResultScreen extends StatefulWidget {
  final ScreeningResult result;
  final List<String> symptomCodes;

  const ScreeningResultScreen({
    super.key,
    required this.result,
    required this.symptomCodes,
  });

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _riskColor {
    switch (widget.result.riskLevel) {
      case 'Tinggi':
        return AppColors.riskHigh;
      case 'Sedang':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }

  Color get _riskBgColor {
    switch (widget.result.riskLevel) {
      case 'Tinggi':
        return AppColors.riskHighBg;
      case 'Sedang':
        return AppColors.riskMediumBg;
      default:
        return AppColors.riskLowBg;
    }
  }

  IconData get _riskIcon {
    switch (widget.result.riskLevel) {
      case 'Tinggi':
        return Icons.dangerous_rounded;
      case 'Sedang':
        return Icons.warning_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String get _riskLabel => 'Risiko ${widget.result.riskLevel}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryDarkBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDarkBlue, Color(0xFF0F2847)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Hasil Analisis',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Powered by AI & Certainty Factor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _shouldSuggestClinic => widget.result.cfScorePercentage > 60.0;

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildScoreCard(),
          const SizedBox(height: 20),
          _buildAiAdviceCard(),
          if (_shouldSuggestClinic) ...[
            const SizedBox(height: 20),
            _buildClinicSuggestionCard(),
          ],
          const SizedBox(height: 20),
          _buildSymptomsCard(),
          const SizedBox(height: 20),
          _buildDisclaimerCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildClinicSuggestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.riskHighBg.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.local_hospital_rounded,
                size: 18,
                color: AppColors.primaryDarkBlue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Periksa Ke Klinik Terdekat',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Persentase hasil di atas 60%. Kami sarankan segera mencari klinik atau rumah sakit terdekat untuk pemeriksaan lanjutan.',
            style: AppTextStyles.bodyRegular.copyWith(height: 1.6),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ClinicScreen()),
                );
              },
              icon: const Icon(Icons.local_hospital_rounded, size: 20),
              label: const Text('Cari Klinik Terdekat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return ScaleTransition(
      scale: _scaleIn,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _riskColor.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _riskColor.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _riskBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _riskColor.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
              child: Icon(_riskIcon, color: _riskColor, size: 36),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _riskBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _riskLabel,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _riskColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetric(
                  'CF Score',
                  widget.result.cfScoreRaw.toStringAsFixed(4),
                  Icons.analytics_outlined,
                ),
                Container(
                  width: 1,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.borderGray,
                ),
                _buildMetric(
                  'Persentase',
                  '${widget.result.cfScorePercentage.toStringAsFixed(1)}%',
                  Icons.percent_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.iconGray),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildAiAdviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Saran AI',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI-Powered',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.result.aiAdvice,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.92),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    final gejala = widget.symptomCodes.where((c) => c.startsWith('G')).toList();
    final risiko = widget.symptomCodes
        .where((c) => c.startsWith('R') || c.startsWith('K'))
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  color: AppColors.primaryDarkBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fact_check_rounded,
                  size: 20,
                  color: AppColors.primaryDarkBlue,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Detail Gejala Terdeteksi',
                style: AppTextStyles.heading3.copyWith(fontSize: 15),
              ),
            ],
          ),
          if (gejala.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSymptomSection(
              'Gejala',
              Icons.coronavirus_outlined,
              AppColors.riskHigh,
              gejala,
            ),
          ],
          if (risiko.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildSymptomSection(
              'Faktor Risiko',
              Icons.shield_outlined,
              AppColors.riskMedium,
              risiko,
            ),
          ],
          if (widget.symptomCodes.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Tidak ada gejala/faktor risiko yang terdeteksi',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomSection(
    String title,
    IconData icon,
    Color color,
    List<String> codes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              '$title (${codes.length})',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: codes.map((code) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Text(
                SymptomMapper.codeToLabel(code),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard() {
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
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primaryMediumBlue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hasil ini merupakan estimasi awal menggunakan metode Certainty Factor dan AI. Bukan pengganti diagnosis medis profesional. Segera konsultasi ke dokter untuk pemeriksaan lebih lanjut.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDarkBlue,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.of(context).popUntil(ModalRoute.withName('/home')),
            icon: const Icon(Icons.home_rounded, size: 20),
            label: const Text(
              'Kembali ke Beranda',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName('/home'));
              Navigator.pushNamed(context, '/screening');
            },
            icon: const Icon(Icons.replay_rounded, size: 20),
            label: const Text(
              'Skrining Ulang',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDarkBlue,
              side: const BorderSide(
                color: AppColors.primaryDarkBlue,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
