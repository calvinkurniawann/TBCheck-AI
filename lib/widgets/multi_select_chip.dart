import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class MultiSelectChip extends StatelessWidget {
  final List<MultiSelectOption> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;

  const MultiSelectChip({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  void _toggle(String value) {
    final updated = List<String>.from(selectedValues);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        return GestureDetector(
          onTap: () => _toggle(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryDarkBlue
                  : AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryDarkBlue
                    : AppColors.borderGray,
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryDarkBlue.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected
                        ? AppColors.white.withValues(alpha: 0.2)
                        : AppColors.bgLightGray,
                  ),
                  child: Icon(
                    option.icon,
                    size: 14,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.iconGray,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textDark,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MultiSelectOption {
  final String label;
  final String value;
  final IconData icon;

  const MultiSelectOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}
