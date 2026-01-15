import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

enum HabitOptionResult {
  delete,
  cancel,
}

class HabitOptionsBottomSheet extends StatelessWidget {
  const HabitOptionsBottomSheet({super.key});

  static Future<HabitOptionResult?> show(BuildContext context) {
    return showModalBottomSheet<HabitOptionResult>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (context) => const HabitOptionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLg),
            _OptionTile(
              icon: Icons.delete_outline,
              label: AppStrings.deleteActivity,
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () => Navigator.of(context).pop(HabitOptionResult.delete),
            ),
            const SizedBox(height: AppDimensions.paddingSm),
            _OptionTile(
              icon: Icons.close,
              label: AppStrings.cancel,
              onTap: () => Navigator.of(context).pop(HabitOptionResult.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingMd,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? AppColors.textPrimary,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Text(
                label,
                style: TextStyle(
                  color: labelColor ?? AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
