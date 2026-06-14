import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../shared/widgets/ember_icon_tile.dart';
import '../../../domain/entities/habit.dart';

/// Centered hero identity: large icon tile, habit name, and a type pill.
class HabitDetailsHeader extends StatelessWidget {
  final Habit habit;

  const HabitDetailsHeader({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final color = HabitColor.fromGradient(habit.gradient);
    final typeLabel = habit.isQuantity
        ? '${habit.unit ?? 'Amount'} · Daily'
        : 'Yes / No · Daily';

    return Column(
      children: [
        EmberIconTile(emoji: habit.emoji, color: color, size: 64),
        const SizedBox(height: 14),
        Text(
          habit.name,
          textAlign: TextAlign.center,
          style: EmberText.display(27, color: palette.text, letterSpacingEm: -0.03),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: palette.cardHi,
            border: Border.all(color: palette.border),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            typeLabel.toUpperCase(),
            style: EmberText.mono(11, color: palette.dim),
          ),
        ),
      ],
    );
  }
}
