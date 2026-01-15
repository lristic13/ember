import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/insights_period.dart';

class PeriodSelector extends StatelessWidget {
  final InsightsPeriod selectedPeriod;
  final ValueChanged<InsightsPeriod> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  Future<void> _showPeriodSheet(BuildContext context) async {
    final result = await showModalBottomSheet<InsightsPeriod>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (context) => _PeriodBottomSheet(selectedPeriod: selectedPeriod),
    );

    if (result != null) {
      onPeriodChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPeriodSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedPeriod.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodBottomSheet extends StatelessWidget {
  final InsightsPeriod selectedPeriod;

  const _PeriodBottomSheet({required this.selectedPeriod});

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
            ...InsightsPeriod.values.map((period) {
              final isSelected = period == selectedPeriod;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSm),
                child: Material(
                  color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.surfaceLight,
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
                                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.accent,
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
