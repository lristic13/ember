import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../shared/widgets/ember_check_circle.dart';
import '../../../../../shared/widgets/ember_icon_tile.dart';
import '../../../domain/entities/habit.dart';
import 'habit_streak_chip.dart';
import 'home_week_strip.dart';
import 'participant_avatars.dart';

class HabitCardContent extends ConsumerWidget {
  final Habit habit;
  final double todayValue;
  final VoidCallback onTap;
  final VoidCallback onQuickLog;
  final void Function(DateTime date, double currentValue) onCellTap;

  const HabitCardContent({
    super.key,
    required this.habit,
    required this.todayValue,
    required this.onTap,
    required this.onQuickLog,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final color = HabitColor.fromGradient(habit.gradient);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EmberIconTile(emoji: habit.emoji, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              habit.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: EmberText.display(19, color: palette.text),
                            ),
                          ),
                          // For shared habits, show who's in it next to the name.
                          if (habit.isShared) ...[
                            const SizedBox(width: 8),
                            ParticipantAvatars(
                              participants: habit.participants,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      HabitStreakChip(habitId: habit.id, color: color),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                EmberCheckCircle(
                  done: todayValue > 0,
                  color: color,
                  onTap: onQuickLog,
                ),
              ],
            ),
            const SizedBox(height: 16),
            HomeWeekStrip(
              habitId: habit.id,
              color: color,
              onCellTap: onCellTap,
            ),
          ],
        ),
      ),
    );
  }
}
