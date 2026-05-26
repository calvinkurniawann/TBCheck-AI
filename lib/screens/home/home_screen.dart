import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/screening_api_service.dart';
import '../../core/services/auth_service.dart';
import '../../models/screening_history.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onStartScreening;

  const HomeScreen({super.key, required this.onStartScreening});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  final ScreeningApiService _apiService = ScreeningApiService();

  List<ScreeningHistory> _histories = [];
  final AuthService _authService = AuthService();
  UserData? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getSavedUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
    await _loadHistory();
  }

  @override
  void dispose() {
    _animController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final apiItems = await _apiService.getHistory();
      if (!mounted) return;
      setState(() {
        _histories = apiItems
            .map((item) => ScreeningHistory.fromApi(item))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('[Home] Failed to load history: $e');
      setState(() {
        _histories = ScreeningHistory.mockData();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: FadeTransition(
        opacity: _fadeIn,
        child: CustomScrollView(
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    final latest = _histories.isNotEmpty ? _histories.first : null;
    final statusText = latest != null
        ? 'Status terakhir: ${latest.riskLabel} • ${latest.timeAgo}'
        : 'Belum ada skrining';

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryDarkBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDarkBlue,
                const Color(0xFF0F2847),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang! 👋',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                'Halo, ${_currentUser?.name ?? 'Pengguna'}!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                              size: 22,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.riskHigh,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: AppColors.accentTealLight,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCtaCard(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildRecentScreening(),
          const SizedBox(height: 24),
          _buildEducationSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCtaCard() {
    return GestureDetector(
      onTap: widget.onStartScreening,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentTeal.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SKRINING CEPAT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mulai Skrining\nTBC Sekarang',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deteksi dini risiko TBC dalam 5 menit',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final latestStatus = _histories.isNotEmpty
        ? (_histories.first.riskLevel == RiskLevel.rendah ? 'Aman' : 'Waspada')
        : '-';
    final statusColor = _histories.isNotEmpty
        ? (_histories.first.riskLevel == RiskLevel.rendah
            ? AppColors.riskLow
            : _histories.first.riskColor)
        : AppColors.iconGray;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.fact_check_rounded,
            label: 'Total Skrining',
            value: _isLoading ? '...' : '${_histories.length}',
            color: AppColors.primaryMediumBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.shield_rounded,
            label: 'Status Saat Ini',
            value: _isLoading ? '...' : latestStatus,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildRecentScreening() {
    final latest = _histories.isNotEmpty ? _histories.first : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Skrining Terakhir', style: AppTextStyles.heading3),
            TextButton(
              onPressed: () {},
              child: Text(
                'Lihat Semua',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryMediumBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.accentTeal),
                strokeWidth: 2,
              ),
            ),
          )
        else if (latest != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: latest.riskBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(latest.riskIcon, color: latest.riskColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latest.riskLabel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: latest.riskColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${latest.timeAgo} • Skor: ${latest.riskScore.toStringAsFixed(0)}%',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.iconGray,
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 40, color: AppColors.iconGray),
                const SizedBox(height: 8),
                Text(
                  'Belum ada riwayat skrining',
                  style: AppTextStyles.bodyRegular,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEducationSection() {
    final tips = [
      _HealthTip(
        title: 'Kenali Gejala TBC',
        desc: 'Batuk > 3 minggu, demam, keringat malam, dan penurunan berat badan.',
        icon: Icons.coronavirus_outlined,
        gradient: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
      ),
      _HealthTip(
        title: 'Pentingnya Ventilasi',
        desc: 'Sirkulasi udara yang baik mengurangi risiko penularan TBC hingga 70%.',
        icon: Icons.air_rounded,
        gradient: [const Color(0xFF0D9488), const Color(0xFF0F766E)],
      ),
      _HealthTip(
        title: 'TBC Bisa Disembuhkan',
        desc: 'Dengan pengobatan OAT selama 6-9 bulan, TBC dapat sembuh total.',
        icon: Icons.medical_services_rounded,
        gradient: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
      ),
      _HealthTip(
        title: 'Hindari Penularan',
        desc: 'Gunakan masker, tutup mulut saat batuk, dan jaga jarak dengan penderita.',
        icon: Icons.masks_rounded,
        gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tips Kesehatan', style: AppTextStyles.heading3),
        const SizedBox(height: 4),
        Text(
          'Fakta penting seputar Tuberkulosis',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: 240,
                margin: EdgeInsets.only(right: index < tips.length - 1 ? 14 : 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tip.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: tip.gradient.first.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tip.icon, size: 20, color: AppColors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tip.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        tip.desc,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HealthTip {
  final String title;
  final String desc;
  final IconData icon;
  final List<Color> gradient;

  const _HealthTip({
    required this.title,
    required this.desc,
    required this.icon,
    required this.gradient,
  });
}
