import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;

  const StatisticItem({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValueColor = valueColor ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.displaySmall.copyWith(color: effectiveValueColor),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          if (unit != null && unit!.isNotEmpty) ...[
            Text(
              unit!,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXs),
          ],
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
