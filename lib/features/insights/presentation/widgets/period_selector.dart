import 'package:flutter/material.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showPeriodSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedPeriod.label,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
