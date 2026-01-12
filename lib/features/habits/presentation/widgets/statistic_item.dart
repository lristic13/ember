import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;

  const StatisticItem({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(
              color: valueColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          if (unit != null) ...[
            Text(
              unit!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXs),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
