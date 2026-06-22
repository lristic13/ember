import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/ember_tokens.dart';
import '../viewmodels/invite_providers.dart';
import '../widgets/invites/invite_card.dart';

/// Inbox of pending collaboration invites. Updates live as invites arrive or
/// are answered.
class InvitesScreen extends ConsumerWidget {
  const InvitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final invitesAsync = ref.watch(pendingInvitesProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.close_rounded,
                          color: palette.dim,
                          size: 22,
                        ),
                      ),
                    ),
                    Text(
                      'Invites',
                      style: EmberText.display(15, color: palette.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: invitesAsync.when(
                  data: (invites) {
                    if (invites.isEmpty) {
                      return _EmptyState(palette: palette);
                    }
                    return ListView.separated(
                      itemCount: invites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => InviteCard(invite: invites[i]),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _EmptyState(palette: palette),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final EmberPalette palette;

  const _EmptyState({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 40, color: palette.dimmer),
          const SizedBox(height: 14),
          Text(
            'No pending invites',
            style: EmberText.display(16, color: palette.dim),
          ),
          const SizedBox(height: 6),
          Text(
            'When someone shares a habit with you,\nit shows up here.',
            textAlign: TextAlign.center,
            style: EmberText.mono(11, color: palette.dimmer),
          ),
        ],
      ),
    );
  }
}
