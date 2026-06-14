import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/insights_period.dart';

class PeriodBottomSheet extends StatelessWidget {
  final InsightsPeriod selectedPeriod;

  const PeriodBottomSheet({super.key, required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLg),
            ...InsightsPeriod.values.map((period) {
              final isSelected = period == selectedPeriod;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSm),
                child: Material(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(period),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMd,
                        vertical: AppDimensions.paddingMd,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              period.label,
                              style: TextStyle(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                              size: AppDimensions.iconMd,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
