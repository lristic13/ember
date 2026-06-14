import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/ember_tokens.dart';
import '../../../../../core/theme/theme_provider.dart';
import '../../../../../shared/widgets/ember_icon_button.dart';
import '../../../../../shared/widgets/ember_wordmark.dart';
import '../../viewmodels/view_mode_provider.dart';

/// Blurred, translucent header for the home screen: the ember wordmark plus
/// insights and calendar (view-mode) icon buttons.
class HabitsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HabitsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(habitsViewModeProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
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
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onTap: () => ref.read(themeProvider.notifier).toggle(),
              child: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 18,
                color: palette.dim,
              ),
            ),
            const SizedBox(width: 10),
            EmberIconButton(
              tooltip: 'Insights',
              onTap: () => context.push(AppRoutes.insights),
              child: Icon(Icons.insights, size: 18, color: palette.dim),
            ),
            const SizedBox(width: 10),
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
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
