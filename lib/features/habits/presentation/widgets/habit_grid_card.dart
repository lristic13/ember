import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/habit.dart';
import '../viewmodels/habit_entries_viewmodel.dart';
import '../viewmodels/intensity_viewmodel.dart';
import 'entry_editor_bottom_sheet.dart';
import 'mini_month_heatmap.dart';

class HabitGridCard extends ConsumerWidget {
  final Habit habit;

  const HabitGridCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final entriesAsync = ref.watch(allHabitEntriesProvider(habit.id));
    final intensitiesAsync = ref.watch(
      habitIntensitiesProvider(
        habit.id,
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
      ),
    );

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.habitDetailsPath(habit.id)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji and name
              Row(
                children: [
                  if (habit.emoji != null)
                    Text(habit.emoji!, style: const TextStyle(fontSize: 20)),
                  if (habit.emoji != null)
                    const SizedBox(width: AppDimensions.paddingXs),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingXs),

              // Mini month heatmap
              entriesAsync.when(
                data: (entriesByDate) {
                  final intensitiesByDate = intensitiesAsync.whenOrNull(
                        data: (intensities) => intensities,
                      ) ??
                      <DateTime, double>{};

                  return MiniMonthHeatmap(
                    year: now.year,
                    month: now.month,
                    monthLabel: _getMonthLabel(now.month),
                    entriesByDate: entriesByDate,
                    intensitiesByDate: intensitiesByDate,
                    gradient: habit.gradient,
                    expandToFill: true,
                    onCellTap: (date, value) => _showEntryEditor(context, date, value),
                  );
                },
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEntryEditor(BuildContext context, DateTime date, double value) {
    showEntryEditorBottomSheet(
      context: context,
      habitId: habit.id,
      habitName: habit.name,
      trackingType: habit.trackingType,
      unit: habit.unit,
      date: date,
      currentValue: value,
    );
  }

  String _getMonthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
