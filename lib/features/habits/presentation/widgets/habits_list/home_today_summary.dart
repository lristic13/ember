import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/habit_entries_state.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';

/// Home "Today" summary: a mono date label, a large "Today" heading, and an
/// accent chip showing how many of today's habits are done.
class HomeTodaySummary extends ConsumerWidget {
  final List<Habit> habits;

  const HomeTodaySummary({super.key, required this.habits});

  static const List<String> _weekdays = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
  ];
  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final now = DateTime.now();
    final dateLabel =
        '${_weekdays[now.weekday - 1]} · ${_months[now.month - 1]} ${now.day}';

    final doneCount = habits.where((h) {
      final state = ref.watch(habitEntriesViewModelProvider(h.id));
      return state is HabitEntriesLoaded &&
          state.getValueForDate(now) > 0;
    }).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: EmberText.mono(12, color: palette.dim)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Today',
                  style: EmberText.display(
                    34,
                    color: palette.text,
                    letterSpacingEm: -0.03,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: EmberAccent.chipFill,
                  border: Border.all(color: EmberAccent.chipBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$doneCount',
                      style: EmberText.display(22, color: EmberAccent.neon),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'OF ${habits.length} DONE',
                      style: EmberText.mono(12, color: palette.dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
