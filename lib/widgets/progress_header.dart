import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class ProgressHeader extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const ProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.onBack,
  });

  double get _progress => currentStep / totalSteps;
  int get _percentage => (_progress * 100).round();

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: back button + title + menu
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: AppColors.primaryDarkBlue,
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: const Text(
                        'TBCheck AI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_vert, color: AppColors.primaryDarkBlue.withValues(alpha: 0.6)),
                ],
              ),
              const SizedBox(height: 10),
              // Progress info row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Langkah $currentStep dari $totalSteps',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDarkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getProgressColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_percentage% Selesai',
                        style: AppTextStyles.caption.copyWith(
                          color: _getProgressColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor: AppColors.bgLightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor() {
    if (_percentage <= 25) return AppColors.primaryMediumBlue;
    if (_percentage <= 50) return AppColors.accentTeal;
    if (_percentage <= 75) return AppColors.riskMedium;
    return AppColors.riskLow;
  }
}
