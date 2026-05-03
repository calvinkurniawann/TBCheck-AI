import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class QuestionCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const QuestionCard({
    super.key,
    this.icon,
    this.iconColor,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.selectedBlueBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryMediumBlue,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryDarkBlue,
            fontSize: 15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.caption),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
