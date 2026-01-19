import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../share/presentation/providers/share_providers.dart';
import '../../../share/presentation/widgets/share_preview_dialog.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/intensity_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'heatmap_navigation.dart';
import 'year_month_grid.dart';

class YearHeatmapContent extends ConsumerStatefulWidget {
  final Habit habit;
  final Map<DateTime, double> entriesByDate;

  const YearHeatmapContent({
    super.key,
    required this.habit,
    required this.entriesByDate,
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
      habitId: widget.habit.id,
      habitName: widget.habit.name,
      trackingType: widget.habit.trackingType,
      unit: widget.habit.unit,
      date: date,
      currentValue: value,
    );
  }

  Future<void> _showShareDialog(BuildContext context) async {
    final shareUseCase = ref.read(shareHeatMapProvider);

    // Get years with data
    final years = await shareUseCase.getYearsWithData(widget.habit.id);

    // Use currently selected year as default, or first available year
    final initialYear = years.contains(_selectedYear)
        ? _selectedYear
        : (years.isNotEmpty ? years.first : _selectedYear);

    // Ensure we have at least the selected year in the list
    final availableYears = years.isNotEmpty ? years : [_selectedYear];

    if (context.mounted) {
      await SharePreviewDialog.show(
        context: context,
        habit: widget.habit,
        initialYear: initialYear,
        availableYears: availableYears,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fetch intensities for the entire year
    final startDate = DateTime(_selectedYear, 1, 1);
    final endDate = DateTime(_selectedYear, 12, 31);

    final intensitiesAsync = ref.watch(
      habitIntensitiesProvider(
        widget.habit.id,
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
            trailing: IconButton(
              icon: const Icon(Icons.share),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              tooltip: 'Share',
              onPressed: () => _showShareDialog(context),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          intensitiesAsync.when(
            data: (intensitiesByDate) => YearMonthGrid(
              year: _selectedYear,
              entriesByDate: widget.entriesByDate,
              intensitiesByDate: intensitiesByDate,
              gradient: widget.habit.gradient,
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
              gradient: widget.habit.gradient,
              onCellTap: (date, value) =>
                  _showEntryEditor(context, date, value),
            ),
          ),
        ],
      ),
    );
  }
}
