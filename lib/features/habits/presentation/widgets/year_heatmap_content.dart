import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/habit_gradients.dart';
import '../../domain/entities/tracking_type.dart';
import '../viewmodels/intensity_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'heatmap_navigation.dart';
import 'year_month_grid.dart';

class YearHeatmapContent extends ConsumerStatefulWidget {
  final String habitId;
  final String habitName;
  final TrackingType trackingType;
  final String? unit;
  final Map<DateTime, double> entriesByDate;
  final HabitGradient gradient;

  const YearHeatmapContent({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.trackingType,
    this.unit,
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

  void _showEntryEditor(BuildContext context, DateTime date, double value) {
    showEntryEditorBottomSheet(
      context: context,
      habitId: widget.habitId,
      habitName: widget.habitName,
      trackingType: widget.trackingType,
      unit: widget.unit,
      date: date,
      currentValue: value,
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

    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding + AppDimensions.paddingMd,
        left: AppDimensions.paddingMd,
        right: AppDimensions.paddingMd,
        bottom: AppDimensions.paddingMd,
      ),
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
              onCellTap: (date, value) =>
                  _showEntryEditor(context, date, value),
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
              onCellTap: (date, value) =>
                  _showEntryEditor(context, date, value),
            ),
          ),
        ],
      ),
    );
  }
}
