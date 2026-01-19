import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_entry.dart';
import '../providers/share_providers.dart';
import '../utils/heat_map_image_generator.dart';
import 'share_card.dart';

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

enum ShareMode { year, month }

class _SharePreviewSheetState extends ConsumerState<SharePreviewSheet> {
  late int _selectedYear;
  int _selectedMonth = DateTime.now().month;
  ShareMode _shareMode = ShareMode.year;
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

    if (_shareMode == ShareMode.month) {
      _entries = await shareUseCase.getEntriesForMonth(
        habitId: widget.habit.id,
        year: _selectedYear,
        month: _selectedMonth,
      );
    } else {
      _entries = await shareUseCase.getEntriesForYear(
        habitId: widget.habit.id,
        year: _selectedYear,
      );
    }

    if (mounted) {
      setState(() {
        _isLoadingEntries = false;
      });
    }
  }

  void _showFullPreview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullPreviewScreen(
          habit: widget.habit,
          entries: _entries,
          year: _selectedYear,
          month: _shareMode == ShareMode.month ? _selectedMonth : null,
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
      builder: (context) => _PickerSheet(
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
      builder: (context) => _PickerSheet(
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
        month: _shareMode == ShareMode.month ? _selectedMonth : null,
      );

      final periodText = _shareMode == ShareMode.month
          ? '${_monthNames[_selectedMonth - 1]} $_selectedYear'
          : '$_selectedYear';

      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            'My ${widget.habit.name} journey in $periodText \u{1F525}\n\nTracked with Ember',
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
            'Share Heat Map',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Mode toggle (Year / Month)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_shareMode != ShareMode.year) {
                        setState(() => _shareMode = ShareMode.year);
                        _loadEntries();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _shareMode == ShareMode.year
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Year',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _shareMode == ShareMode.year
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_shareMode != ShareMode.month) {
                        setState(() => _shareMode = ShareMode.month);
                        _loadEntries();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _shareMode == ShareMode.month
                            ? AppColors.accent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Month',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _shareMode == ShareMode.month
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Year/Month selectors
          Row(
            children: [
              // Year picker button
              Expanded(
                child: GestureDetector(
                  onTap: widget.availableYears.length > 1 ? _showYearPicker : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedYear.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.availableYears.length > 1)
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              // Month picker button (only in month mode)
              if (_shareMode == ShareMode.month) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _showMonthPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _monthNames[_selectedMonth - 1],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Preview card
          // Container(
          //   decoration: BoxDecoration(
          //     color: AppColors.background,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: AppColors.surfaceLight,
          //       width: 1,
          //     ),
          //   ),
          //   padding: const EdgeInsets.all(16),
          //   child: _isLoadingEntries
          //       ? const SizedBox(
          //           height: 120,
          //           child: Center(
          //             child: CircularProgressIndicator(
          //               color: AppColors.accent,
          //             ),
          //           ),
          //         )
          //       : Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             // Header row
          //             Row(
          //               children: [
          //                 if (widget.habit.emoji != null) ...[
          //                   Text(
          //                     widget.habit.emoji!,
          //                     style: const TextStyle(fontSize: 24),
          //                   ),
          //                   const SizedBox(width: 12),
          //                 ],
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(
          //                         widget.habit.name,
          //                         style: AppTextStyles.bodyLarge.copyWith(
          //                           color: AppColors.textPrimary,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                         maxLines: 1,
          //                         overflow: TextOverflow.ellipsis,
          //                       ),
          //                       Text(
          //                         _selectedYear.toString(),
          //                         style: TextStyle(
          //                           color: gradient.max,
          //                           fontSize: 12,
          //                           fontWeight: FontWeight.w500,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),

          //             const SizedBox(height: 16),

          //             // Heat map preview
          //             SizedBox(
          //               height: 60,
          //               child: ShareCardHeatMap(
          //                 entries: _entries,
          //                 year: _selectedYear,
          //                 gradient: gradient,
          //               ),
          //             ),

          //             const SizedBox(height: 16),

          //             // Stats row
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //               children: [
          //                 _buildStatItem(
          //                   'Days',
          //                   _entries.length.toString(),
          //                   gradient,
          //                 ),
          //                 _buildStatItem(
          //                   'Streak',
          //                   '${_calculateLongestStreak(_entries)}d',
          //                   gradient,
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          // ),
          // const SizedBox(height: 16),

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

/// Full screen preview of the share card at 1080x1920 scaled to fit.
class _FullPreviewScreen extends StatelessWidget {
  final Habit habit;
  final List<HabitEntry> entries;
  final int year;
  final int? month;

  const _FullPreviewScreen({
    required this.habit,
    required this.entries,
    required this.year,
    this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: ShareCard(
            habit: habit,
            entries: entries,
            year: year,
            month: month,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet picker for selecting year or month.
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final int selectedIndex;
  final void Function(int index) onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
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
          // Title
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Items list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          items[index],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
