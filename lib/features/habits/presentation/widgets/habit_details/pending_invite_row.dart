import 'package:flutter/material.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/invite.dart';

/// A still-pending invite shown to the owner in the members list: the invited
/// `@handle`, a "Pending" tag, and a cancel control.
class PendingInviteRow extends StatelessWidget {
  final Invite invite;
  final VoidCallback onCancel;

  const PendingInviteRow({
    super.key,
    required this.invite,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final handle = invite.toHandle;

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
              color: palette.field,
              border: Border.all(color: palette.border),
            ),
            child: Icon(Icons.schedule_rounded, size: 18, color: palette.dimmer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              handle != null ? '@$handle' : 'Invited',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: EmberText.display(15, color: palette.dim),
            ),
          ),
          Text('PENDING', style: EmberText.mono(10, color: palette.dimmer)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: EmberSemantic.danger,
            ),
          ),
        ],
      ),
    );
  }
}
