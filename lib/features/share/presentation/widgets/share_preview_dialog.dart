import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../providers/share_providers.dart';
import '../utils/heat_map_image_generator.dart';
import 'share_full_preview_screen.dart';
import 'share_period_selector.dart';
import 'share_picker_sheet.dart';

/// Bottom sheet for previewing and sharing heat map images.
class SharePreviewSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final int initialYear;
  final List<int> availableYears;

  const SharePreviewSheet({
    super.key,
    required this.habit,
    required this.initialYear,
    required this.availableYears,
  });

  /// Shows the share preview bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required Habit habit,
    required int initialYear,
    required List<int> availableYears,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SharePreviewSheet(
        habit: habit,
        initialYear: initialYear,
        availableYears: availableYears,
      ),
    );
  }

  @override
  ConsumerState<SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends ConsumerState<SharePreviewSheet> {
  late int _selectedYear;
  int _selectedMonth = DateTime.now().month;
  List<HabitEntry> _entries = [];
  bool _isLoading = false;
  bool _isLoadingEntries = true;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoadingEntries = true;
    });

    final shareUseCase = ref.read(shareHeatMapProvider);

    _entries = await shareUseCase.getEntriesForMonth(
      habitId: widget.habit.id,
      year: _selectedYear,
      month: _selectedMonth,
    );

    if (mounted) {
      setState(() {
        _isLoadingEntries = false;
      });
    }
  }

  void _showFullPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShareFullPreviewScreen(
          habit: widget.habit,
          entries: _entries,
          year: _selectedYear,
          month: _selectedMonth,
        ),
      ),
    );
  }

  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SharePickerSheet(
        title: 'Select Year',
        items: widget.availableYears.map((y) => y.toString()).toList(),
        selectedIndex: widget.availableYears.indexOf(_selectedYear),
        onSelect: (index) {
          setState(() => _selectedYear = widget.availableYears[index]);
          _loadEntries();
        },
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SharePickerSheet(
        title: 'Select Month',
        items: _monthNames,
        selectedIndex: _selectedMonth - 1,
        onSelect: (index) {
          setState(() => _selectedMonth = index + 1);
          _loadEntries();
        },
      ),
    );
  }

  Future<void> _share() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentContext = context;

      // Close the bottom sheet first
      Navigator.of(currentContext).pop();

      // Generate and share image
      final filePath = await HeatMapImageGenerator.generate(
        context: currentContext,
        habit: widget.habit,
        entries: _entries,
        year: _selectedYear,
        month: _selectedMonth,
      );

      await Share.shareXFiles(
        [XFile(filePath)],
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          Text(
            'Share Month',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Year/Month selectors
          SharePeriodSelector(
            yearLabel: _selectedYear.toString(),
            multipleYears: widget.availableYears.length > 1,
            onYearTap: _showYearPicker,
            monthLabel: _monthNames[_selectedMonth - 1],
            onMonthTap: _showMonthPicker,
          ),

          const SizedBox(height: 16),

          // Preview full image button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoadingEntries ? null : _showFullPreview,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fullscreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Preview Full Image',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Share button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || _isLoadingEntries ? null : _share,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Share Image',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep old name as alias for backward compatibility
typedef SharePreviewDialog = SharePreviewSheet;
