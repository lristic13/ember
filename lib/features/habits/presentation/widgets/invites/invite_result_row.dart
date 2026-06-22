import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/habit_participant.dart';

/// A user search result in the invite sheet: avatar, name, `@handle`, and an
/// add affordance. Tapping anywhere adds them.
class InviteResultRow extends StatelessWidget {
  final HabitParticipant user;
  final VoidCallback onAdd;

  const InviteResultRow({super.key, required this.user, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final hasName =
        user.displayName != null && user.displayName!.trim().isNotEmpty;
    final title = hasName
        ? user.displayName!.trim()
        : (user.handle != null ? '@${user.handle}' : 'User');

    return GestureDetector(
      onTap: onAdd,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: EmberGradients.accent155,
              ),
              child: Text(
                user.initials,
                style: EmberText.display(12, color: Colors.white),
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
                  if (hasName && user.handle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '@${user.handle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: EmberText.mono(10, color: palette.dimmer),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline_rounded,
              size: 22,
              color: EmberAccent.neon,
            ),
          ],
        ),
      ),
    );
  }
}
