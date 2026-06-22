import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit_participant.dart';

/// Overlapping initials-avatars for a shared habit's participants. Shows up to
/// three, then a "+N" chip. Signals (and identifies) a shared habit.
class ParticipantAvatars extends StatelessWidget {
  final List<HabitParticipant> participants;
  final double size;

  const ParticipantAvatars({
    super.key,
    required this.participants,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final palette = EmberPalette.of(context);
    final shown = participants.take(3).toList();
    final extra = participants.length - shown.length;
    final step = size * 0.62;
    final count = shown.length + (extra > 0 ? 1 : 0);

    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: EmberGradients.accent155,
                  border: Border.all(color: palette.card, width: 2),
                ),
                child: Text(
                  shown[i].initials,
                  style: EmberText.display(
                    size * 0.34,
                    color: Colors.white,
                    letterSpacingEm: -0.02,
                  ),
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.cardHi,
                  border: Border.all(color: palette.card, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: EmberText.display(size * 0.3, color: palette.dim),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
