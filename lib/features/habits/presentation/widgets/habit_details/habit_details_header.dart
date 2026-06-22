import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../shared/widgets/ember_icon_tile.dart';
import '../../../domain/entities/habit.dart';
import '../../viewmodels/shared_habit_providers.dart';
import '../habits_list/participant_avatars.dart';
import '../invites/invite_sheet.dart';

/// Centered hero identity: large icon tile, habit name, a type pill, and — for
/// shared habits — the participants (dimmed if they haven't logged today on an
/// "Everyone" habit). Tapping the avatars opens the members modal.
class HabitDetailsHeader extends ConsumerWidget {
  final Habit habit;

  const HabitDetailsHeader({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final color = HabitColor.fromGradient(habit.gradient);
    final typeLabel = habit.isQuantity
        ? '${habit.unit ?? 'Amount'} · Daily'
        : 'Yes / No · Daily';

    Set<String>? loggedUids;
    if (habit.isTogether) {
      final checks =
          ref.watch(sharedHabitChecksProvider(habit.id)).asData?.value ??
          const <DateTime, Map<String, double>>{};
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      loggedUids = (checks[today] ?? const <String, double>{}).keys.toSet();
    }

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
        if (habit.isShared) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showMembers(context, ref),
            behavior: HitTestBehavior.opaque,
            child: ParticipantAvatars(
              participants: habit.participants,
              size: 30,
              loggedUids: loggedUids,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showMembers(BuildContext context, WidgetRef ref) async {
    final message = await showInviteSheet(context, habit);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
