import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              _NavItem(
                icon: Icons.medical_services_rounded,
                label: 'Screening',
                isActive: currentIndex == 1,
                onTap: () => onTap?.call(1),
                activeColor: AppColors.accentTeal,
              ),
              _NavItem(
                icon: Icons.local_hospital_rounded,
                label: 'Klinik',
                isActive: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isActive: currentIndex == 3,
                onTap: () => onTap?.call(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.primaryDarkBlue)
        : AppColors.iconGray;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
