import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../domain/entities/invite.dart';
import '../../viewmodels/invite_providers.dart';
import 'invite_action_button.dart';

/// A single pending invite: habit identity, who sent it, and Accept / Decline.
/// On a successful response the underlying stream drops it from the list.
class InviteCard extends ConsumerStatefulWidget {
  final Invite invite;

  const InviteCard({super.key, required this.invite});

  @override
  ConsumerState<InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends ConsumerState<InviteCard> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await ref
        .read(inviteRepositoryProvider)
        .respondToInvite(inviteId: widget.invite.id, accept: accept);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              accept
                  ? 'Joined ${widget.invite.habitName}'
                  : 'Invite declined',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = EmberPalette.of(context);
    final invite = widget.invite;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.field,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  invite.habitEmoji ?? '🔥',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.habitName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: EmberText.display(17, color: palette.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${invite.fromLabel} invited you',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: EmberText.mono(11, color: palette.dim),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InviteActionButton(
                  label: 'Decline',
                  filled: false,
                  enabled: !_busy,
                  onTap: () => _respond(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InviteActionButton(
                  label: 'Accept',
                  filled: true,
                  enabled: !_busy,
                  loading: _busy,
                  onTap: () => _respond(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
