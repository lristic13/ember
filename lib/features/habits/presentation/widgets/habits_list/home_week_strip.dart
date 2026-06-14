import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../core/utils/date_utils.dart' as date_utils;
import '../../viewmodels/habit_entries_state.dart';
import '../../viewmodels/habit_entries_viewmodel.dart';

/// The 7-day week strip on a home activity card: real dates, with done days
/// filled in the habit's color, today ringed in the brand accent, and future
/// days dimmed.
class HomeWeekStrip extends ConsumerWidget {
  final String habitId;
  final HabitColor color;
  final void Function(DateTime date, double currentValue)? onCellTap;

  const HomeWeekStrip({
    super.key,
    required this.habitId,
    required this.color,
    this.onCellTap,
  });

  static const List<String> _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final entriesState = ref.watch(habitEntriesViewModelProvider(habitId));
    final weekDates = date_utils.DateUtils.getWeekDates(DateTime.now());

    return Row(
      children: [
        for (var i = 0; i < weekDates.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
              child: _DayColumn(
                letter: _letters[i],
                date: weekDates[i],
                value: _valueFor(entriesState, weekDates[i]),
                color: color,
                palette: palette,
                onTap: onCellTap,
              ),
            ),
          ),
      ],
    );
  }

  double _valueFor(HabitEntriesState state, DateTime date) {
    if (state is HabitEntriesLoaded) return state.getValueForDate(date);
    return 0;
  }
}

class _DayColumn extends StatelessWidget {
  final String letter;
  final DateTime date;
  final double value;
  final HabitColor color;
  final EmberPalette palette;
  final void Function(DateTime date, double currentValue)? onTap;

  const _DayColumn({
    required this.letter,
    required this.date,
    required this.value,
    required this.color,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = date_utils.DateUtils.isToday(date);
    final future = date_utils.DateUtils.isFuture(date);
    final done = !future && value > 0;

    final cell = AspectRatio(
      aspectRatio: 1,
      child: Opacity(
        opacity: future ? 0.4 : 1,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: done ? color.fill : null,
            color: done ? null : palette.cardHi,
            border: today
                ? Border.all(color: color.base, width: 2)
                : done
                ? null
                : Border.all(color: palette.borderSoft),
            boxShadow: done
                ? [
                    BoxShadow(
                      color: color.base.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '${date.day}',
            style: EmberText.mono(
              13,
              color: done
                  ? color.ink
                  : future
                  ? palette.dimmer
                  : palette.dim,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          letter,
          style: EmberText.mono(
            10,
            color: today ? color.base : palette.dimmer,
          ),
        ),
        const SizedBox(height: 7),
        onTap != null && !future
            ? GestureDetector(
                onTap: () => onTap!(date, value),
                behavior: HitTestBehavior.opaque,
                child: cell,
              )
            : cell,
      ],
    );
  }
}
