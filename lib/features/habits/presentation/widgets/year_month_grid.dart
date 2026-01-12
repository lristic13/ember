import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import 'mini_month_heatmap.dart';

class YearMonthGrid extends StatelessWidget {
  final int year;
  final Map<DateTime, double> entriesByDate;
  final Map<DateTime, double> intensitiesByDate;
  final void Function(DateTime date, double value)? onCellTap;

  const YearMonthGrid({
    super.key,
    required this.year,
    required this.entriesByDate,
    required this.intensitiesByDate,
    this.onCellTap,
  });

  static const List<String> _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingMd,
      runSpacing: AppDimensions.paddingLg,
      alignment: WrapAlignment.center,
      children: List.generate(12, (index) {
        final month = index + 1;
        return MiniMonthHeatmap(
          year: year,
          month: month,
          monthLabel: _monthLabels[index],
          entriesByDate: entriesByDate,
          intensitiesByDate: intensitiesByDate,
          onCellTap: onCellTap,
        );
      }),
    );
  }
}
