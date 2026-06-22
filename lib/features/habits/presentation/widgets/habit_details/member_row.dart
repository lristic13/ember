import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit_participant.dart';

/// One participant in a shared habit's members list: a gradient initials
/// avatar, name + `@handle`, an Owner/You tag, and an optional remove control.
class MemberRow extends StatelessWidget {
  final HabitParticipant participant;
  final bool isYou;
  final bool canRemove;
  final VoidCallback? onRemove;

  const MemberRow({
    super.key,
    required this.participant,
    this.isYou = false,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final handle = participant.handle;
    final title = (participant.displayName != null &&
            participant.displayName!.trim().isNotEmpty)
        ? participant.displayName!.trim()
        : (handle != null ? '@$handle' : 'Member');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: EmberGradients.accent155,
            ),
            child: Text(
              participant.initials,
              style: EmberText.display(13, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EmberText.display(15, color: palette.text),
                ),
                if (handle != null && participant.displayName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@$handle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: EmberText.mono(10, color: palette.dimmer),
                  ),
                ],
              ],
            ),
          ),
          if (participant.isOwner || isYou) ...[
            const SizedBox(width: 8),
            Text(
              participant.isOwner ? 'OWNER' : 'YOU',
              style: EmberText.mono(10, color: palette.dim),
            ),
          ],
          if (canRemove) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: EmberSemantic.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
