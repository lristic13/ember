import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../shared/widgets/ember_icon_button.dart';
import '../../../../../shared/widgets/ember_wordmark.dart';
import '../../../../auth/presentation/widgets/profile_app_bar_button.dart';
import '../../viewmodels/view_mode_provider.dart';

/// Blurred, translucent header for the home screen: the ember wordmark, the
/// calendar (view-mode) toggle, and the profile / sign-in entry point.
class HabitsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HabitsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(habitsViewModeProvider);
    final palette = EmberPalette.of(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: palette.bg.withValues(alpha: 0.7),
          centerTitle: false,
          titleSpacing: 20,
          title: const EmberWordmark(size: 23),
          actions: [
            EmberIconButton(
              tooltip: viewMode == HabitsViewMode.week ? 'Month view' : 'Week view',
              onTap: () => ref.read(habitsViewModeProvider.notifier).toggle(),
              child: Icon(
                viewMode == HabitsViewMode.week
                    ? Icons.calendar_today_outlined
                    : Icons.view_agenda_outlined,
                size: 18,
                color: palette.dim,
              ),
            ),
            const SizedBox(width: 10),
            const ProfileAppBarButton(),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
