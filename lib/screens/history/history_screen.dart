import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/screening_api_service.dart';
import '../../models/screening_history.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  final ScreeningApiService _apiService = ScreeningApiService();

  List<ScreeningHistory> _histories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadHistory();
  }

  @override
  void dispose() {
    _animController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiItems = await _apiService.getHistory();
      if (!mounted) return;

      setState(() {
        _histories = apiItems
            .map((item) => ScreeningHistory.fromApi(item))
            .toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      debugPrint('[History] API Error: ${e.message}');
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
        // Fallback to mock data if API fails
        _histories = ScreeningHistory.mockData();
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('[History] Error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _histories = ScreeningHistory.mockData();
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
            _buildHeader(),
            if (_errorMessage != null) _buildErrorBanner(),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.accentTeal),
                  ),
                ),
              )
            else ...[
              _buildSummaryBar(),
              _buildHistoryList(),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: kToolbarHeight,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.chevron_left_rounded, size: 28),
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Riwayat Skrining',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _loadHistory,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningOrangeBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.warningOrange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tidak dapat terhubung ke server. Menampilkan data contoh.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.warningOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: _loadHistory,
              child: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.warningOrange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final rendahCount = _histories.where((h) => h.riskLevel == RiskLevel.rendah).length;
    final sedangCount = _histories.where((h) => h.riskLevel == RiskLevel.sedang).length;
    final tinggiCount = _histories.where((h) => h.riskLevel == RiskLevel.tinggi).length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Row(
          children: [
            _buildMiniStat('Rendah', rendahCount, AppColors.riskLow),
            const SizedBox(width: 10),
            _buildMiniStat('Sedang', sedangCount, AppColors.riskMedium),
            const SizedBox(width: 10),
            _buildMiniStat('Tinggi', tinggiCount, AppColors.riskHigh),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_histories.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 56, color: AppColors.iconGray),
              const SizedBox(height: 12),
              Text(
                'Belum ada riwayat skrining',
                style: AppTextStyles.bodyRegular.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Mulai skrining pertama Anda',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _histories[index];
          return _buildHistoryCard(item, index);
        },
        childCount: _histories.length,
      ),
    );
  }

  Widget _buildHistoryCard(ScreeningHistory item, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, index == 0 ? 12 : 0, 20, 12),
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryDetailScreen(history: item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.riskBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.riskIcon, color: item.riskColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.riskBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.riskLabel,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: item.riskColor,
                                ),
                              ),
                            ),
                            Text(
                              item.timeAgo,
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDetailChip(
                              Icons.analytics_outlined,
                              'Skor: ${item.riskScore.toStringAsFixed(0)}%',
                            ),
                            const SizedBox(width: 10),
                            _buildDetailChip(
                              Icons.coronavirus_outlined,
                              '${item.gejalaTerdeteksi} gejala',
                            ),
                            const SizedBox(width: 10),
                            _buildDetailChip(
                              Icons.warning_amber_rounded,
                              '${item.faktorRisiko} risiko',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.iconGray,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.iconGray),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}
