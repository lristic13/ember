import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../viewmodels/intensity_viewmodel.dart';
import 'heatmap_navigation.dart';
import 'year_month_grid.dart';

class YearHeatmapContent extends ConsumerStatefulWidget {
  final String habitId;
  final String unit;
  final Map<DateTime, double> entriesByDate;
  final HabitGradient gradient;

  const YearHeatmapContent({
    super.key,
    required this.habitId,
    required this.unit,
    required this.entriesByDate,
    required this.gradient,
  });

  @override
  ConsumerState<YearHeatmapContent> createState() => _YearHeatmapContentState();
}

class _YearHeatmapContentState extends ConsumerState<YearHeatmapContent> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  void _goToPreviousYear() {
    setState(() {
      _selectedYear--;
    });
  }

  void _goToNextYear() {
    setState(() {
      _selectedYear++;
    });
  }

  void _showTooltip(BuildContext context, DateTime date, double value) {
    final formattedDate = DateFormat.MMMd().format(date);
    final valueText = value > 0
        ? '${value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1)} ${widget.unit}'
        : AppStrings.noEntry;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$formattedDate: $valueText'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch intensities for the entire year
    final startDate = DateTime(_selectedYear, 1, 1);
    final endDate = DateTime(_selectedYear, 12, 31);

    final intensitiesAsync = ref.watch(
      habitIntensitiesProvider(
        widget.habitId,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Column(
        children: [
          HeatmapNavigation(
            title: _selectedYear.toString(),
            onPrevious: _goToPreviousYear,
            onNext: _goToNextYear,
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          intensitiesAsync.when(
            data: (intensitiesByDate) => YearMonthGrid(
              year: _selectedYear,
              entriesByDate: widget.entriesByDate,
              intensitiesByDate: intensitiesByDate,
              gradient: widget.gradient,
              onCellTap: (date, value) => _showTooltip(context, date, value),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingLg),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => YearMonthGrid(
              year: _selectedYear,
              entriesByDate: widget.entriesByDate,
              intensitiesByDate: const {},
              gradient: widget.gradient,
              onCellTap: (date, value) => _showTooltip(context, date, value),
            ),
          ),
        ],
      ),
    );
  }
}
