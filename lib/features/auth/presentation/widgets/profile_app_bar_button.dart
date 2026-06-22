import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/ember_tokens.dart';
import '../../../../shared/widgets/ember_icon_button.dart';
import '../../../habits/presentation/viewmodels/invite_providers.dart';
import '../viewmodels/auth_providers.dart';
import 'profile_avatar.dart';

/// App-bar entry point: a small initials avatar (→ Profile) when signed in, or
/// a "sign in to share" person icon (→ Sign in) when signed out.
class ProfileAppBarButton extends ConsumerWidget {
  const ProfileAppBarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = EmberPalette.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return EmberIconButton(
        tooltip: 'Sign in to share',
        onTap: () => context.push(AppRoutes.signIn),
        child: Icon(Icons.person_outline_rounded, size: 18, color: palette.dim),
      );
    }

    final pendingInvites = ref.watch(pendingInviteCountProvider);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.profile),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProfileAvatar(initials: user.initials, size: 28),
          if (pendingInvites > 0)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: EmberSemantic.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.bg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
