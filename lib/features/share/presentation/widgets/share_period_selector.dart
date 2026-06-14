import 'package:flutter/material.dart';

import 'share_period_picker_button.dart';

/// Year picker button plus an optional month picker button.
class SharePeriodSelector extends StatelessWidget {
  final String yearLabel;
  final bool multipleYears;
  final VoidCallback onYearTap;
  final String? monthLabel;
  final VoidCallback? onMonthTap;

  const SharePeriodSelector({
    super.key,
    required this.yearLabel,
    required this.multipleYears,
    required this.onYearTap,
    this.monthLabel,
    this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SharePeriodPickerButton(
            label: yearLabel,
            showChevron: multipleYears,
            onTap: multipleYears ? onYearTap : null,
          ),
        ),
        if (monthLabel != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: SharePeriodPickerButton(
              label: monthLabel!,
              showChevron: true,
              onTap: onMonthTap,
            ),
          ),
        ],
      ],
    );
  }
}
