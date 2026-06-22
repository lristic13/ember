import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ember_tokens.dart';
import '../../../habits/presentation/viewmodels/invite_providers.dart';
import '../viewmodels/auth_providers.dart';
import '../viewmodels/profile_view_model.dart';
import '../widgets/appearance_row.dart';
import '../widgets/delete_account_sheet.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_list_row.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final user = ref.watch(currentUserProvider);
    final name = user?.displayName ?? 'You';
    final handle = user?.handle ?? '';
    final pendingInvites = ref.watch(pendingInviteCountProvider);

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
                      'Profile',
                      style: EmberText.display(15, color: palette.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ProfileAvatar(initials: user?.initials ?? '?'),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: EmberText.display(
                  22,
                  color: palette.text,
                  letterSpacingEm: -0.03,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                handle.isEmpty ? '' : '@$handle',
                textAlign: TextAlign.center,
                style: EmberText.mono(12, color: palette.dim),
              ),
              const SizedBox(height: 22),
              ProfileListRow(
                icon: Icons.bar_chart_rounded,
                tint: EmberAccent.neon.withValues(alpha: 0.10),
                label: 'Insights',
                subtitle: 'See where you showed up',
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: palette.dimmer,
                  size: 22,
                ),
                onTap: () => context.push(AppRoutes.insights),
              ),
              const SizedBox(height: 8),
              ProfileListRow(
                icon: Icons.mark_email_unread_outlined,
                tint: EmberAccent.neon.withValues(alpha: 0.10),
                label: 'Invites',
                subtitle: pendingInvites > 0
                    ? '$pendingInvites waiting for you'
                    : 'Habits people shared with you',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pendingInvites > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: EmberGradients.accent155,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingInvites',
                          style: EmberText.mono(11, color: EmberAccent.ink),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      Icons.chevron_right_rounded,
                      color: palette.dimmer,
                      size: 22,
                    ),
                  ],
                ),
                onTap: () => context.push(AppRoutes.invites),
              ),
              const SizedBox(height: 8),
              const AppearanceRow(),
              const Spacer(),
              ProfileActionButton(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                onPressed: () =>
                    ref.read(profileViewModelProvider.notifier).signOut(),
              ),
              const SizedBox(height: 8),
              ProfileActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Delete account',
                danger: true,
                onPressed: () => showDeleteAccountSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
