import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ChipSelector extends StatelessWidget {
  final List<ChipOption> options;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: option != options.last ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: () => onSelected(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (option.selectedColor ?? AppColors.primaryDarkBlue)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? (option.selectedColor ?? AppColors.primaryDarkBlue)
                        : AppColors.borderGray,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (option.selectedColor ?? AppColors.primaryDarkBlue)
                                .withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        size: 18,
                        color: isSelected ? AppColors.white : AppColors.iconGray,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ChipOption {
  final String label;
  final String value;
  final IconData? icon;
  final Color? selectedColor;

  const ChipOption({
    required this.label,
    required this.value,
    this.icon,
    this.selectedColor,
  });
}
