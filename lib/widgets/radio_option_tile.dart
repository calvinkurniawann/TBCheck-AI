import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class RadioOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  const RadioOptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBlueBg : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryMediumBlue : AppColors.borderGray,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryMediumBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryMediumBlue : AppColors.borderGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 18,
                color: isSelected ? AppColors.primaryMediumBlue : AppColors.iconGray,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primaryDarkBlue : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
