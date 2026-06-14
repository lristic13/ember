import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/ember_tokens.dart';
import '../../domain/entities/insights_period.dart';
import 'period_bottom_sheet.dart';

/// Compact range selector pill ("7 DAYS ▾") for the insights header.
class InsightsRangePill extends StatelessWidget {
  final InsightsPeriod selectedPeriod;
  final ValueChanged<InsightsPeriod> onPeriodChanged;

  const InsightsRangePill({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<InsightsPeriod>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (context) => PeriodBottomSheet(selectedPeriod: selectedPeriod),
    );
    if (result != null) onPeriodChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: palette.cardHi,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${selectedPeriod.days} DAYS',
              style: EmberText.mono(11, color: palette.dim),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down, size: 14, color: palette.dim),
          ],
        ),
      ),
    );
  }
}
